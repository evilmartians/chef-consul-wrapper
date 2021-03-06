#
# Cookbook Name:: consul_wrapper
# Resource:: sidekiq
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

property :service_name, String, name_property: true
property :username, String, default: 'root'
property :min_procs, Integer, default: 1
property :tags, Array, default: []

default_action :add

action :add do
  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         %w[queue sidekiq]

  proc_lower_limit = new_resource.min_procs

  grep_regex = '[s]idekiq .+ \[[0-9]+ of [0-9]+ busy\]'

  consul_definition "sidekiq-#{new_resource.service_name}" do
    type 'service'
    parameters(tags: tags)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "sidekiq-#{new_resource.service_name}-workers-check" do
    type 'check'
    parameters(
      script: "/usr/bin/test $(/bin/ps aux | /bin/grep -Eo '#{grep_regex}' | /bin/grep -ce '#{new_resource.username}') -ge #{proc_lower_limit}",
      interval: '15s',
      notes: "#{new_resource.service_name} sidekiq should have enough workers running.",
      service_id: "sidekiq-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

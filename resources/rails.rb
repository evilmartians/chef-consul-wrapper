#
# Cookbook Name:: consul_wrapper
# Resource:: rails
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :socket, [String, Integer, FalseClass], default: false
property :url, String, default: '/'
property :hostname, String, default: 'example.com'
property :username, String, default: 'root'
property :appserver, String, default: 'unicorn'
property :min_procs, Integer, default: 2
property :tags, Array, default: []

default_action :add

action :add do
  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         %w[web app rails application]

  socket("/tmp/#{new_resource.service_name}_rails.sock") unless socket

  proc_lower_limit = new_resource.min_procs

  nc_cmd = if socket.is_a?(Integer) || /\A\d+\z/.match(socket)
             "/bin/nc #{new_resource.address} #{new_resource.socket}"
           else
             "/bin/nc -U #{new_resource.socket}"
           end

  grep_regex = if new_resource.appserver == 'unicorn'
                 '[u]nicorn_rails worker'
               elsif new_resource.appserver == 'puma'
                 proc_lower_limit = 1
                 'puma [0-9]\.[0-9]\.[0-9].* \[.*\]'
               end

  consul_definition "application-#{new_resource.service_name}" do
    type 'service'
    parameters(
      tags: tags,
      address: new_resource.address,
      port: 80,
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app-#{new_resource.service_name}-workers-check" do
    type 'check'
    parameters(
      script: "/usr/bin/test $(/bin/ps auxn | /bin/grep '#{grep_regex}' | /bin/grep -ce \"^[ \t]*$(id -u #{new_resource.username})\") -ge #{proc_lower_limit}",
      interval: '15s',
      notes: "#{new_resource.service_name} rails appserver should have workers running.",
      service_id: "application-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app-#{new_resource.service_name}-socket-check" do
    type 'check'
    parameters(
      script: "/bin/echo -e 'GET #{url} HTTP/1.1\\r\\nHost: #{new_resource.hostname}\\r\\nConnection: close\\r\\n\\r\\n' | #{nc_cmd} | /bin/grep -E 'HTTP/1.1 (200|301|302) (OK|Found)'",
      notes: "#{new_resource.service_name.capitalize} rails should serve requests on its socket.",
      interval: '15s',
      service_id: "application-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

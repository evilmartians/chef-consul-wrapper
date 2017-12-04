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
  # rubocop:disable Style/TrailingCommaInArguments
  tags(
    tags +
    service_name.split(/[-_]/) +
    node.chef_environment.split(/[-_]/) +
    %w(web app rails application)
  )
  # rubocop:enable Style/TrailingCommaInArguments

  socket("/tmp/#{service_name}_rails.sock") unless socket

  proc_lower_limit = min_procs

  nc_cmd = if socket.is_a?(Integer) || /\A\d+\z/.match(socket)
             "/bin/nc #{address} #{socket}"
           else
             "/bin/nc -U #{socket}"
           end

  grep_regex = if appserver == 'unicorn'
                 '[u]nicorn_rails worker'
               elsif appserver == 'puma'
                 proc_lower_limit = 1
                 'puma [0-9]\.[0-9]\.[0-9].* \[.*\]'
               end

  consul_definition "application-#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: 80)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app-#{service_name}-workers-check" do
    type 'check'
    parameters(
      # rubocop:disable LineLength
      script: "/usr/bin/test $(/bin/ps auxn | /bin/grep '#{grep_regex}' | /bin/grep -ce \"^[ \t]*$(id -u #{username})\") -ge #{proc_lower_limit}",
      # rubocop:enable LineLength
      interval: '15s',
      notes: "#{service_name} rails appserver should have workers running.",
      service_id: "application-#{service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app-#{service_name}-socket-check" do
    type 'check'
    parameters(
      # rubocop:disable LineLength
      script: "/bin/echo -e 'GET #{url} HTTP/1.1\\r\\nHost: #{hostname}\\r\\nConnection: close\\r\\n\\r\\n' | #{nc_cmd} | /bin/grep 'HTTP/1.1 200 OK'",
      notes: "#{service_name.capitalize} rails should serve requests on its socket.",
      # rubocop:enable LineLength
      interval: '15s',
      service_id: "application-#{service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

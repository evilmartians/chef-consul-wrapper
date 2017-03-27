#
# Cookbook Name:: consul_wrapper
# Resource:: docker
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#
property :service_name, String, name_property: true
property :socket, String, default: '/var/run/docker.sock'
property :tags, Array, default: []
default_action :add

action :add do
  service_type = 'docker'

  tags(tags + service_name.split(/[-_]/) + node.chef_environment.split(/[-_]/) + ['docker'])

  consul_definition "#{service_type}-#{service_name}" do
    type 'service'
    parameters(tags: tags)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{service_name}-process" do
    type 'check'
    parameters(
      script: "/bin/echo -e 'GET /info HTTP/1.1\\r\\nHost: localhost\\r\\nConnection: close\\r\\n\\r\\n' | /bin/nc -U #{socket} | /bin/grep 'HTTP/1.1 200 OK'",
      interval: '15s',
      notes: "#{service_type}-#{service_name} should answer on #{socket} via http",
      service_id: "#{service_type}-#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end

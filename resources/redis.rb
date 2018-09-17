#
# Cookbook Name:: consul_wrapper
# Resource:: redis
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#
property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Integer, default: 6379
property :tags, Array, default: []
default_action :add

action :add do
  service_type = 'redis'

  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         ['redis']

  consul_definition "#{service_type}-#{new_resource.service_name}" do
    type 'service'
    parameters(
      tags: tags,
      address: new_resource.address,
      port: new_resource.port,
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{new_resource.service_name}-process" do
    type 'check'
    parameters(
      script: "/bin/ps aux| /bin/grep -Eo '[r]edis-server #{new_resource.address}:#{new_resource.port}'",
      interval: '15s',
      notes: "#{service_type}-#{new_resource.name} should have process with cmd: redis-server #{new_resource.address}:#{new_resource.port}",
      service_id: "#{service_type}-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{new_resource.service_name}_port" do
    type 'check'
    parameters(
      tcp: "#{new_resource.address}:#{new_resource.port}",
      interval: '15s',
      timeout: '1s',
      notes: "#{service_type}-#{new_resource.name} should listen on #{new_resource.address}:#{new_resource.port}",
      service_id: "#{service_type}-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

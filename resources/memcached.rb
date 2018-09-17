#
# Cookbook Name:: consul_wrapper
# Resource:: memcached
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#
property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Integer, default: 11_211
property :tags, Array, default: []
default_action :add

action :add do
  service_type = 'memcached'

  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         %w[memcached memcache]

  consul_definition "#{service_type}-#{new_resource.service_name}" do
    type 'service'
    parameters(
      tags: tags,
      address: new_resource.address,
      port: new_resource.port,
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{new_resource.service_name}_process" do
    type 'check'
    parameters(
      script: "/bin/ps xau | /bin/grep '[m]emcached.* -l #{new_resource.address}' | /bin/grep  -- '-p #{new_resource.port}'",
      notes: "#{service_type}-#{new_resource.service_name} should have process with cmd: memcached #{new_resource.address}:#{new_resource.port}",
      interval: '15s',
      service_id: "#{service_type}-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end

  notes = "#{service_type}-#{new_resource.service_name} should listen on #{new_resource.address}:#{new_resource.port}"

  consul_definition "#{service_type}-#{new_resource.service_name}-port" do
    type 'check'
    parameters(
      tcp: "#{new_resource.address}:#{new_resource.port}",
      interval: '15s',
      timeout: '1s',
      notes: notes,
      service_id: "#{service_type}-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

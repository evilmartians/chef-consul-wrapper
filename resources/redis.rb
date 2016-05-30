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
property :port, Fixnum, default: 6379
property :tags, Array, default: node.chef_environment.split('_') + ['redis']

default_action :add

action :add do
  service_type = 'redis'

  tags(tags + [service_name])

  directory '/var/lib/consul/checks' do
    recursive true
    owner 'consul'
    group 'consul'
  end

  template "/var/lib/consul/checks/#{service_type}_#{service_name}_process_check" do
    source "#{service_type}_process_check.erb"
    cookbook 'consul_wrapper'
    owner  'consul'
    group  'consul'
    mode   '0755'
  end

  consul_definition "#{service_type}_#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}_#{service_name}_process" do
    type 'check'
    parameters(
      script: "/var/lib/consul/checks/#{service_type}_process_check",
      interval: '15s',
      notes: "#{service.capitalize}_#{name.capitalize} should have process with cmd: redis-server #{address}:#{port}",
      service_id: "#{service_type}_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}_#{service_name}_port" do
    type 'check'
    parameters(
      tcp: "#{address}:#{port}",
      interval: '15s',
      timeout: '1s',
      notes: "#{service.capitalize}_#{name.capitalize} should listen on #{address}:#{port}",
      service_id: "#{service_type}_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end

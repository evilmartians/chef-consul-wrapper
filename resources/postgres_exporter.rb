#
# Cookbook Name:: consul_wrapper
# Resource:: postgres_exporter
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Integer, default: 9187
property :http_location, String, default: '/metrics'
property :tags, Array, default: node.chef_environment.split('_')

default_action :add

action :add do
  tags(tags + [service_name] + %w(postgres_exporter prometheus))

  service_type = 'postgres_exporter'

  consul_definition "#{service_type}_#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}_#{service_name}_port" do
    type 'check'
    parameters(
      tcp: "#{address}:#{port}",
      interval: '15s',
      timeout: '1s',
      notes: "#{service_type}_#{service_name} should listen on #{address}:#{port}",
      service_id: "#{service_type}_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}_#{service_name}_http" do
    type 'check'
    parameters(
      http: "http://#{address}:#{port}#{http_location}",
      interval: '15s',
      timeout: '5s',
      notes: "#{service_type}_#{service_name} should answer with metrics via http",
      service_id: "#{service_type}_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end
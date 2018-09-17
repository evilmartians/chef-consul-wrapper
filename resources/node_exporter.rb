#
# Cookbook Name:: consul_wrapper
# Resource:: node_exporter
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Elasticsearchtribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Integer, default: 9100
property :http_location, String, default: '/metrics'
property :tags, Array, default: node.chef_environment.split('_')

default_action :add

action :add do
  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         %w[node-exporter prometheus]

  service_type = 'node-exporter'

  consul_definition "#{service_type}-#{new_resource.service_name}" do
    type 'service'
    parameters(
      tags: tags,
      address: new_resource.address,
      port: new_resource.port,
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

  notes = "#{service_type}_#{new_resource.service_name} should answer with metrics via http"
  consul_definition "#{service_type}-#{new_resource.service_name}-http" do
    type 'check'
    parameters(
      http: "http://#{new_resource.address}:#{new_resource.port}#{new_resource.http_location}",
      interval: '15s',
      timeout: '5s',
      notes: notes,
      service_id: "#{service_type}-#{new_resource.service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

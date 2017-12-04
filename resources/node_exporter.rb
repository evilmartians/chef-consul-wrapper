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
  tags(tags + [service_name] + %w(node-exporter prometheus))

  service_type = 'node-exporter'

  consul_definition "#{service_type}-#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  notes = "#{service_type}-#{service_name} should listen on #{address}:#{port}"

  consul_definition "#{service_type}-#{service_name}-port" do
    type 'check'
    parameters(
      tcp: "#{address}:#{port}",
      interval: '15s',
      timeout: '1s',
      notes: notes,
      service_id: "#{service_type}-#{service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end

  notes = "#{service_type}_#{service_name} should answer with metrics via http"
  consul_definition "#{service_type}-#{service_name}-http" do
    type 'check'
    parameters(
      http: "http://#{address}:#{port}#{http_location}",
      interval: '15s',
      timeout: '5s',
      notes: notes,
      service_id: "#{service_type}-#{service_name}",
    )
    notifies :reload, 'consul_service[consul]'
  end
end

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
property :tags, Array, default: node.chef_environment.split('_') + %w(node_exporter prometheus)

default_action :add

action :add do
  tags(tags + [service_name])

  service_type = 'node_exporter'

  directory '/var/lib/consul/checks' do
    recursive true
    owner 'consul'
    group 'consul'
  end

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
end

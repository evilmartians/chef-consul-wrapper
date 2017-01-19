#
# Cookbook Name:: consul_wrapper
# Resource:: elasticsearch
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Elasticsearchtribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Integer, default: 9200
property :tags, Array, default: node.chef_environment.split('_') + ['elasticsearch']

default_action :add

action :add do
  tags(tags + [service_name])

  service_type = 'elasticsearch'

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
      script: "/var/lib/consul/checks/#{service_type}_#{service_name}_process_check",
      interval: '15s',
      notes: "#{service_type.capitalize}_#{service_name.capitalize} should have process with cmd: org.elasticsearch.bootstrap.Elasticsearch",
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
      notes: "#{service_type.capitalize}_#{service_name.capitalize} should listen on #{address}:#{port}",
      service_id: "#{service_type}_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end

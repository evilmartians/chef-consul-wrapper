#
# Cookbook Name:: consul_wrapper
# Resource:: postgresql
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Elasticsearchtribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :port, Fixnum, default: 5432
property :tags, Array, default: node.chef_environment.split('_') + %w(postgresql db database)

default_action :add

action :add do
  service_type = 'postgresql'

  tags(tags + [service_name])

  directory '/var/lib/consul/checks' do
    recursive true
    owner 'consul'
    group 'consul'
  end

  template "/var/lib/consul/checks/#{service_type}_#{service_name}_accessibility_check" do
    source "#{service_type}_accessibility_check.erb"
    cookbook 'consul_wrapper'
    owner  'consul'
    group  'consul'
    mode   '0755'
  end

  sudo "consul_#{service_type}_accessibility_check" do
    user 'consul'
    runas 'postgres'
    commands ['/usr/bin/psql -p [0-9]* -U postgres -d postgres -A -t -c select 1']
    nopasswd true
  end

  consul_definition "#{service_type}_#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}_#{service_name}_accessibility_check" do
    type 'check'
    parameters(
      script: "/var/lib/consul/checks/#{service_type}_accessibility_check",
      interval: '30s',
      notes: 'PostgreSQL should serve queries',
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

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
property :port, Integer, default: 5432
property :tags, Array, default: []

default_action :add

action :add do
  service_type = 'postgresql'

  tags = new_resource.tags +
         new_resource.service_name.split(/[-_]/) +
         node.chef_environment.split(/[-_]/) +
         %w[postgresql db database]

  sudo "#{service_type}-check" do
    user 'consul'
    runas 'postgres'
    commands [
      '/usr/bin/psql -p [0-9]* -U postgres -d postgres -A -t -c select 1',
    ]
    nopasswd true
  end

  consul_definition "#{service_type}-#{new_resource.service_name}" do
    type 'service'
    parameters(
      tags: tags,
      address: new_resource.address,
      port: new_resource.port,
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{new_resource.service_name}-check" do
    type 'check'
    parameters(
      script: "/usr/bin/sudo -u postgres /usr/bin/psql -p #{new_resource.port} -U postgres -d postgres -A -t -c 'select 1' >/dev/null 2>&1",
      interval: '30s',
      notes: "#{service_type}-#{new_resource.service_name} should serve queries",
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

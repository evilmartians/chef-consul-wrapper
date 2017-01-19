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
property :port, Fixnum, default: 11_211
property :tags, Array, default: []
default_action :add

action :add do
  service_type = 'memcached'

  tags(tags + service_name.split(/[-_]/) + node.chef_environment.split(/[-_]/) + %w(memcached memcache))

  consul_definition "#{service_type}-#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{service_name}_process" do
    type 'check'
    parameters(
      script: "/bin/ps xau | /bin/grep '[m]emcached.* -l #{address}' | /bin/grep  -- '-p #{port}'",
      interval: '15s',
      notes: "#{service_type}-#{service_name} should have process with cmd: memcached #{address}:#{port}",
      service_id: "#{service_type}-#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{service_name}-port" do
    type 'check'
    parameters(
      tcp: "#{address}:#{port}",
      interval: '15s',
      timeout: '1s',
      notes: "#{service_type}-#{service_name} should listen on #{address}:#{port}",
      service_id: "#{service_type}-#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end

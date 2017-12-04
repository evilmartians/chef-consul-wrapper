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

  # rubocop:disable Style/TrailingCommaInArguments
  tags(
    tags +
    service_name.split(/[-_]/) +
    node.chef_environment.split(/[-_]/) +
    %w(memcached memcache)
  )
  # rubocop:enable Style/TrailingCommaInArguments

  consul_definition "#{service_type}-#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{service_name}_process" do
    type 'check'
    parameters(
      # rubocop:disable LineLength
      script: "/bin/ps xau | /bin/grep '[m]emcached.* -l #{address}' | /bin/grep  -- '-p #{port}'",
      notes: "#{service_type}-#{service_name} should have process with cmd: memcached #{address}:#{port}",
      # rubocop:enable LineLength
      interval: '15s',
      service_id: "#{service_type}-#{service_name}",
    )
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
end

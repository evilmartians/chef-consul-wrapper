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

  # rubocop:disable Style/TrailingCommaInArguments
  tags(
    tags +
    service_name.split(/[-_]/) +
    node.chef_environment.split(/[-_]/) +
    %w(postgresql db database)
  )
  # rubocop:enable Style/TrailingCommaInArguments

  sudo "#{service_type}-check" do
    user 'consul'
    runas 'postgres'
    commands [
      '/usr/bin/psql -p [0-9]* -U postgres -d postgres -A -t -c select 1',
    ]
    nopasswd true
  end

  consul_definition "#{service_type}-#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: port)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "#{service_type}-#{service_name}-check" do
    type 'check'
    parameters(
      # rubocop:disable LineLength
      script: "/usr/bin/sudo -u postgres /usr/bin/psql -p #{port} -U postgres -d postgres -A -t -c 'select 1' >/dev/null 2>&1",
      # rubocop:enable LineLength
      interval: '30s',
      notes: "#{service_type}-#{service_name} should serve queries",
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

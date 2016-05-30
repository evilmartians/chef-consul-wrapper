#
# Cookbook Name:: consul_wrapper
# Resource:: application
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

property :service_name, String, name_property: true
property :address, String, default: '127.0.0.1'
property :socket, [String, Fixnum, FalseClass], default: false
property :url, String, default: '/'
property :hostname, String, default: 'example.com'
property :appserver, String, default: 'unicorn'
property :lower_limit, Fixnum, default: 2
property :tags, Array, default: node.chef_environment.split('_') + ['rails']

default_action :add

action :add do
  tags(tags + [service_name])
  socket("/tmp/#{service_name}_rails.sock") unless socket

  directory '/var/lib/consul/checks' do
    recursive true
    owner 'consul'
    group 'consul'
  end

  unix = if socket.is_a?(Fixnum) || /\A\d+\z/.match(socket)
           false
         else
           true
         end

  template "/var/lib/consul/checks/app_#{service_name}_socket_check" do
    source 'rails_socket_check.erb'
    cookbook 'consul_wrapper'
    owner  'consul'
    group  'consul'
    mode   '0755'
    variables(
      unix: unix,
      socket: socket,
      address: address,
      url: url,
      hostname: hostname
    )
  end

  template "/var/lib/consul/checks/app_#{service_name}_workers_check" do
    source 'rails_workers_check.erb'
    cookbook 'consul_wrapper'
    owner  'consul'
    group  'consul'
    mode   '0755'
    variables(
      appserver: appserver,
      lower_limit: lower_limit
    )
  end

  consul_definition "application_#{service_name}" do
    type 'service'
    parameters(tags: tags, address: address, port: 80)
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app_#{service_name}_workers_check" do
    type 'check'
    parameters(
      script: "/var/lib/consul/checks/app_#{service_name}_workers_check",
      interval: '15s',
      notes: "#{service_name.capitalize} rails appserver should have workers running.",
      service_id: "application_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app_#{service_name}_socket_check" do
    type 'check'
    parameters(
      script: "/var/lib/consul/checks/app_#{service_name}_socket_check",
      interval: '15s',
      notes: "#{service_name.capitalize} rails should serve requests on its socket.",
      service_id: "application_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end

  consul_definition "app_#{service_name}_http_port_check" do
    type 'check'
    parameters(
      tcp: "#{address}:80",
      interval: '15s',
      timeout: '1s',
      notes: "NGINX should listen on #{address}:80",
      service_id: "application_#{service_name}"
    )
    notifies :reload, 'consul_service[consul]'
  end
end

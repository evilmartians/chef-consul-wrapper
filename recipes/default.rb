#
# Cookbook Name:: consul_wrapper
# Recipe:: default
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['consul_wrapper']['disable']
  private_interface_name = node['consul_wrapper']['private_interface']
  private_ip = '127.0.0.1'
  start_join = [private_ip]

  if node['network']['interfaces'].key?(private_interface_name)
    interface = node['network']['interfaces'][private_interface_name]
    interface_addresses = interface['addresses'].find do |_address, data|
      data['family'] == 'inet'
    end
    private_ip = interface_addresses.first

    start_join = [private_ip]
  end

  if !Chef::Config[:solo] and
     node['network']['interfaces'].key?(private_interface_name)
    consul_nodes = search(:node, node['consul_wrapper']['search_string'])

    start_join = [] unless consul_nodes.empty?

    consul_nodes.each do |item|
      next unless item['network']['interfaces'].key?(private_interface_name)
      interface = item['network']['interfaces'][private_interface_name]
      interface_addresses = interface['addresses'].find do |_address, data|
        data['family'] == 'inet'
      end
      start_join << interface_addresses.first
    end
  end

  node.default['consul']['config']['bind_addr'] = '0.0.0.0'
  if node['consul_wrapper']['listen_http_on_lan']
    node.default['consul']['config']['addresses']['http'] = private_ip
  end
  node.default['consul']['config']['start_join'] = start_join
  node.default['consul']['config']['advertise_addr'] = private_ip

  if node['consul']['version'].to_i >= 1
    node.default['consul']['config']['serf_lan'] = private_ip
  else
    node.default['consul']['config']['serf_lan_bind'] = private_ip
  end

  if node['platform_version'].to_f >= 16.04
    node.default['consul']['service_shell'] = '/bin/bash'
  end

  directory '/etc/consul' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    not_if { ::File.directory?('/etc/consul') }
  end

  if node['consul']['config']['verify_incoming'] or
     node['consul']['config']['verify_outgoing']
    %w[
      /etc/consul/ssl
      /etc/consul/ssl/CA
      /etc/consul/ssl/certs
      /etc/consul/ssl/private
    ].each do |dir|
      directory dir do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end
    end

    %w[ca_file cert_file key_file].each do |filename|
      file node['consul']['config'][filename] do
        owner 'root'
        group 'root'
        mode '0644'
        content data_bag_item(
          node['consul_wrapper']['secrets']['data_bag'],
          node['consul_wrapper']['secrets']['data_bag_item'],
        )[filename]
      end
    end
  end

  include_recipe 'consul_wrapper::server' if node['consul']['config']['server']
  include_recipe 'consul_wrapper::agent'

  consul_definition 'consul-http' do
    type 'service'
    parameters(
      tags: %w[consul consul-http],
      address: private_ip,
      port: 8500,
    )
    only_if do
      node['consul_wrapper']['listen_http_on_lan']
    end
    notifies :reload, 'consul_service[consul]'
  end

  node['consul_wrapper']['include_recipes'].each do |r|
    include_recipe "consul_wrapper::#{r}"
  end
end

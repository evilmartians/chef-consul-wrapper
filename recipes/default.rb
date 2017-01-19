#
# Cookbook Name:: consul_wrapper
# Recipe:: default
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['consul_wrapper']['disable']
  interface = node['consul_wrapper']['listen_interface']
  ip = '127.0.0.1'
  start_join = [ip]

  if node['network']['interfaces'].key?(interface)
    ip = node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
    start_join = [ip]

    unless Chef::Config[:solo]
      consul_nodes = search(:node, node['consul_wrapper']['search_string'])

      start_join = [] if consul_nodes.size > 0

      consul_nodes.each do |item|
        start_join << item['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first if item['network']['interfaces'].key?(interface)
      end
    end
  end

  node.set['consul']['config']['bind_addr']  = ip
  node.set['consul']['config']['start_join'] = start_join

  node.set['consul']['service_shell'] = '/bin/bash' if node['platform_version'].to_f >= 16.04

  directory '/etc/consul' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
    not_if { ::File.directory?('/etc/consul') }
  end

  if node['consul']['config']['verify_incoming'] || node['consul']['config']['verify_outgoing']
    %w(
      /etc/consul/ssl
      /etc/consul/ssl/CA
      /etc/consul/ssl/certs
      /etc/consul/ssl/private
    ).each do |dir|
      directory dir do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
      end
    end

    file node['consul']['config']['ca_file'] do
      owner 'root'
      group 'root'
      mode '0644'
      content Chef::EncryptedDataBagItem.load(node['consul_wrapper']['secrets']['data_bag'], node['consul_wrapper']['secrets']['data_bag_item'])['ca_file']
    end

    file node['consul']['config']['cert_file'] do
      owner 'root'
      group 'root'
      mode '0644'
      content Chef::EncryptedDataBagItem.load(node['consul_wrapper']['secrets']['data_bag'], node['consul_wrapper']['secrets']['data_bag_item'])['cert_file']
    end

    file node['consul']['config']['key_file'] do
      owner 'root'
      group 'root'
      mode '0644'
      content Chef::EncryptedDataBagItem.load(node['consul_wrapper']['secrets']['data_bag'], node['consul_wrapper']['secrets']['data_bag_item'])['key_file']
    end
  end

  include_recipe 'consul_wrapper::agent'
  include_recipe 'consul_wrapper::server' if node['consul']['config']['server']
end

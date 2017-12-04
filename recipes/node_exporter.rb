#
# Cookbook Name:: consul_wrapper
# Recipe:: node_exporter
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['consul_wrapper']['disable']
  private_interface_name = node['consul_wrapper']['private_interface']
  ip = '127.0.0.1'

  interface = node['network']['interfaces'][private_interface_name]
  interface_addresses = interface['addresses'].find do |_address, data|
    data['family'] == 'inet'
  end
  ip = interface_addresses.first

  consul_wrapper_node_exporter 'main' do
    address ip
  end
end

#
# Cookbook Name:: consul_wrapper
# Recipe:: node_exporter
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

unless node['consul_wrapper']['disable']
  interface = node['consul_wrapper']['private_interface']
  ip = '127.0.0.1'
  ip = node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first if node['network']['interfaces'].key?(interface)

  consul_wrapper_node_exporter 'main' do
    address ip
  end
end

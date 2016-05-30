#
# Cookbook Name:: consul_wrapper
# Recipe:: default
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

interface = node['consul_wrapper']['listen_interface']
ip = if node['network']['interfaces'].key?(interface)
       node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
     else
       '127.0.0.1'
     end

if node['network']['interfaces'].key?(interface)
  consul_nodes = search(:node, "role:consul_master AND chef_environment:#{node.chef_environment}")

  start_join = []

  consul_nodes.each do |item|
    start_join << item['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
  end
end

node.set[:consul][:config][:bind_addr]  = ip
node.set[:consul][:config][:start_join] = start_join

include_recipe 'consul_wrapper::agent'
include_recipe 'consul_wrapper::server' if node[:consul][:config][:server]

#
# Cookbook Name:: consul_wrapper
# Recipe:: default
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

interface = node['consul_wrapper']['listen_interface']
ip = '127.0.0.1'
start_join = [ip]

if node['network']['interfaces'].key?(interface)
  ip = node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
  start_join = [ip]

  unless Chef::Config[:solo]
    consul_nodes = search(:node, "role:consul_master AND chef_environment:#{node.chef_environment}")

    start_join = [] if consul_nodes.size > 0

    consul_nodes.each do |item|
      start_join << item['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first if item['network']['interfaces'].key?(interface)
    end
  end
end

node.set['consul']['config']['bind_addr']  = ip
node.set['consul']['config']['start_join'] = start_join

include_recipe 'consul_wrapper::agent'
include_recipe 'consul_wrapper::server' if node['consul']['config']['server']

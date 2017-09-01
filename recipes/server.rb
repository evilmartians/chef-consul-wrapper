#
# Cookbook Name:: consul_wrapper
# Recipe:: server
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

interface = node['consul_wrapper']['private_interface']
private_ip = if node['consul_wrapper']['listen_ip']
               node['consul_wrapper']['listen_ip']
             elsif node['network']['interfaces'].key?(interface)
               node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
             else
               '127.0.0.1'
             end

node.default['consul']['ui'] = true
node.default['consul']['config']['server'] = true
node.default['consul']['config']['verify_incoming'] = true
node.default['consul']['config']['verify_outgoing'] = true
node.default['consul']['config']['bind_addr'] = '0.0.0.0'
node.default['consul']['config']['serf_lan_bind'] = private_ip
node.default['consul']['config']['advertise_addr'] = private_ip

include_recipe 'consul::default'

directory '/var/lib/consul/checks' do
  recursive true
  owner 'consul'
  group 'consul'
end
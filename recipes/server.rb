#
# Cookbook Name:: consul_wrapper
# Recipe:: server
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

interface = node['consul_wrapper']['listen_interface']
ip = if node['consul_wrapper']['listen_ip']
       node['consul_wrapper']['listen_ip']
     elsif node['network']['interfaces'].key?(interface)
       node['network']['interfaces'][interface]['addresses'].find { |address, data| data['family'] == 'inet' }.first
     else
       '127.0.0.1'
     end

node.set['consul']['ui'] = true
node.default['consul']['config']['server'] = true
node.default['consul']['config']['verify_incoming'] = true
node.default['consul']['config']['verify_outgoing'] = true
node.default['consul']['config']['bind_addr'] = ip
node.default['consul']['config']['advertise_addr'] = ip
node.default['consul']['config']['advertise_addr_wan'] = ip

include_recipe 'consul::default'

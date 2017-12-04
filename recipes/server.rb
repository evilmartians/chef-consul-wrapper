#
# Cookbook Name:: consul_wrapper
# Recipe:: server
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

private_interface_name = node['consul_wrapper']['private_interface']
private_ip = if node['consul_wrapper']['listen_ip']
               node['consul_wrapper']['listen_ip']
             elsif node['network']['interfaces'].key?(private_interface_name)
               interface = node['network']['interfaces'][private_interface_name]
               interface_addrs = interface['addresses'].find do |_address, data|
                 data['family'] == 'inet'
               end
               interface_addrs.first
             else
               '127.0.0.1'
             end

if node['consul']['config']['start_join_wan'].is_a?(Array) and
   !node['consul']['config']['start_join_wan'].empty?
  public_interface_name = node['consul_wrapper']['public_interface']
  interface = node['network']['interfaces'][public_interface_name]
  interface_addrs = interface['addresses'].find do |_address, data|
    data['family'] == 'inet'
  end
  node.default['consul']['config']['advertise_addr_wan'] = interface_addrs.first

  firewall_rule 'consul_serf_wan' do
    port 8302
  end
end

node.default['consul']['ui'] = true
node.default['consul']['config']['server'] = true
node.default['consul']['config']['verify_incoming'] = true
node.default['consul']['config']['verify_outgoing'] = true
node.default['consul']['config']['bind_addr'] = '0.0.0.0'
node.default['consul']['config']['advertise_addr'] = private_ip

include_recipe 'consul::default'

directory '/var/lib/consul/checks' do
  recursive true
  owner 'consul'
  group 'consul'
end

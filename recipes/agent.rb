#
# Cookbook Name:: consul_wrapper
# Recipe:: agent
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'consul'

firewall_rule "consul_serf_lan_#{node['consul_wrapper']['private_interface']}" do
  protocol :tcp
  port 8301
  interface node['consul_wrapper']['private_interface']
end

firewall_rule 'consul_rpc_lo' do
  protocol :tcp
  port 8400
  interface 'lo'
end

['lo', node['consul_wrapper']['private_interface']].each do |interface_name|
  firewall_rule "consul_dns_udp_#{interface_name}" do
    protocol :udp
    port 8600
    interface interface_name
  end

  firewall_rule "consul_dns_tcp_#{interface_name}" do
    protocol :udp
    port 8600
    interface interface_name
  end

  firewall_rule "consul_http_#{interface_name}" do
    protocol :tcp
    port 8500
    interface interface_name
  end
end

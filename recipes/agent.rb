#
# Cookbook Name:: consul_wrapper
# Recipe:: agent
#
# Copyright 2017, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'consul'

# Allow serf_lan port on all interfaces by default
firewall_rule 'consul_serf_lan' do
  port 8301
  only_if { node['consul_wrapper']['enable_firewall'] }
end

#
# Cookbook Name:: consul_wrapper
# Recipe:: agent
#
# Copyright 2016, Evil Martians
#
# All rights reserved - Do Not Redistribute
#

node.set['consul']['ui'] = true

include_recipe 'consul'

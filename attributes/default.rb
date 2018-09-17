default['consul_wrapper']['public_interface']         = 'eth0'
default['consul_wrapper']['private_interface']        = 'eth1'
default['consul_wrapper']['disable']                  = false
default['consul_wrapper']['secrets']['data_bag']      = 'secrets'
default['consul_wrapper']['secrets']['data_bag_item'] = 'consul_certificates'
default['consul_wrapper']['include_recipes']          = []
default['consul_wrapper']['listen_http_on_lan']       = true
default['consul_wrapper']['enable_firewall']          = true

default['consul']['config']['server']              = false
default['consul']['config']['datacenter']          = 'SETMEPLEASE'
default['consul']['config']['data_dir']            = '/var/lib/consul/data'
default['consul']['config']['client_addr']         = '127.0.0.1'
default['consul']['config']['node_name']           = node['hostname']
default['consul']['config']['server_name']         = node['fqdn']
default['consul']['config']['enable_syslog']       = true
default['consul']['config']['syslog_facility']     = 'local5'
default['consul']['config']['log_level']           = 'DEBUG'
default['consul']['config']['ui']                  = true
default['consul']['config']['disable_remote_exec'] = true

default['consul_wrapper']['search_string'] =
  "role:consul_master AND chef_environment:#{node.chef_environment}"

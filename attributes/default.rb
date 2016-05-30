default['consul_wrapper']['listen_interface']  = 'eth1'

default['consul']['config']['server']          = false
default['consul']['config']['datacenter']      = 'SETMEPLEASE'
default['consul']['config']['data_dir']        = '/var/lib/consul/data'
default['consul']['config']['client_addr']     = '127.0.0.1'
default['consul']['config']['node_name']       = node[:hostname]
default['consul']['config']['server_name']     = node[:hostname]
default['consul']['config']['enable_syslog']   = true
default['consul']['config']['syslog_facility'] = 'local5'
default['consul']['config']['log_level']       = 'DEBUG'
default['consul']['config']['ui_dir']          = '/var/lib/consul/ui/current'

default['consul-cluster']['config']['bootstrap_expect'] = 1

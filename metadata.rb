name             'consul_wrapper'
maintainer       'Evil Martians'
maintainer_email 'surrender@evilmartians.com'
license          'All rights reserved'
description      'Installs/Configures consul'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.0'

depends 'consul'
depends 'firewall'

supports 'ubuntu', '= 16'

chef_version '>= 14'

source_url 'https://github.com/evilmartians/chef-consul-wrapper'
issues_url 'https://github.com/evilmartians/chef-consul-wrapper/issues'

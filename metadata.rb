name             'sensu_spec'
maintainer       'Fraser Scott'
maintainer_email 'fraser.scott@gmail.com'
license          'All rights reserved'
description      'Installs/Configures sensu_spec'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.11.0'

depends 'apt', '>= 2.6'
depends 'yum', '>= 3.0'
depends 'yum-epel', '>= 0.2'
depends 'sensu'

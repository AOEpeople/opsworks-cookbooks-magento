name             'magentostack'
maintainer       'Fabrizio Branca'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures magentostack'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "cron"
depends "newrelic"

supports "ubuntu"
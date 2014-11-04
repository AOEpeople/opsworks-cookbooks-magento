magentostack Cookbook
=====================

This cookbook is intended to be used with AWS OpsWorks

Configuration
-------------

- Configure custom repository URL: https://github.com/fbrnc/opsworks-cookbooks.git
- Layers:
  - Setup: 
    - mod_php5_apache2::php
    - magentostack::awscli
    - magentostack::configure_magento
    - magentostack::setup 
  - Configure:
    - magentostack::configure_magento
  - Deploy:
    - magentostack::configure_magento

License and Authors
-------------------
Authors: Fabrizio Branca

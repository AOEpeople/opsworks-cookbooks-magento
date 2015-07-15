# Magentostack Cookbook

This cookbook is intended to be used with AWS OpsWorks

## Configuration

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
    
## Additional ELBs    

```
{
  "additional-elbs": {
    "elbs": [
      "magento-production-opsworks2"
    ],
    "aws_secret_access_key": "...",
    "aws_access_key_id": "..."
  }
}
```

## License and Authors
Author: [Fabrizio Branca](https://twitter.com/fbrnc)

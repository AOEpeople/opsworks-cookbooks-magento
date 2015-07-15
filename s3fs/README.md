# S3FS OpsWorks Cookbook
[S3FS](https://github.com/s3fs-fuse/s3fs-fuse) is a FUSE (File System in User Space) based solution to
mount/unmount an Amazon S3 storage buckets and use system commands with S3 just like it was another hard disk.

## Original Version: https://github.com/netsrv-cookbooks/opsworks-cookbooks/tree/master/s3fs

## Changelog (Fabrizio Branca)

* Adapted for Ubuntu 14.04

## Known Limitations
A future version will address these:

* Allow other access is always used.
* Caching is always used and hard coded to use ephemeral0 disk.


## Configuration

Add this JSON configuration (to the stack or a custom cookbook)

```
{
    "s3fs": {
        "buckets": [{
            "name": "...",
            "access_key": "...",
            "secret_key": "..."
        }, {
        ...
        }]
    }
}
```

## Using IAM

You need to ensure that the IAM user has permissions to both the bucket and to list all buckets otherwise you will
get access denied errors.

This is a IAM permission policy that grants (too much) access to my-bucket and allows listing of all buckets.  In
the real world it is recommended that you restrict the actions that can be performed to only those needed.

    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [ "s3:*" ],
        "Resource": [
          "arn:aws:s3:::my-bucket*"
        ]
      },
      {
        "Effect":"Allow",
        "Action":"s3:ListAllMyBuckets",
        "Resource":"arn:aws:s3:::*"
      }]
    }
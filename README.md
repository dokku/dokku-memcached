# dokku memcached [![Build Status](https://img.shields.io/travis/dokku/dokku-memcached.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-memcached) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official memcached plugin for dokku. Currently defaults to installing [memcached 1.5.20](https://hub.docker.com/_/memcached/).

## Requirements

- dokku 0.12.x+
- docker 1.8.x

## Installation

```shell
# on 0.12.x+
sudo dokku plugin:install https://github.com/dokku/dokku-memcached.git memcached
```

## Commands

```
memcached:app-links <app>                          # list all memcached service links for a given app
memcached:backup <service> <bucket-name> [--use-iam] # creates a backup of the memcached service to an existing s3 bucket
memcached:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # sets up authentication for backups on the memcached service
memcached:backup-deauth <service>                  # removes backup authentication for the memcached service
memcached:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedules a backup of the memcached service
memcached:backup-schedule-cat <service>            # cat the contents of the configured backup cronfile for the service
memcached:backup-set-encryption <service> <passphrase> # sets encryption for all future backups of memcached service
memcached:backup-unschedule <service>              # unschedules the backup of the memcached service
memcached:backup-unset-encryption <service>        # unsets encryption for future backups of the memcached service
memcached:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
memcached:connect <service>                        # connect to the service via the memcached connection tool
memcached:create <service> [--create-flags...]     # create a memcached service
memcached:destroy <service> [-f|--force]           # delete the memcached service/data/container if there are no links left
memcached:enter <service>                          # enter or run a command in a running memcached service container
memcached:exists <service>                         # check if the memcached service exists
memcached:export <service>                         # export a dump of the memcached service database
memcached:expose <service> <ports...>              # expose a memcached service on custom port if provided (random port otherwise)
memcached:import <service>                         # import a dump into the memcached service database
memcached:info <service> [--single-info-flag]      # print the connection information
memcached:link <service> <app> [--link-flags...]   # link the memcached service to the app
memcached:linked <service> <app>                   # check if the memcached service is linked to an app
memcached:links <service>                          # list all apps linked to the memcached service
memcached:list                                     # list all memcached services
memcached:logs <service> [-t|--tail]               # print the most recent log(s) for this service
memcached:promote <service> <app>                  # promote service <service> as MEMCACHED_URL in <app>
memcached:restart <service>                        # graceful shutdown and restart of the memcached service container
memcached:start <service>                          # start a previously stopped memcached service
memcached:stop <service>                           # stop a running memcached service
memcached:unexpose <service>                       # unexpose a previously exposed memcached service
memcached:unlink <service> <app>                   # unlink the memcached service from the app
memcached:upgrade <service> [--upgrade-flags...]   # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to memcached:help. Please consult the `memcached:help` command for any undocumented commands.

### Basic Usage
### list all memcached services

```shell
# usage
dokku memcached:list 
```

examples:

List all services:

```shell
dokku memcached:list
```
### create a memcached service

```shell
# usage
dokku memcached:create <service> [--create-flags...]
```

examples:

Create a memcached service named lolipop:

```shell
dokku memcached:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the ${plugin_image} image. :

```shell
export MEMCACHED_IMAGE="${PLUGIN_IMAGE}"
export MEMCACHED_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku memcached:create lolipop
```

You can also specify custom environment variables to start the memcached service in semi-colon separated form. :

```shell
export MEMCACHED_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku memcached:create lolipop
```
### print the connection information

```shell
# usage
dokku memcached:info <service> [--single-info-flag]
```

examples:

Get connection information as follows:

```shell
dokku memcached:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku memcached:info lolipop --config-dir
dokku memcached:info lolipop --data-dir
dokku memcached:info lolipop --dsn
dokku memcached:info lolipop --exposed-ports
dokku memcached:info lolipop --id
dokku memcached:info lolipop --internal-ip
dokku memcached:info lolipop --links
dokku memcached:info lolipop --service-root
dokku memcached:info lolipop --status
dokku memcached:info lolipop --version
```
### print the most recent log(s) for this service

```shell
# usage
dokku memcached:logs <service> [-t|--tail]
```

examples:

You can tail logs for a particular service:

```shell
dokku memcached:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku memcached:logs lolipop --tail
```
### link the memcached service to the app

```shell
# usage
dokku memcached:link <service> <app> [--link-flags...]
```

examples:

A memcached service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. :

> NOTE: this will restart your app

```shell
dokku memcached:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_MEMCACHED_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_MEMCACHED_LOLIPOP_PORT=tcp://172.17.0.1:11211
DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP=tcp://172.17.0.1:11211
DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_PROTO=tcp
DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_PORT=11211
DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
MEMCACHED_URL=memcached://lolipop:SOME_PASSWORD@dokku-memcached-lolipop:11211/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku memcached:link other_service playground
```

It is possible to change the protocol for memcached_url by setting the environment variable memcached_database_scheme on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. :

```shell
dokku config:set playground MEMCACHED_DATABASE_SCHEME=memcached2
dokku memcached:link lolipop playground
```

This will cause memcached_url to be set as:

```
memcached2://lolipop:SOME_PASSWORD@dokku-memcached-lolipop:11211/lolipop
```
### unlink the memcached service from the app

```shell
# usage
dokku memcached:unlink <service> <app>
```

examples:

You can unlink a memcached service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku memcached:unlink lolipop playground
```
### delete the memcached service/data/container if there are no links left

```shell
# usage
dokku memcached:destroy <service> [-f|--force]
```

examples:

Destroy the service, it's data, and the running container:

```shell
dokku memcached:destroy lolipop
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the memcached connection tool

```shell
# usage
dokku memcached:connect <service>
```

examples:

Connect to the service via the memcached connection tool:

```shell
dokku memcached:connect lolipop
```
### enter or run a command in a running memcached service container

```shell
# usage
dokku memcached:enter <service>
```

examples:

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. :

```shell
dokku memcached:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. :

```shell
dokku memcached:enter lolipop touch /tmp/test
```
### expose a memcached service on custom port if provided (random port otherwise)

```shell
# usage
dokku memcached:expose <service> <ports...>
```

examples:

Expose the service on the service's normal ports, allowing access to it from the public interface (0. 0. 0. 0):

```shell
dokku memcached:expose lolipop ${PLUGIN_DATASTORE_PORTS[@]}
```
### unexpose a previously exposed memcached service

```shell
# usage
dokku memcached:unexpose <service>
```

examples:

Unexpose the service, removing access to it from the public interface (0. 0. 0. 0):

```shell
dokku memcached:unexpose lolipop
```
### promote service <service> as MEMCACHED_URL in <app>

```shell
# usage
dokku memcached:promote <service> <app>
```

examples:

If you have a memcached service linked to an app and try to link another memcached service another link environment variable will be generated automatically:

```
DOKKU_MEMCACHED_BLUE_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku memcached:promote other_service playground
```

This will replace memcached_url with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
MEMCACHED_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
DOKKU_MEMCACHED_BLUE_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
DOKKU_MEMCACHED_SILVER_URL=memcached://lolipop:SOME_PASSWORD@dokku-memcached-lolipop:11211/lolipop
```
### graceful shutdown and restart of the memcached service container

```shell
# usage
dokku memcached:restart <service>
```

examples:

Restart the service:

```shell
dokku memcached:restart lolipop
```
### start a previously stopped memcached service

```shell
# usage
dokku memcached:start <service>
```

examples:

Start the service:

```shell
dokku memcached:start lolipop
```
### stop a running memcached service

```shell
# usage
dokku memcached:stop <service>
```

examples:

Stop the service and the running container:

```shell
dokku memcached:stop lolipop
```
### upgrade service <service> to the specified versions

```shell
# usage
dokku memcached:upgrade <service> [--upgrade-flags...]
```

examples:

You can upgrade an existing service to a new image or image-version:

```shell
dokku memcached:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all memcached service links for a given app

```shell
# usage
dokku memcached:app-links <app>
```

examples:

List all memcached services that are linked to the 'playground' app. :

```shell
dokku memcached:app-links playground
```
### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku memcached:clone <service> <new-service> [--clone-flags...]
```

examples:

You can clone an existing service to a new one:

```shell
dokku memcached:clone lolipop lolipop-2
```
### check if the memcached service exists

```shell
# usage
dokku memcached:exists <service>
```

examples:

Here we check if the lolipop memcached service exists. :

```shell
dokku memcached:exists lolipop
```
### check if the memcached service is linked to an app

```shell
# usage
dokku memcached:linked <service> <app>
```

examples:

Here we check if the lolipop memcached service is linked to the 'playground' app. :

```shell
dokku memcached:linked lolipop playground
```
### list all apps linked to the memcached service

```shell
# usage
dokku memcached:links <service>
```

examples:

List all apps linked to the 'lolipop' memcached service. :

```shell
dokku memcached:links lolipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the memcached service database

```shell
# usage
dokku memcached:import <service>
```

examples:

Import a datastore dump:

```shell
dokku memcached:import lolipop < database.dump
```
### export a dump of the memcached service database

```shell
# usage
dokku memcached:export <service>
```

examples:

By default, datastore output is exported to stdout:

```shell
dokku memcached:export lolipop
```

You can redirect this output to a file:

```shell
dokku memcached:export lolipop > lolipop.dump
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### sets up authentication for backups on the memcached service

```shell
# usage
dokku memcached:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

examples:

Setup s3 backup authentication:

```shell
dokku memcached:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku memcached:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku memcached:backup-auth lolipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku memcached:backup-auth lolipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```
### removes backup authentication for the memcached service

```shell
# usage
dokku memcached:backup-deauth <service>
```

examples:

Remove s3 authentication:

```shell
dokku memcached:backup-deauth lolipop
```
### creates a backup of the memcached service to an existing s3 bucket

```shell
# usage
dokku memcached:backup <service> <bucket-name> [--use-iam]
```

examples:

Backup the 'lolipop' service to the 'my-s3-bucket' bucket on aws:

```shell
dokku memcached:backup lolipop my-s3-bucket --use-iam
```
### sets encryption for all future backups of memcached service

```shell
# usage
dokku memcached:backup-set-encryption <service> <passphrase>
```

examples:

Set a gpg passphrase for backups:

```shell
dokku memcached:backup-set-encryption lolipop
```
### unsets encryption for future backups of the memcached service

```shell
# usage
dokku memcached:backup-unset-encryption <service>
```

examples:

Unset a gpg encryption key for backups:

```shell
dokku memcached:backup-unset-encryption lolipop
```
### schedules a backup of the memcached service

```shell
# usage
dokku memcached:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

examples:

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku memcached:backup-schedule lolipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku memcached:backup-schedule lolipop "0 3 * * *" my-s3-bucket --use-iam
```
### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku memcached:backup-schedule-cat <service>
```

examples:

Cat the contents of the configured backup cronfile for the service:

```shell
dokku memcached:backup-schedule-cat lolipop
```
### unschedules the backup of the memcached service

```shell
# usage
dokku memcached:backup-unschedule <service>
```

examples:

Remove the scheduled backup from cron:

```shell
dokku memcached:backup-unschedule lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MEMCACHED_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.
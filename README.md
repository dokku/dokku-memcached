# dokku memcached [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-memcached/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-memcached/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official memcached plugin for dokku. Currently defaults to installing [memcached 1.6.18](https://hub.docker.com/_/memcached/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-memcached.git memcached
```

## Commands

```
memcached:app-links <app>                          # list all memcached service links for a given app
memcached:connect <service>                        # connect to the service via the memcached connection tool
memcached:create <service> [--create-flags...]     # create a memcached service
memcached:destroy <service> [-f|--force]           # delete the memcached service/data/container if there are no links left
memcached:enter <service>                          # enter or run a command in a running memcached service container
memcached:exists <service>                         # check if the memcached service exists
memcached:expose <service> <ports...>              # expose a memcached service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
memcached:info <service> [--single-info-flag]      # print the service information
memcached:link <service> <app> [--link-flags...]   # link the memcached service to the app
memcached:linked <service> <app>                   # check if the memcached service is linked to an app
memcached:links <service>                          # list all apps linked to the memcached service
memcached:list                                     # list all memcached services
memcached:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
memcached:pause <service>                          # pause a running memcached service
memcached:promote <service> <app>                  # promote service <service> as MEMCACHED_URL in <app>
memcached:restart <service>                        # graceful shutdown and restart of the memcached service container
memcached:start <service>                          # start a previously stopped memcached service
memcached:stop <service>                           # stop a running memcached service
memcached:unexpose <service>                       # unexpose a previously exposed memcached service
memcached:unlink <service> <app>                   # unlink the memcached service from the app
memcached:upgrade <service> [--upgrade-flags...]   # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to memcached:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `memcached:help` command for any undocumented commands.

### Basic Usage

### create a memcached service

```shell
# usage
dokku memcached:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password
- `-s|--shm-size SHM_SIZE`: override shared memory size for memcached docker container

Create a memcached service named lollipop:

```shell
dokku memcached:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the memcached image.

```shell
export MEMCACHED_IMAGE="memcached"
export MEMCACHED_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku memcached:create lollipop
```

You can also specify custom environment variables to start the memcached service in semi-colon separated form.

```shell
export MEMCACHED_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku memcached:create lollipop
```

### print the service information

```shell
# usage
dokku memcached:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku memcached:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku memcached:info lollipop --config-dir
dokku memcached:info lollipop --data-dir
dokku memcached:info lollipop --dsn
dokku memcached:info lollipop --exposed-ports
dokku memcached:info lollipop --id
dokku memcached:info lollipop --internal-ip
dokku memcached:info lollipop --links
dokku memcached:info lollipop --service-root
dokku memcached:info lollipop --status
dokku memcached:info lollipop --version
```

### list all memcached services

```shell
# usage
dokku memcached:list 
```

List all services:

```shell
dokku memcached:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku memcached:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku memcached:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku memcached:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku memcached:logs lollipop --tail 5
```

### link the memcached service to the app

```shell
# usage
dokku memcached:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A memcached service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku memcached:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_MEMCACHED_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_MEMCACHED_LOLLIPOP_PORT=tcp://172.17.0.1:11211
DOKKU_MEMCACHED_LOLLIPOP_PORT_11211_TCP=tcp://172.17.0.1:11211
DOKKU_MEMCACHED_LOLLIPOP_PORT_11211_TCP_PROTO=tcp
DOKKU_MEMCACHED_LOLLIPOP_PORT_11211_TCP_PORT=11211
DOKKU_MEMCACHED_LOLLIPOP_PORT_11211_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
MEMCACHED_URL=memcached://dokku-memcached-lollipop:11211
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku memcached:link other_service playground
```

It is possible to change the protocol for `MEMCACHED_URL` by setting the environment variable `MEMCACHED_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground MEMCACHED_DATABASE_SCHEME=memcached2
dokku memcached:link lollipop playground
```

This will cause `MEMCACHED_URL` to be set as:

```
memcached2://dokku-memcached-lollipop:11211
```

### unlink the memcached service from the app

```shell
# usage
dokku memcached:unlink <service> <app>
```

You can unlink a memcached service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku memcached:unlink lollipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the memcached connection tool

```shell
# usage
dokku memcached:connect <service>
```

Connect to the service via the memcached connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku memcached:connect lollipop
```

### enter or run a command in a running memcached service container

```shell
# usage
dokku memcached:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku memcached:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku memcached:enter lollipop touch /tmp/test
```

### expose a memcached service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku memcached:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku memcached:expose lollipop 11211
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku memcached:expose lollipop 127.0.0.1:11211
```

### unexpose a previously exposed memcached service

```shell
# usage
dokku memcached:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku memcached:unexpose lollipop
```

### promote service <service> as MEMCACHED_URL in <app>

```shell
# usage
dokku memcached:promote <service> <app>
```

If you have a memcached service linked to an app and try to link another memcached service another link environment variable will be generated automatically:

```
DOKKU_MEMCACHED_BLUE_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku memcached:promote other_service playground
```

This will replace `MEMCACHED_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
MEMCACHED_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
DOKKU_MEMCACHED_BLUE_URL=memcached://other_service:ANOTHER_PASSWORD@dokku-memcached-other-service:11211/other_service
DOKKU_MEMCACHED_SILVER_URL=memcached://lollipop:SOME_PASSWORD@dokku-memcached-lollipop:11211/lollipop
```

### start a previously stopped memcached service

```shell
# usage
dokku memcached:start <service>
```

Start the service:

```shell
dokku memcached:start lollipop
```

### stop a running memcached service

```shell
# usage
dokku memcached:stop <service>
```

Stop the service and removes the running container:

```shell
dokku memcached:stop lollipop
```

### pause a running memcached service

```shell
# usage
dokku memcached:pause <service>
```

Pause the running container for the service:

```shell
dokku memcached:pause lollipop
```

### graceful shutdown and restart of the memcached service container

```shell
# usage
dokku memcached:restart <service>
```

Restart the service:

```shell
dokku memcached:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku memcached:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart
- `-s|--shm-size SHM_SIZE`: override shared memory size for memcached docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku memcached:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all memcached service links for a given app

```shell
# usage
dokku memcached:app-links <app>
```

List all memcached services that are linked to the `playground` app.

```shell
dokku memcached:app-links playground
```

### check if the memcached service exists

```shell
# usage
dokku memcached:exists <service>
```

Here we check if the lollipop memcached service exists.

```shell
dokku memcached:exists lollipop
```

### check if the memcached service is linked to an app

```shell
# usage
dokku memcached:linked <service> <app>
```

Here we check if the lollipop memcached service is linked to the `playground` app.

```shell
dokku memcached:linked lollipop playground
```

### list all apps linked to the memcached service

```shell
# usage
dokku memcached:links <service>
```

List all apps linked to the `lollipop` memcached service.

```shell
dokku memcached:links lollipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `MEMCACHED_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.

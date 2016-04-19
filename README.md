# dokku memcached (beta) [![Build Status](https://img.shields.io/travis/dokku/dokku-memcached.svg?branch=master "Build Status")](https://travis-ci.org/dokku/dokku-memcached) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official memcached plugin for dokku. Currently defaults to installing [memcached 1.4.25](https://hub.docker.com/_/memcached/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-memcached.git memcached
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/dokku/dokku-memcached.git memcached
```

## commands

```
memcached:connect <name>           Connect via telnet to a memcached service
memcached:create <name>            Create a memcached service with environment variables
memcached:destroy <name>           Delete the service and stop its container if there are no links left
memcached:expose <name> [port]     Expose a memcached service on custom port if provided (random port otherwise)
memcached:info <name>              Print the connection information
memcached:link <name> <app>        Link the memcached service to the app
memcached:list                     List all memcached services
memcached:logs <name> [-t]         Print the most recent log(s) for this service
memcached:promote <name> <app>     Promote service <name> as MEMCACHED_URL in <app>
memcached:restart <name>           Graceful shutdown and restart of the memcached service container
memcached:start <name>             Start a previously stopped memcached service
memcached:stop <name>              Stop a running memcached service
memcached:unexpose <name>          Unexpose a previously exposed memcached service
memcached:unlink <name> <app>      Unlink the memcached service from the app
```

## usage

```shell
# create a memcached service named lolipop
dokku memcached:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official memcached image
export MEMCACHED_IMAGE="memcached"
export MEMCACHED_IMAGE_VERSION="1.4"

# you can also specify custom environment
# variables to start the memcached service
# in semi-colon separated forma
export MEMCACHED_CUSTOM_ENV="USER=alpha;HOST=beta"

# create a memcached service
dokku memcached:create lolipop

# get connection information as follows
dokku memcached:info lolipop

# a memcached service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku memcached:link lolipop playground

# the following environment variables will be set automatically by docker (not
# on the app itself, so they won’t be listed when calling dokku config)
#
#   DOKKU_MEMCACHED_LOLIPOP_NAME=/lolipop/DATABASE
#   DOKKU_MEMCACHED_LOLIPOP_PORT=tcp://172.17.0.1:11211
#   DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP=tcp://172.17.0.1:11211
#   DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_PROTO=tcp
#   DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_PORT=11211
#   DOKKU_MEMCACHED_LOLIPOP_PORT_11211_TCP_ADDR=172.17.0.1
#
# and the following will be set on the linked application by default
#
#   MEMCACHED_URL=memcached://dokku-memcached-lolipop:11211
#
# NOTE: the host exposed here only works internally in docker containers. If
# you want your container to be reachable from outside, you should use `expose`.

# another service can be linked to your app
dokku memcached:link other_service playground

# since MEMCACHED_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-other-service:11211

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku memcached:promote other_service playground

# this will replace MEMCACHED_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   MEMCACHED_URL=memcached://dokku-memcached-other-service:11211
#   DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-other-service:11211
#   DOKKU_MEMCACHED_SILVER_URL=memcached://dokku-memcached-lolipop:11211

# you can also unlink a memcached service
# NOTE: this will restart your app and unset related environment variables
dokku memcached:unlink lolipop playground

# you can tail logs for a particular service
dokku memcached:logs lolipop
dokku memcached:logs lolipop -t # to tail

# finally, you can destroy the container
dokku memcached:destroy lolipop
```

## Changing database adapter

It's possible to change the protocol for MEMCACHED_URL by setting
the environment variable MEMCACHED_DATABASE_SCHEME on the app:

```
dokku config:set playground MEMCACHED_DATABASE_SCHEME=memcached2
dokku memcached:link lolipop playground
```

Will cause MEMCACHED_URL to be set as
memcached2://dokku-memcached-lolipop:11211

CAUTION: Changing MEMCACHED_DATABASE_SCHEME after linking will cause dokku to
believe the memcached is not linked when attempting to use `dokku memcached:unlink`
or `dokku memcached:promote`.
You should be able to fix this by

- Changing MEMCACHED_URL manually to the new value.

OR

- Set MEMCACHED_DATABASE_SCHEME back to its original setting
- Unlink the service
- Change MEMCACHED_DATABASE_SCHEME to the desired setting
- Relink the service

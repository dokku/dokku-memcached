# dokku memcached (beta)

Official memcached plugin for dokku. Currently installs memcached 1.4.24.

## requirements

- dokku 0.3.25+
- docker 1.6.x

## installation

```
cd /var/lib/dokku/plugins
git clone https://github.com/dokku/dokku-memcached.git memcached
dokku plugins-install-dependencies
dokku plugins-install
```

## commands

```
memcached:alias <name> <alias>     Set an alias for the docker link
memcached:clone <name> <new-name>  NOT IMPLEMENTED
memcached:connect <name>           Connect via telnet to a memcached service
memcached:create <name>            Create a memcached service
memcached:destroy <name>           Delete the service and stop its container if there are no links left
memcached:export <name>            NOT IMPLEMENTED
memcached:expose <name> <port>     NOT IMPLEMENTED
memcached:import <name> <file>     NOT IMPLEMENTED
memcached:info <name>              Print the connection information
memcached:link <name> <app>        Link the memcached service to the app
memcached:list                     List all memcached services
memcached:logs <name> [-t]         Print the most recent log(s) for this service
memcached:restart <name>           Graceful shutdown and restart of the service container
memcached:unexpose <name> <port>   NOT IMPLEMENTED
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
dokku memcached:create lolipop

# get connection information as follows
dokku memcached:info lolipop

# lets assume the ip of our memcached service is 172.17.0.1

# a memcached service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku memcached:link lolipop playground

# the above will expose the following environment variables
#
#   MEMCACHED_URL=memcached://172.17.0.1:11211
#   MEMCACHED_NAME=/playground/DATABASE
#   MEMCACHED_PORT=tcp://172.17.0.1:11211
#   MEMCACHED_PORT_11211_TCP=tcp://172.17.0.1:11211
#   MEMCACHED_PORT_11211_TCP_PROTO=tcp
#   MEMCACHED_PORT_11211_TCP_PORT=11211
#   MEMCACHED_PORT_11211_TCP_ADDR=172.17.0.1

# you can customize the environment
# variables through a custom docker link alias
dokku memcached:alias lolipop MEMCACHED_DATABASE

# you can also unlink a memcached service
# NOTE: this will restart your app
dokku memcached:unlink lolipop playground

# you can tail logs for a particular service
dokku memcached:logs lolipop
dokku memcached:logs lolipop -t # to tail

# finally, you can destroy the container
dokku memcached:destroy playground
```

## todo

- implement memcached:clone
- implement memcached:expose
- implement memcached:import

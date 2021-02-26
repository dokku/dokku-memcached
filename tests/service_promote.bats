#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  dokku apps:create my-app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my-app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my-app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  dokku --force apps:destroy my-app
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my-app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  assert_contains "${lines[*]}" "already promoted as MEMCACHED_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes MEMCACHED_URL" {
  dokku config:set my-app "MEMCACHED_URL=memcached://host:11211" "DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-l:11211"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  url=$(dokku config:get my-app MEMCACHED_URL)
  assert_equal "$url" "memcached://dokku-memcached-l:11211"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  dokku config:set my-app "MEMCACHED_URL=memcached://host:11211" "DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-l:11211"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  run dokku config my-app
  assert_contains "${lines[*]}" "DOKKU_MEMCACHED_"
}
@test "($PLUGIN_COMMAND_PREFIX:promote) uses MEMCACHED_DATABASE_SCHEME variable" {
  dokku config:set my-app "MEMCACHED_DATABASE_SCHEME=memcached2" "MEMCACHED_URL=memcached://host:11211/db" "DOKKU_MEMCACHED_BLUE_URL=memcached2://dokku-memcached-l:11211"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my-app
  url=$(dokku config:get my-app MEMCACHED_URL)
  assert_contains "$url" "memcached2://dokku-memcached-l:11211"
}

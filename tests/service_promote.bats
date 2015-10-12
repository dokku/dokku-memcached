#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
  dokku apps:create my_app >&2
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
  rm "$DOKKU_ROOT/my_app" -rf
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a name for the service"
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
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  assert_contains "${lines[*]}" "already promoted as MEMCACHED_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes MEMCACHED_URL" {
  dokku config:set my_app "MEMCACHED_URL=memcached://host:11211" "DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-l:11211"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app MEMCACHED_URL)
  assert_equal "$url" "memcached://dokku-memcached-l:11211"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  dokku config:set my_app "MEMCACHED_URL=memcached://host:11211" "DOKKU_MEMCACHED_BLUE_URL=memcached://dokku-memcached-l:11211"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  run dokku config my_app
  assert_contains "${lines[*]}" "DOKKU_MEMCACHED_"
}

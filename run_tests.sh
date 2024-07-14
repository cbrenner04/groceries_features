#!/bin/bash

# override the number of parallels by setting PARALLELS. otherwise, defaults to 5
: ${PARALLELS:=5}

# sign in only once, before all tests start
ruby spec/scripts/sign_in_to_results.rb
# run tests
# TODO: fix SITEPRISM_DSL_VALIDATION_DISABLED (just remove the env var and fix errors)
SITEPRISM_DSL_VALIDATION_DISABLED=true PARALLELS=$PARALLELS bundle exec parallel_rspec spec/ -n $PARALLELS --serialize-stdout --combine-stderr --group-by runtime --runtime-log spec/tmp/parallel_runtime_rspec.log
# sign out only once, after all tests are finished
ruby spec/scripts/sign_out_of_results.rb
# clean up the database only once, after all tests are finished
ruby spec/scripts/clean_database.rb

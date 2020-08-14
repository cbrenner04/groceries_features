#!/bin/bash

# override the number of parallels by setting PARALLELS. otherwise, defaults to 5
: ${PARALLELS:=5}

# sign in only once, before all tests start
ruby spec/sign_in_to_results.rb
# run tests
PARALLELS=$PARALLELS bundle exec parallel_rspec spec/ -n $PARALLELS --serialize-stdout --combine-stderr --group-by runtime
# sign out only once, after all tests are finished
ruby spec/sign_out_of_results.rb
# clean up the database only once, after all tests are finished
ruby spec/clean_database.rb

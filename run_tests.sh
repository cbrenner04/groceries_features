#!/bin/bash

ruby spec/sign_in_to_results.rb
# 4 parallels is less flaky than 6 with no noticeable difference in speed
# this is likely due to the retrying logic having to rerun more tests at 6 parrallel
bundle exec parallel_rspec spec/ -n 4 --serialize-stdout --combine-stderr --group-by runtime
ruby spec/sign_out_of_results.rb
ruby spec/clean_database.rb

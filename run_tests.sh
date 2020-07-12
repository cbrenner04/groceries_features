#!/bin/bash

ruby spec/sign_in_to_results.rb
# parallel count is best at 4 atm. 5 is ok but not any faster (probably due to failures). 6 is slower (definitely due to failures)
bundle exec parallel_rspec spec/ -n 4 --serialize-stdout --combine-stderr
ruby spec/sign_out_of_results.rb
ruby spec/clean_database.rb

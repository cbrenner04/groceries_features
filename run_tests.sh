#!/bin/bash

ruby spec/sign_in_to_results.rb
bundle exec parallel_rspec spec/ -n 7 --serialize-stdout --combine-stderr --group-by runtime
ruby spec/sign_out_of_results.rb
ruby spec/clean_database.rb

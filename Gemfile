# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "better_html"
gem "capybara"
gem "mail", ">= 2.8.0.rc1" # https://github.com/mikel/mail/pull/1472
gem "mocha"
gem "net-http" # Ruby 2.7 stdlib's net/http loads net/protocol relatively, which loads both the stdlib and gem version
gem "pg"
gem "pry-byebug"
gem "puma"
if defined?(@rails_gem_requirement) && @rails_gem_requirement
  # causes Dependabot to ignore the next line and update the next gem "rails"
  rails = "rails"
  gem rails, @rails_gem_requirement
else
  gem "rails"
end
gem "rubocop", "1.36.0"
gem "rubocop-shopify"
gem "selenium-webdriver"
gem "sprockets-rails"
gem "sqlite3"
gem "webdrivers", require: false
gem "yard"

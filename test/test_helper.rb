ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Hyperstack checks `defined? Rails::Server` to decide if it's running in server
# context. That's false under `bin/rails test`, so tables never get created and
# send_data falls back to an HTTP POST instead of broadcasting via ActionCable.
# Override it here so the test Puma server behaves like a real server.
module Hyperstack
  def self.on_server?
    true
  end
end
Hyperstack::Connection.build_tables if Hyperstack::Connection.build_tables?

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

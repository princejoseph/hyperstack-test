Hyperstack.import 'hyperstack/hotloader', client_only: true if Rails.env.development?

# Hyperstack components are Opal/client-side code compiled by Sprockets.
# Remove app/hyperstack from Rails' server-side eager load paths to prevent
# load-order errors (e.g. greetings.rb loads before hyper_component.rb).
Rails.application.config.eager_load_paths.reject! { |p| p.to_s.include?('/hyperstack') }

# server_side_auto_require will patch the ActiveSupport Dependencies module
# so that you can define classes and modules with files in both the
# app/hyperstack/xxx and app/xxx directories.  For example you can split
# a Todo model into server and client related definitions and place this
# in `app/hyperstack/models/todo.rb`, and place any server only definitions in
# `app/models/todo.rb`.

require "hyperstack/server_side_auto_require.rb"

# set the component base class

Hyperstack.component_base_class = 'HyperComponent' # i.e. 'ApplicationComponent'

# prerendering is default :off, you should wait until your
# application is relatively well debugged before turning on.

Hyperstack.prerendering = :off # or :on

# add this line if you need jQuery AND ARE NOT USING WEBPACK
# Hyperstack.import 'hyperstack/component/jquery', client_only: true

# change definition of on_error to control how errors such as validation
# exceptions are reported on the server
module Hyperstack
  def self.on_error(operation, err, params, formatted_error_message)
    ::Rails.logger.debug(
      "#{formatted_error_message}\n\n" +
      Pastel.new.red(
        'To further investigate you may want to add a debugging '\
        'breakpoint to the on_error method in config/initializers/hyperstack.rb'
      )
    )
  end
end if Rails.env.development?

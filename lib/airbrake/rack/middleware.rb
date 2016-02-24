module Airbrake
  module Rack
    ##
    # Build middleware for the default notifier.
    Middleware = MiddlewareBuilder.new(:default).build_middleware

    ##
    # Airbrake Rack middleware for Rails and Sinatra applications (or any other
    # Rack-compliant app). Any errors raised by the upstream application will be
    # delivered to Airbrake and re-raised.
    #
    # The middleware automatically sends information about the framework that
    # uses it (name and version).
    class Middleware
      ##
      # Builds a new middleware that reports exceptions using +notifier_name+
      # notifier. Useful if you want to report exceptions from Rails engines
      # (or different apps) separately, to different Airbrake dashboards.
      #
      # @example
      #   require 'sinatra/base'
      #
      #   class App1 < Sinatra::Base
      #     get('/') { 1/0 }
      #   end
      #   Airbrake.configure(App1) do |c|
      #     c.project_id = 1111
      #     c.project_key = '1111'
      #   end
      #
      #   class App2 < Sinatra::Base
      #     get('/') { 1/0 }
      #   end
      #   Airbrake.configure(App2) do |c|
      #     c.project_id = 2222
      #     c.project_key = '2222'
      #   end
      #
      #   map '/app1' do
      #     use Airbrake::Rack::Middleware.for(App1)
      #     run App1
      #   end
      #
      #   map '/app2' do
      #     use Airbrake::Rack::Middleware.for(App2)
      #     run App2
      #   end
      #
      # @param [String] notifier_name the name of the notifier
      # @return [Class] the middleware class specifically crafted for certain
      #   Airbrake notifier
      def self.for(notifier_name)
        MiddlewareBuilder.new(notifier_name).build_middleware
      end
    end
  end
end

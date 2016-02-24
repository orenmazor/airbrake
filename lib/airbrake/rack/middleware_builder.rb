module Airbrake
  module Rack
    ##
    # Dynamically builds a new anonymous class that serves as a Rack middleware.
    # Instances of this class need to know name of the Airbrake notifier that
    # should be used to report Rack exceptions.
    class MiddlewareBuilder
      ##
      # Helper methods for building an Airbrake Rack middleware. These methods
      # should be used for every middleware.
      module MiddlewareMethods
        def initialize(app)
          @app = app
        end

        ##
        # Rescues any exceptions, sends them to Airbrake and re-raises the
        # exception.
        # @param [Hash] env the Rack environment
        def call(env)
          # rubocop:disable Lint/RescueException
          begin
            response = @app.call(env)
          rescue Exception => ex
            notify_airbrake(ex, env)
            raise ex
          end
          # rubocop:enable Lint/RescueException

          # The internal framework middlewares store exceptions inside the Rack
          # env. See: https://goo.gl/Kd694n
          exception = env['action_dispatch.exception'] || env['sinatra.error']
          notify_airbrake(exception, env) if exception

          response
        end
      end

      def initialize(notifier_name)
        @notifier_name = notifier_name
      end

      def build_middleware
        # Local variable assignment, so we could pass instance variables from
        # this class to the class that we want to create
        notifier_name = @notifier_name

        Class.new do
          include MiddlewareMethods

          private

          define_method(:notify_airbrake) do |exception, env|
            notice = NoticeBuilder.new(env, notifier_name).build_notice(exception)
            Airbrake.notify(notice, {}, notifier_name)
          end
        end
      end
    end
  end
end

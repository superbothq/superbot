# frozen_string_literal: true

module Superbot
  module Convert
    module Web
      def self.registered(sinatra)
        sinatra.helpers do
          def capybara_runner
            @capybara_runner ||= Superbot::Capybara::Runner.new
          end
        end

        sinatra.post "/__superbot/v1/convert" do
          begin
            converted_script = Superbot::Capybara::Convert.call(request.body.read)
            capybara_runner.run(converted_script)
            halt 200
          rescue SystemExit => e
            e.message
          end
        end
      end
    end
  end
end

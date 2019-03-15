require 'logger'

module JAM
  module Log
    # Modified from:
    # https://stackoverflow.com/questions/6407141/how-can-i-have-ruby-logger-log-output-to-stdout-as-well-as-file
    class MultiLogger
      def initialize(*targets)
        @targets = targets
      end

      %w(log debug info warn error fatal unknown level=).each do |m|
        define_method(m) do |*args|
          @targets.map { |t| t.send(m, *args) }
        end
      end
    end
  end
end

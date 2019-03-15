require 'jam/log'
require 'jam/sh'
require 'yaml'

module JAM
  module App
    def self.name
      @name ||= File.basename($0)
    end

    def self.log
      @log and return @log

      # Setup standard logging.
      # - Set log level to info.
      # - Set date time format.
      # - Use custom format.
      # - Print logging msg using inspect to handle nested data types.
      time_format = '%Y-%m-%d %H:%M:%S'
      formatter = proc do |severity, datetime, progname, msg|
        data = msg.is_a?(String) ? msg : msg.inspect
        "[#{datetime}|#{severity}] #{data}\n"
      end

      # Note: logger can't output only at a specified level.
      stdout_log = ::Logger.new(STDOUT)
      stdout_log.level = ::Logger::WARN

      # Save 2 1MB files
      file_log = ::Logger.new("#{JAM::App.name}.log", 2, 1024*1000)
      file_log.level = ::Logger::INFO

      [stdout_log, file_log].each do |log| 
        log.datetime_format = time_format
        log.formatter = formatter
      end

      @log = JAM::Log::MultiLogger.new( stdout_log, file_log )
    end

    def hostname
      @hostname ||= %x(hostname).chomp
    end

    def config_file
      "#{JAM::App.name}.yaml"
    end

    def config()
      @config and return @config
      File.exists?(config_file) or die "Config file #{config_file} not found."
      @config = YAML::load_file(config_file)
    end

    def die(message)
      App.log.fatal(message)
      exit 2
    end
  end
end

# Returns true if the current process is interactive.
def interactive?
  system "tty -s"
end

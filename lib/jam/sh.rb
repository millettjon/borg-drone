require 'shellwords'

module JAM
  class ShellException < StandardError
    attr_reader :command, :status, :output

    def initialize(command, status, output=nil)
      @command = command
      @status = status
      @output = output
    end

    def to_s
      s = "Command #{@command} exited with code #{@status.exitstatus}"
      s += " and output #{@output}" if output
      s
    end
  end

  class << self
    def build_cmd(cmd)
      if cmd.is_a? Array
        cmd.shelljoin
      else
        cmd
      end
    end

    # Runs a command redirecting STDERR to STDOUT.  If the exit code is
    # zero, the output is returned.  Otherwise, an exception is raised.
    def sh(command, opts={})
      opts = {:ignore_codes => nil}.merge(opts) # exit codes to ignore
      cmd = build_cmd(command)
      out = `#{cmd} 2>&1`.chomp
      (opts[:ignore_codes].to_a << 0).include? $?.exitstatus or raise ShellException.new(cmd, $?, out), nil, caller
      out
    end

    def sys(command)
      cmd = build_cmd(command)
      system cmd
      $?.success? or raise ShellException.new(cmd, $?), nil, caller
    end
  end
end

def sh(*args)
  JAM.sh(*args)
end

def sys(*args)
  JAM.sys(*args)
end

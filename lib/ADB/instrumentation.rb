require 'ADB/errors'

module ADB
  module Instrumentation
    def instrument(runner, args = {})
      with(the(runner) << and_the(args))
    end

    private
    def with(args)
      shell *"am instrument #{args.strip}".split
    end

    def the(runner)
      "-w #{runner} "
    end

    def and_the(extras)
      to_arg(extras).join
    end

    def to_arg(args)
      args.map do |name, value|
        "-e #{name} #{value} "
      end
    end

  end
end

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

    def and_the(args)
      to_args(args).join
    end

    def to_args(args)
      args.map do |name, value|
        "-e #{name} #{value} "
      end
    end

  end
end

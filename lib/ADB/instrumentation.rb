require 'ADB/errors'

module ADB
  module Instrumentation
    #
    # send instrumentation requests
    # 
    # @example
    #   instrument "com.example/android.test.InstrumentationTestRunner"
    #   # will run all of the tests within the 'com.example' package using the 'android.test.InstrumentationTestRunner'
    #
    # @example
    #   instrument "com.example/android.test.InstrumentationTestRunner", :class => "com.example.test.SomeTestClass"
    #
    #   # will execute all of the tests within 'com.example.test.SomeTestClass'
    #
    # @param [String] runner indicates the package/runner to instrument
    # @param [Hash] collection of key/value pairs to be sent as arguments to the instrumentation runner
    #
    def instrument(runner, args = {})
      with(the(runner) << and_the(args))
      raise ADBError, last_stderr unless last_stderr.empty?
    end

    private
    def with(args)
      shell *"am instrument #{args.strip}"
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

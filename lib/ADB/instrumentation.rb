require 'ADB/errors'

module ADB
  module Instrumentation
    def instrument(info, extras = {})
      runner(info)
      the_class(extras)
      instrument_with(@args)
    end

    private
    def runner(info)
      @args = "-w #{info}"
    end

    def the_class(extras)
      @args << " -e class #{extras[:class]}" if extras[:class]
    end

    def instrument_with(args)
      shell *"am instrument #{args}".split
    end

  end
end

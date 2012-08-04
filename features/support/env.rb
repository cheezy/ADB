$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../../', 'lib'))

require 'rspec/expectations'
require 'childprocess'
require 'ADB'

World(ADB)

emulator = ChildProcess.build('emulator', '-avd', 'Android_4.0.3')
emulator.start

at_exit do
  emulator.stop
end


After do
  stop_server
end


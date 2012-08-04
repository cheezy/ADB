# encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rspec'
require 'ADB'
require 'childprocess'

include ADB

def process_mock
  process_mock = double('process_mock')
  process_mock.should_receive(:start)
  process_mock.should_receive(:poll_for_exit)
  process_mock.should_receive(:io).twice.and_return(process_mock)
  process_mock.should_receive(:stdout=)
  process_mock.should_receive(:stderr=)
  process_mock
end

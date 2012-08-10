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
  mock_output_file(process_mock)
  process_mock
end

def mock_output_file(output)
  output.should_receive(:io).exactly(4).times.and_return(output)
  output.should_receive(:stdout=)
  output.should_receive(:stdout).and_return(output)
  output.should_receive(:stderr=)
  output.should_receive(:stderr).and_return(output)
  output.should_receive(:rewind).twice
  output.should_receive(:read).twice.and_return([])
  output.should_receive(:close).twice
  output.should_receive(:unlink).twice
end

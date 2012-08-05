require 'spec_helper'

describe ADB do
  it "should know how to start the adb server" do
    ChildProcess.should_receive(:build).with('adb', 'start-server').and_return(process_mock)
    ADB.start_server
  end

  it "should know how to stop the adb server" do
    ChildProcess.should_receive(:build).with('adb', 'kill-server').and_return(process_mock)
    ADB.stop_server
  end
  
  it "should know how to provide list of devices" do
    ChildProcess.should_receive(:build).with('adb', 'devices').and_return(process_mock)
    ADB.devices
  end

  it "should stop process if it takes too long" do
    process = double('process_mock')
    process.should_receive(:io).twice.and_return(process)
    process.should_receive(:stdout=)
    process.should_receive(:stderr=)
    process.should_receive(:start)
    process.should_receive(:poll_for_exit).and_raise(ChildProcess::TimeoutError)
    process.should_receive(:stop)
    ChildProcess.should_receive(:build).with('adb', 'devices').and_return(process)
    ADB.devices
  end
end

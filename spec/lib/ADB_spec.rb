require 'spec_helper'

describe ADB do
  it "should know how to start the adb server" do
    should_call_adb_with('start-server')
    ADB.start_server
  end

  it "should know how to stop the adb server" do
    should_call_adb_with('kill-server')
    ADB.stop_server
  end
  
  it "should know how to provide list of devices" do
    should_call_adb_with('devices')
    ADB.devices
  end

  it "should stop process if it takes too long" do
    process = double('process')
    process.should_receive(:start)
    process.should_receive(:poll_for_exit).and_raise(ChildProcess::TimeoutError)
    process.should_receive(:stop)
    mock_output_file(process)
    ChildProcess.should_receive(:build).with('adb', 'devices').and_return(process)
    ADB.devices
  end

  it "should know how to connect to a device" do
    should_call_adb_with('connect', 'localhost:5555')
    ADB.connect('localhost', '5555')
  end

  it "should default to using port 5555 when connecting to a device" do
    should_call_adb_with('connect', 'localhost:5555')
    ADB.connect('localhost')
  end

  it "should default to using localhost when connecting to a device" do
    should_call_adb_with('connect', 'localhost:5555')
    ADB.connect
  end

  it "should know how to disconnect from a device" do
    should_call_adb_with('disconnect', 'localhost:5555')
    ADB.disconnect('localhost', '5555')
  end

  it "should default to using port 5555 when disconnecting from a device" do
    should_call_adb_with('disconnect', 'localhost:5555')
    ADB.disconnect('localhost')
  end

  it "should default to using localhost when disconnecting from a device" do
    should_call_adb_with('disconnect', 'localhost:5555')
    ADB.disconnect
  end

  def should_call_adb_with(*args)
    ChildProcess.should_receive(:build).with('adb', *args).and_return(process_mock)    
  end
end

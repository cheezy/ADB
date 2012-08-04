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
end

require 'spec_helper'

describe ADB do
  it "should know how to provide list of devices" do
    ChildProcess.should_receive(:build).with('adb', 'devices').and_return(process_mock)
    ADB.devices
  end
end

require 'spec_helper'

describe ADB do
  it "should know how to start the adb server" do
    ADB.should_receive(:last_stdout).and_return("daemon started successfully")
    should_call_adb_with('start-server')
    ADB.start_server
  end

  it "should know how to stop the adb server" do
    should_call_adb_with('kill-server')
    ADB.stop_server
  end

  it "should stop process if it takes too long" do
    ADB.should_receive(:last_stdout).and_return("device")
    process = double('process')
    process.should_receive(:start)
    process.should_receive(:poll_for_exit).and_raise(ChildProcess::TimeoutError)
    process.should_receive(:stop)
    mock_output_file(process)
    ChildProcess.should_receive(:build).with('adb', 'devices').and_return(process)
    ADB.devices
  end

  it "should know how to provide list of devices" do
    ADB.should_receive(:last_stdout).and_return("device")
    should_call_adb_with('devices')
    ADB.devices
  end

  context "when executing a shell command" do
    it "should be able to check the device date and time" do
      should_call_adb_with('wait-for-device', 'shell', 'date')
      ADB.shell('date')
    end

    it "can list installed packages" do
      should_call_adb_with('wait-for-device', 'shell', 'pm', 'list', 'packages')
      ADB.list_packages
    end
    it "can list installed packages with packages" do
      should_call_adb_with('wait-for-device', 'shell', 'pm', 'list', 'packages', '-f')
      ADB.list_packages '-f'
    end
  end

  it "should be able to build an date formatted for adb shell date command" do
    date = DateTime.strptime('04/23/2012  13:24', '%m/%d/%C%y %H:%M')
    ADB.format_date_for_adb(date).should eq "20120423.132400"
  end

  it "should setup port forwarding" do
    should_call_adb_with('forward', 'src', 'dest')
    ADB.forward('src', 'dest')
  end

  context "when transferring files" do

    it "should be able to push a file" do
      should_call_adb_with('push', '/usr/foo.txt', '/sdcard/bar.txt')
      ADB.push('/usr/foo.txt', '/sdcard/bar.txt')
    end

    it "should be able to push a file with spaces in the name" do
      should_call_adb_with('push', '/usr/local file with spaces.txt', '/sdcard/remote file with spaces.txt')
      ADB.push('/usr/local file with spaces.txt', '/sdcard/remote file with spaces.txt')
    end

    it "should be able to pull a file" do
      should_call_adb_with('pull', '/usr/foo.txt', '/sdcard/bar.txt')
      ADB.pull('/usr/foo.txt', '/sdcard/bar.txt')
    end

    it "should be able to pull a file with spaces in the name" do
      should_call_adb_with('pull', '/usr/local file with spaces.txt', '/sdcard/remote file with spaces.txt')
      ADB.pull('/usr/local file with spaces.txt', '/sdcard/remote file with spaces.txt')
    end

    it "should be able to remount the /system drive" do
      should_call_adb_with('remount')
      ADB.remount
    end

    it "should be able to provide root access" do
      should_call_adb_with('root')
      ADB.root
    end
  end

  context "when connecting to a device" do
    before(:each) do
      ADB.should_receive(:last_stdout).and_return("connected to localhost")
    end

    it "should connect successfully" do
      should_call_adb_with('connect', 'localhost:5555')
      ADB.connect('localhost', '5555')
    end

    it "should default to using port 5555" do
      should_call_adb_with('connect', 'localhost:5555')
      ADB.connect('localhost')
    end

    it "should default to using host localhost" do
      should_call_adb_with('connect', 'localhost:5555')
      ADB.connect
    end
  end

  context "when disconnecting from a device" do
    it "should disconnect successfully" do
      should_call_adb_with('disconnect', 'localhost:5555')
      ADB.disconnect('localhost', '5555')
    end

    it "should default to using port 5555" do
      should_call_adb_with('disconnect', 'localhost:5555')
      ADB.disconnect('localhost')
    end

    it "should default to using host localhost" do
      should_call_adb_with('disconnect', 'localhost:5555')
      ADB.disconnect
    end
  end

  context "wating for a device to start" do
    it "should wait for only device" do
      should_call_adb_with('wait-for-device')
      ADB.wait_for_device
    end

    it "should wait for the only connected device" do
      should_call_adb_with('-d', 'wait-for-device')
      ADB.wait_for_device :device => 'blah'
    end

    it "should wait for the only emulator" do
      should_call_adb_with('-e', 'wait-for-device')
      ADB.wait_for_device :emulator => 'blah'
    end

    it "should wait for a device when using serial number" do
      should_call_adb_with('-s', 'sernum', 'wait-for-device')
      ADB.wait_for_device :serial => 'sernum'
    end
  end

  context "when installing an apk" do
    it "should be able to install an application" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('wait-for-device', 'install', 'Test.apk')
      ADB.install 'Test.apk'
    end

    it "should be able to install an application with spaces in the path" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('wait-for-device', 'install', 'Test Path With Spaces.apk')
      ADB.install 'Test Path With Spaces.apk'
    end

    it "should install to the only connected device" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('-d', 'wait-for-device', 'install', 'Test.apk')
      ADB.install 'Test.apk', nil, :device => 'blah'
    end

    it "should install to the only emulator" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('-e', 'wait-for-device', 'install', 'Test.apk')
      ADB.install 'Test.apk', nil, :emulator => 'blah'
    end

    it "should install to a target using serial number" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('-s', 'sernum', 'wait-for-device', 'install', 'Test.apk')
      ADB.install 'Test.apk', nil, :serial => 'sernum'
    end

    it "should raise an error when the install fails" do
      ADB.should_receive(:last_stdout).any_number_of_times.and_return("some error")
      should_call_adb_with('wait-for-device', 'install', 'Test.apk')
      expect { ADB.install('Test.apk') }.to raise_error(ADBError)
    end

    it "should accept an optional parameter" do
      ADB.should_receive(:last_stdout).and_return("Success")
      should_call_adb_with('-s', 'sernum', 'wait-for-device', 'install', '-r', 'Test.apk')
      ADB.install 'Test.apk', '-r', :serial => 'sernum'
    end
  end

  context "when uninstalling an apk" do
    it "should be able to uninstall an application" do
      ADB.should_receive(:last_stdout).and_return('Success')
      should_call_adb_with('uninstall', 'com.example')
      ADB.uninstall 'com.example'
    end

    it "should uninstall from the only connected device" do
      ADB.should_receive(:last_stdout).and_return('Success')
      should_call_adb_with('-d', 'uninstall', 'com.example')
      ADB.uninstall 'com.example', :device => 'blah'
    end

    it "should uninstall from the only emulator" do
      ADB.should_receive(:last_stdout).and_return('Success')
      should_call_adb_with('-e', 'uninstall', 'com.example')
      ADB.uninstall 'com.example', :emulator => 'blah'
    end

    it "should unistall from a device using the serial number" do
      ADB.should_receive(:last_stdout).and_return('Success')
      should_call_adb_with('-s', 'sernum', 'uninstall', 'com.example')
      ADB.uninstall 'com.example', :serial => 'sernum'
    end

    it "should raise an error when the uninstall fails" do
      ADB.should_receive(:last_stdout).any_number_of_times.and_return('some error')
      should_call_adb_with('uninstall', 'com.example')
      expect { ADB.uninstall('com.example') }.to raise_error(ADBError)
    end

    it "should raise an error when the uninstall fails" do
      ADB.should_receive(:last_stdout).any_number_of_times.and_return('some stdout message')
      should_call_adb_with('uninstall', 'com.example')
      expect { ADB.uninstall('com.example') }.to raise_error(ADBError, "Could not uninstall com.example Cause: some stdout message")
    end

    it "should raise an error when the uninstall fails" do
      ADB.should_receive(:last_stderr).any_number_of_times.and_return('some stderr message')
      should_call_adb_with('uninstall', 'com.example')
      expect { ADB.uninstall('com.example') }.to raise_error(ADBError, "Could not uninstall com.example Error: some stderr message")
    end

    it "should raise an error when the uninstall fails" do
      ADB.should_receive(:last_stdout).any_number_of_times.and_return('some stdout message')
      ADB.should_receive(:last_stderr).any_number_of_times.and_return('some stderr message')
      should_call_adb_with('uninstall', 'com.example')
      expect { ADB.uninstall('com.example') }.to raise_error(ADBError, "Could not uninstall com.example Cause: some stdout message, and Error: some stderr message")
    end

  end


  def should_call_adb_with(*args)
    ChildProcess.should_receive(:build).with('adb', *args).and_return(process_mock)
  end
 end

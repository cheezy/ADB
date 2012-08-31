When /^the adb server is started$/ do
  start_server
end

Then /^the adb server should be running$/ do
  last_stdout.should include "daemon started successfully"
end

Then /^I should be able to connect to a local device$/ do
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  connect('localhost')
  last_stdout.should include "connected to localhost"
  disconnect('localhost')
end

Given /^I am connected to the local device$/ do
  connect
end

Then /^I should see the device "(.*?)"$/ do |device|
puts devices
  devices.should include device
end

Then /^I should be able to install the sample application$/ do
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  install 'features/support/ApiDemos.apk', {:serial => sn}, 60
  last_stdout.should include 'Success'
end

Then /^I should be able to uninstall the sample application$/ do
  sn = devices[0]
  uninstall 'com.example.android.apis', {:serial => sn}
  last_stdout.should include 'Success'
end

When /^I change the devices date and time to (.*?)$/ do |date_arg|
  sn = devices[0]
  date = DateTime.strptime(date_arg, '%m/%d/%C%y %I:%M')
  shell("date -s #{format_date_for_adb(date)}", {:serial => sn}, 60)
end

Then /^the device time should be (.*?)$/ do |date_str|
  last_stdout.should include date_str
end

Then /^I should be able to forward "(.*?)" to "(.*?)"$/ do |source, target|
  sn = devices[0]
  forward(source, target, {:serial => sn})
end

Then /^I can remount the system partition$/ do
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  remount({:serial => sn})
  last_stdout.should include 'remount succeeded'
end

Then /^I can attain root privileges$/ do
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  root({:serial => sn})
  #TODO: how to assert?
  #last_stdout.should include 'remount succeeded'
end

Then /^I should be able to push a file to the local device$/ do
  # confirm that the file doesn't already exist
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  remount({:serial => sn})
  shell('ls /system/cuke_test_file.txt', {:serial => sn})
  last_stdout.should include 'No such file or directory'

  # create the temp file
  File.open('cuke_test_file.txt', 'w'){ |f|  f.write('Temporary file for adb testing. If found, please delete.') }

  # push the file
  push('cuke_test_file.txt', '/system/cuke_test_file.txt', {:serial => sn})
  last_stderr.should_not include 'failed to copy'

end

Then /^I should be able to pull a file from the local device$/ do
  # confirm that the file exists on the device and not locally
  sn = devices[0]
  wait_for_device({:serial => sn}, 60)
  remount({:serial => sn})
  shell("touch /system/cuke_test_file.txt", {:serial => sn})

  # pull the file
  pull('/system/cuke_test_file.txt', 'cuke_test_file.txt', {:serial => sn})

  # confirm that the file was created
  File.exists?('cuke_test_file.txt').should == true
end

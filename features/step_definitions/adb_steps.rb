When /^the adb server is started$/ do
  start_server
end

Then /^the adb server should be running$/ do
  last_stdout.should include "daemon started successfully"
end

Then /^I should be able to connect to a local device$/ do
  connect('localhost')
  last_stdout.should include "connected to localhost"
  disconnect('localhost')
end

Given /^I am connected to the local device$/ do
  connect
end

Then /^I should see the device "(.*?)"$/ do |device|
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

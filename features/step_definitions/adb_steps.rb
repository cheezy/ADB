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

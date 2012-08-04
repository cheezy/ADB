When /^the adb server is started$/ do
  start_server
end

Then /^the adb server should be running$/ do
  last_stdout.should include "daemon started successfully"
end

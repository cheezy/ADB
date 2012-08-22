Feature: Using the ADB module

  Scenario: Starting the adb server
    When the adb server is started
    Then the adb server should be running

  Scenario: Connecting to a device
    Given the adb server is started
    Then I should be able to connect to a local device

  Scenario: Getting list of devices
    Given the adb server is started
    And I am connected to the local device
    Then I should see the device "localhost:5555"

  Scenario: Installing applications on the device
    Given the adb server is started
    And I am connected to the local device
    Then I should be able to install the sample application

  Scenario: Uninstalling the application
    Given the adb server is started
    And I am connected to the local device
    Then I should be able to uninstall the sample application

  Scenario: Use shell to update the system date
    Given the adb server is started
    And I am connected to the local device
    When I change the devices date and time to 08/10/2012 11:25
    Then the device time should be Aug 10 11:25:00 EDT 2012

  Scenario: Forwarding ports
    Given the adb server is started
    And I am connected to the local device
    Then I should be able to forward "tcp:7777" to "tcp:5555"

  Scenario: Remount the system partition for read-write access
    Given the adb server is started
    And I am connected to the local device
    Then I can remount the system partition

  Scenario: Restart adb in root mode
    Given the adb server is started
    And I am connected to the local device
    Then I can attain root privileges

  Scenario: Push a file
    Given the adb server is started
    And I am connected to the local device
    Then I should be able to push a file to the local device

  Scenario: Pull a file
    Given the adb server is started
    Then I should be able to pull a file from the local device



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

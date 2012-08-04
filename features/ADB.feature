Feature: Using the ADB module

  Scenario: Starting the adb server
    When the adb server is started
    Then the adb server should be running

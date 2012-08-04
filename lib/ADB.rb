require "ADB/version"
require 'childprocess'

module ADB

  def devices
    process = ChildProcess.build('adb', 'devices')
    process.start
  end
  
end

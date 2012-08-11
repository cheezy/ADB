require 'ADB/version'
require 'ADB/errors'
require 'childprocess'
require 'tempfile'

#
# Mixin that provides access to the commands of the adb executable
# which is a part of the android toolset.
#
module ADB

  attr_reader :last_stdout, :last_stderr

  #
  # start the server process
  #
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def start_server(timeout=30)
    execute_adb_with(timeout, 'start-server')
    raise ADBError, "Server didn't start" unless stdout_contains "daemon started successfully"
  end

  #
  # stop the server process
  #
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def stop_server(timeout=30)
    execute_adb_with(timeout, 'kill-server')
  end

  #
  # connect to a running device via TCP/IP
  #
  # @param hostname defaults to 'localhost'
  # @param port defaults to '5555'
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def connect(hostname='localhost', port='5555', timeout=30)
    execute_adb_with(timeout, "connect #{hostname}:#{port}")
    raise ADBError, "Could not connect to device at #{hostname}:#{port}" unless stdout_contains "connected to #{hostname}"
  end

  #
  # disconnect from a device
  #
  # @param hostname defaults to 'localhost'
  # @param port defaults to '5555'
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def disconnect(hostname='localhost', port='5555', timeout=30)
    execute_adb_with(timeout, "disconnect #{hostname}:#{port}")
  end

  #
  # list all connected devices
  #
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def devices(timeout=30)
    execute_adb_with(timeout, 'devices')
    device_list = last_stdout.split("\n")
    device_list.shift
    device_list.collect { |device| device.split("\t").first }
  end

  #
  # wait for a device to complete startup
  #
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def wait_for_device(target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} wait-for-device")
  end

  #
  # install an apk file to a device
  #
  # @param the path and filename to the apk you wish to install
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def install(installable, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} install #{installable}")
    raise ADBError, "Could not install #{installable}" unless stdout_contains "Success"
  end

  #
  # uninstall an apk file to a device
  #
  # @param the package name of the apk ou wish to uninstall
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def uninstall(package, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} uninstall #{package}")
    raise ADBError, "Could not uninstall #{package}" unless stdout_contains "Success"
  end

  private

  def execute_adb_with(timeout, arguments)
    args = arguments.split
    process = ChildProcess.build('adb', *args)
    process.io.stdout, process.io.stderr = std_out_err
    process.start
    kill_if_longer_than(process, timeout)
    @last_stdout = output(process.io.stdout)
    @last_stderr = output(process.io.stderr)
  end

  def which_one(target)
    direct = ''
    direct = '-d' if target[:device]
    direct = '-e' if target[:emulator]
    direct = "-s #{target[:serial]}" if target[:serial]
    direct
  end

  def kill_if_longer_than(process, timeout)
    begin
      process.poll_for_exit(timeout)
    rescue ChildProcess::TimeoutError
      process.stop
    end
  end

  def output(file)
    file.rewind
    out = file.read
    file.close
    file.unlink
    out
  end

  def std_out_err
    return ::Tempfile.new("adb-out#{Time.now}"), ::Tempfile.new("adb-err#{Time.now}")
  end

  def stdout_contains(expected)
    last_stdout.include? expected
  end
end

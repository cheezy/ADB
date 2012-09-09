require 'ADB/instrumentation'
require 'ADB/version'
require 'ADB/errors'
require 'childprocess'
require 'tempfile'
require 'date'
#
# Mixin that provides access to the commands of the adb executable
# which is a part of the android toolset.
#
module ADB
  include ADB::Instrumentation

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
  def install(installable, options=nil, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} wait-for-device install #{options} #{installable}")
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

  #
  # execute shell command
  #
  # @param [String] command to be passed to the shell command
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def shell(command, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} wait-for-device shell #{command}")
  end

  #
  # format a date for adb shell date command
  #
  # @param date to format.  Defaults current date
  #
  def format_date_for_adb(date=Date.new) 
    date.strftime("%C%y%m%d.%H%M00")
  end

  #
  # setup port forwarding
  #
  # @param the source protocol:port
  # @param the destination protocol:port
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def forward(source, destination, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} forward #{source} #{destination}")
  end

  #
  # push a file
  #
  # @param the fully quanified source (local) file name
  # @param the fully quanified destination (device) file name
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def push(source, destination, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} push #{source} #{destination}")
  end

  #
  # push a file
  #
  # @param the fully quanified source (device) file name
  # @param the fully quanified destination (local) file name
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def pull(source, destination, target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} pull #{source} #{destination}")
  end

  #
  # remount /system as read-write
  #
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def remount(target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} remount")
  end

  #
  # restarts the adb daemon with root permissions
  #
  # @param [Hash] which device to wait for.  Valid keys are :device,
  # :emulator, and :serial.
  # @param timeout value for the command to complete.  Defaults to 30
  # seconds.
  #
  def root(target={}, timeout=30)
    execute_adb_with(timeout, "#{which_one(target)} root")
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

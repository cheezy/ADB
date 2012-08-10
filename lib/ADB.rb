require 'ADB/version'
require 'ADB/errors'
require 'childprocess'
require 'tempfile'

module ADB

  attr_reader :last_stdout

  def start_server(timeout=30)
    execute_adb_with(timeout, 'start-server')
    raise ADBError, "Server didn't start" unless stdout_contains "daemon started successfully"
  end

  def stop_server(timeout=30)
    execute_adb_with(timeout, 'kill-server')
  end

  def connect(hostname='localhost', port='5555', timeout=30)
    execute_adb_with(timeout, "connect #{hostname}:#{port}")
    raise ADBError, "Could not connect to device at #{hostname}:#{port}" unless stdout_contains "connected to #{hostname}"
  end

  def disconnect(hostname='localhost', port='5555', timeout=30)
    execute_adb_with(timeout, "disconnect #{hostname}:#{port}")
  end

  def devices(timeout=30)
    execute_adb_with(timeout, 'devices')
  end

  def last_stdout
    @last_stdout
  end

  def last_stderr
    @last_stderr
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

require "ADB/version"
require 'childprocess'
require 'tempfile'

module ADB

  def start_server(timeout=30)
    execute_adb_with(timeout, 'start-server')
  end

  def stop_server(timeout=30)
    execute_adb_with(timeout, 'kill-server')
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
    process = ChildProcess.build('adb', arguments)
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
end

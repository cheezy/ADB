require "ADB/version"
require 'childprocess'
require 'tempfile'

module ADB

  def start_server(timeout=30)
    execute_adb_with(timeout, ['start-server'])
  end

  def stop_server(timeout=30)
    execute_adb_with(timeout, ['kill-server'])
  end

  def devices(timeout=30)
    execute_adb_with(timeout, ['devices'])
  end

  def last_stdout
    @last_stdout
  end

  def last_stderr
    @last_stderr
  end

  private

  def execute_adb_with(timeout, parameters)
    out = ::Tempfile.new('adb-out')
    err = ::Tempfile.new('adb-err')
    process = ChildProcess.build('adb', parameters.join(','))
    process.io.stdout = out
    process.io.stderr = err
    process.start
    kill_if_longer_than(process, timeout)
    get_output(out, err)
  end

  def kill_if_longer_than(process, timeout)
    begin
      process.poll_for_exit(timeout)
    rescue ChildProcess::TimeoutError
      process.stop
    end
  end

  def get_output(out, err)
    out.rewind
    @last_stdout = out.read
    out.close
    out.unlink

    err.rewind
    @last_stderr = err.read
    err.close
    err.unlink
  end
end

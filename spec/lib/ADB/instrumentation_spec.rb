require 'spec_helper'

class InstrumentingClass
  include ADB
end

describe ADB::Instrumentation do
  let(:instrumenter) { InstrumentingClass.new }
  let(:runner) { 'com.example/com.example.TestRunner' }
  let(:base_args) { "am instrument " }

  before(:each) do
    instrumenter.stub(:shell)
    instrumenter.stub(:last_stdout).and_return('')
  end

  context "when instrumenting through ADB" do
    it "should be able to run all of the tests" do
      instrumenter.should_receive(:shell).with(*base_args.concat("-w #{runner}"))
      instrumenter.instrument(runner)
    end

    it "should run tests in a single test class only" do
      instrumenter.should_receive(:shell).with(*base_args.concat("-e class com.example.class #{runner}"))
      instrumenter.instrument(runner, :class => 'com.example.class')
    end

    it "should be able to take extra arguments" do
      instrumenter.should_receive(:shell).with(*base_args.concat("-e any thing -e should be -e able to -e be passed -w #{runner}"))
      instrumenter.instrument(runner, :any => 'thing', :should => 'be', :able => 'to', :be => 'passed')
    end

    it "should raise an error if anything is in stderr" do
      instrumenter.stub(:last_stdout).and_return('some problem')
      lambda { instrumenter.instrument(runner) }.should raise_error(exception=ADBError, message="some problem")
    end
  end

end

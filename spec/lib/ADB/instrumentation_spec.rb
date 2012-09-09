require 'spec_helper'
require 'ADB/instrumentation'

class InstrumentingClass
  include ADB::Instrumentation
end

describe ADB::Instrumentation do
  let(:instrumenter) { InstrumentingClass.new }
  let(:runner) { 'com.example/com.example.TestRunner' }
  let(:base_args) { "am instrument -w #{runner}".split }

  context "when instrumenting through ADB" do
    it "should be able to run all of the tests" do
      instrumenter.should_receive(:shell).with(*base_args)
      instrumenter.instrument(runner)
    end

    it "should be able to run tests in a single test class" do
      instrumenter.should_receive(:shell).with(*base_args.concat("-e class com.example.class".split))
      instrumenter.instrument(runner, :class => 'com.example.class')
    end

    it "should be able to take extra arguments" do
      instrumenter.should_receive(:shell).with(*base_args.concat("-e any thing -e should be -e able to -e be passed".split))
      instrumenter.instrument(runner, :any => 'thing', :should => 'be', :able => 'to', :be => 'passed')
    end
  end

end

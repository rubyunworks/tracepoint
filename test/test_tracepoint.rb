$:.unshift File.dirname(__FILE__) + '/../lib'

require 'tracepoint'
require 'minitest/autorun'

class TracePointTestCase < MiniTest::Unit::TestCase

  def test_simple_trace  
    trace_log = []

    TracePoint.trace do |tp|
      trace_log << [tp.self.class, tp.callee, tp.event, tp.return?, tp.back == tp.bind]
    end

    TracePoint.activate
    1 + 1
    TracePoint.deactivate

    assert_includes trace_log, [Fixnum, :'+', 'c-call',   false, false]
    assert_includes trace_log, [Fixnum, :'+', 'c-return', false, false] 
  end

end

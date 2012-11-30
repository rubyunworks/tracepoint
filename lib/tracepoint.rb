# TracePoint is a better way to use #set_trace_func.
# By definition a TracePoint is a Binding with the addition
# of event information. Howerver, Binding can't be subclassed,
# so the implementation delegates.
#
# If it were not for the speed degration that comes fomr using
# a tracing function, the tracepoint functions very well as the
# join-point for Event-based AOP.
#
# Simple example of usage:
#
#   TracePoint.trace { |tp|
#     puts "#{tp.self.class}\t#{tp.called}\t#{tp.event}\t#{tp.return?}\t#{tp.back == tp.bind}"
#   }
#
#   1 + 1
#
# produces
#
#   Class   trace   return     true    false
#   Object          line       false   false
#   Fixnum  +       c-call     false   false
#   Fixnum  +       c-return   false   false
#
#
# TracePoint provide a number of methods for working with events.
# Here is a list of these methods and the events to which they
# coorespond.
#
#    all     => *all events*
#    before  => call, c-call
#    after   => return, c-return
#    call    => call
#    return  => return
#    ccall   => c-call
#    creturn => c-return
#    line    => line
#    class   => class
#    end     => end
#    raise   => raise
# 
# Note the CodePoing alias for Binding has been deprecated.
#
class TracePoint #< CodePoint

  # Access to project metadata. This simply provides information
  # abouty the project. It is used by #const_missing, allowing 
  # access most importantly to `TracePoint::VERSION`.
  def self.metadata
    @metadata ||= (
      require 'yaml'
      YAML.load(File.new(File.dirname(__FILE__) + '/tracepoint.yml'))
    )
  end

  # Access metadata as constants. See #metdata.
  #
  # @example
  #   TracePoint::VERSION  #=> '1.3.0'
  #
  def self.const_missing(name)
    name = name.to_s.downcase
    metadata[name] || super(name)
  end

  #  C L A S S  M E T H O D S
  class << self

    @@active = false

    @@index = {}
    @@procs = []

    # Setup a new tracing procedure.
    #
    # @param [Object] name
    #   The name to use to identify given procedure.
    #
    # @yield [tracepoint] procedure
    #   The tracing procedure.
    #
    # @yieldparam [TracePoint] Instance of TracePoint.
    #   The tracing procedure.
    #
    # @return [Array] List of tracing procedures.
    def trace(name=nil, &procedure)
      @@index[name] = procedure if name
      @@procs << procedure
    end

    # Is tracing active?
    #
    # @return [Boolean] true if tracing is active.
    def active?
      @@active
    end

    # Use active method to begin tracing.
    #
    # @example
    #   TracePoint.active
    #
    # @return [Proc] The factual function passed to #set_trace_func.
    def activate
      @@active = true
      bb_stack = []
      fn = lambda do |e, f, l, m, b, k|
        unless k == TracePoint or (k == Kernel && m == :set_trace_func)
          #(p e, f, l, m, b, k, @@bb_stack; puts "---") if $DEBUG
          if ['call','c-call','class'].include?(e)
            bb_stack << b
          elsif ['return','c-return','end'].include?(e)
            bb = bb_stack.pop
          end
          b = bb if ! b    # this sucks!
          tp = TracePoint.new(e, f, l, m, b, bb)
          @@procs.each{ |fn| fn.call(tp) }
        end
      end
      set_trace_func(fn)
    end

    # Deactivate tracing.
    def deactivate
      @@active = false
      set_trace_func nil
    end

    # Clear all trace procedures, or a specific trace by name.
    #
    # @return 
    def clear(name=nil)
      if name
        raise "Undefined trace -- #{name}" unless @@index.key?(name)
        @@procs.delete(@@index.delete(name))
      else
        deactivate
        @@index = {}
        @@procs = []
      end
    end

  end

  # Name of the event.
  #
  # @return [String] Event name
  attr_accessor :event

  # File in which event occured.
  #
  # @return [String] File system path
  attr_accessor :file

  # Line number on which event occured.
  #
  # @return [Integer] Line number
  attr_accessor :line

  # The Binding context in which the even occured.
  #
  # @todo Does this method conflict with `Kernel#binding`?
  #
  # @return [Binding]
  attr_accessor :binding

  # The previous Binding context.
  #
  # @return [Binding]
  attr_accessor :back_binding

  # Until Ruby has a built-in way to get the name of the calling method
  # that information must be passed into the TracePoint.
  #
  # @param [String] event
  #   The event name.
  #
  # @param [String] file
  #   File system path to the file in which the event occured.
  #
  # @param [String] line
  #   The line number of the file on which the event occured.
  #
  # @param [String] method
  #   The name of the method in which the event occured.
  #
  # @param [Binding] bind
  #   The binding of the object context in which the event occured.
  #
  # @param [Binding] back_bind
  #   The previous binding. This is used so `return` events can
  #   refer the binding of there originating `call` events.
  #
  def initialize(event, file, line, method, bind, back_binding=bind)
    @event   = event
    @file    = file
    @line    = line
    @method  = method
    @binding = bind || TOPLEVEL_BINDING #?
    @back_binding = back_binding
  end

  # Shorthand for #binding.
  #
  # @return [Binding]
  def bind
    @binding
  end

  # Shorthand for #back_binding.
  #
  # @return [Binding]
  def back
    @back_binding
  end

  # Delegates "self" to the binding which
  # in turn delegates the binding object.
  def self
    @binding.self #if @binding
  end

  # NOTE: The #callee method could delegate to the binding
  # if Ruby had an internal way to retrieve the current
  # method name.

  # Returns the name of the event's method.
  def callee
    @method
  end

  # Alternate name for #callee method.
  #
  # @deprecated Use #callee instead.
  alias :method_name :callee

  # Original name for #callee method.
  #
  # @deprecated Conflicts with Kernel#method.
  #def method ; @method ; end

  # delegate to binding
  #def method_missing(meth, *args, &blk)
  #  @binding.send(meth, *args, &blk)
  #end

  # TracePoint event references and the actual events to which they coorespond.
  EVENT_MAP = {
    :all     => ['call', 'c-call', 'return', 'c-return', 'line', 'class', 'end', 'raise'],
    :before  => ['call', 'c-call'],
    :after   => ['return', 'c-return'],
    :call    => ['call'],
    :return  => ['return'],
    :ccall   => ['c-call'],
    :creturn => ['c-return'],
    :line    => ['line'],
    :class   => ['class'],
    :end     => ['end'],
    :raise   => ['raise']
  }

  # Lookup the actual internal events for a given TracePoint event reference.
  #
  # @example
  #   tracepoint.event_map(:before)
  #   => ['call', 'c-call']
  #
  # @return [Array<String>] Event list.
  def event_map(e)
    EVENT_MAP[e.to_sym]
  end

  # Is the trace point defined?
  #
  # @return [Boolean]
  def event?
    !! @event
  end

  # Is the trace point undefined?
  #
  # @return [Boolean]
  def eventless?
    ! @event
  end

  # For use in case conditions.
  #
  # @example
  #   case tracepoint
  #   when :before
  #     ...
  #   end
  #
  def ===(e)
    EVENT_MAP[e.to_sym].include?(@event)
  end

  # Creates an <event>? method for each of the above event mappings.
  #
  # @!method before?
  #   TracePoint event matches `call` or `c-call`?
  #   @return [Boolean]
  #
  # @!method after?
  #   TracePoint event matches `return` or `c-return`?
  #   @return [Boolean]
  #
  # @!method call?
  #   TracePoint event matches `call`?
  #   @return [Boolean]
  #
  # @!method return?
  #   TracePoint event matches `return`?
  #   @return [Boolean]
  #
  # @!method ccall?
  #   TracePoint event matches `c-call`?
  #   @return [Boolean]
  #
  # @!method creturn?
  #   TracePoint event matches `c-return`?
  #   @return [Boolean]
  #
  # @!method line?
  #   TracePoint event matches `line`?
  #   @return [Boolean]
  #
  # @!method class?
  #   TracePoint event matches `class`?
  #   @return [Boolean]
  #
  # @!method end?
  #   TracePoint event matches `end`?
  #   @return [Boolean]
  #
  # @!method raise?
  #   TracePoint event matches `raise`?
  #   @return [Boolean]
  #
  EVENT_MAP.each_pair do |m,v|
    define_method( "#{m}?" ){ v.include?(@event) }
  end
end


class Binding

  unless method_defined?(:eval) # 1.8.7+

    # Evaluate a Ruby source code string in the binding context.
    #
    # Ruby 1.9+ has this method built-in. It is only hear for
    # older version of Ruby.
    #
    # @param [String] Source code.
    #
    def eval(code)
      Kernel.eval(code, self)
    end

  end

  # Returns `#self` on the binding context.
  def self()
    @_self ||= eval("self")
  end

end

# Copyright (c) 2005,2010 Thomas Sawyer (FreeBSD License)

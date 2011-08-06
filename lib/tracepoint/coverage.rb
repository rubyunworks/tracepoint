if RUBY_VERSION < '1.9'

  require 'tracepoint' unless defined?(TracePoint)

  # This is backport of Ruby 1.9's Coverage library that can be used with
  # Ruby 1.8 or older. It is not a 100% perfect drop-in, but in comes close.
  #
  # This biggest issue with it at this point is that it cannot exclude coverage
  # of irrelevant files b/c $LOADED_FEATURES in Ruby 1.8 does not use absolute
  # paths. Not sure how to work around this yet.
  module Coverage

    #
    def self.start
      reset

      ignore = @ignore
      result = @result

      TracePoint.trace do |tp|
        case tp.event
        when 'line', 'call', 'end'
          unless ignore.include?(tp.file)
            file = File.expand_path(tp.file)
            result[file][tp.line-1] ||= 0
            result[file][tp.line-1] += 1
          end
        end
      end

      TracePoint.activate
    end

    #
    def self.result
      @result
    end

    #
    def self.reset
      @ignore = $LOADED_FEATURES.dup
      @result = Hash.new{ |h,k| h[k]=[] }
    end

    #
    def self.stop
      TracePoint.deactivate
    end

  end

else

  require 'coverage'

end

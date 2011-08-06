require 'tracepoint/coverage'

Coverage.start

require './foo.rb'

p Coverage.result

module Prometheus
  module Client
    class Eviction
      def initialize(size = 1)
        @size = size
      end

      def call(heap)
        @size.times { heap.shift }
      end
    end
  end
end

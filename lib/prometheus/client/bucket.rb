require 'thread'

require 'prometheus/client/eviction'

module Prometheus
  module Client
    class Bucket
      attr_reader :observations, :values

      def initialize(maximum_size, eviction_policy = Eviction.new(5))
        @maximum_size = maximum_size
        @eviction_policy = eviction_policy
        @observations = 0
        @values = []
        @mutex = Mutex.new
      end

      def size
        @values.size
      end

      def full?
        size == @maximum_size
      end

      def add(timing)
        synchronize do
          @observations += 1
          @eviction_policy.call(@values) if full?
          @values.push(timing)
        end
      end

      def value_at(index)
        observations, values = synchronize do
          [@observations, @values]
        end

        return nil if observations.zero?

        if (index + 1) >= observations
          values.sort.last
        else
          index = ((index.to_f / observations) * size).floor
          values.sort[index]
        end
      end

      def last
        value_at(@observations)
      end

    protected

      def synchronize(&block)
        @mutex.synchronize(&block)
      end
    end
  end
end

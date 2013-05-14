require 'prometheus/client/bucket'

module Prometheus
  module Client
    class BucketList
      attr_reader :buckets

      def initialize(settings = nil)
        @buckets = {}

        init(settings || default_settings)
      end

      def add(value)
        key = @buckets.keys.sort.reverse.find { |key| value >= key }
        @buckets[key].add(value)
      end

      def percentile(percentile)
        observations = @buckets.inject(0) do |memo, (_, bucket)|
          memo += bucket.observations
        end

        index = [(percentile * observations).to_i - 1, 0].max

        cumulative_observations = 0
        @buckets.each do |_, bucket|
          next if bucket.observations.zero?

          # return value at index if bucket includes the requested index
          if (cumulative_observations + bucket.observations) > index
            return bucket.value_at(index - cumulative_observations)
          end

          cumulative_observations += bucket.observations
        end

        # fallback to last value of last bucket
        @buckets.last.last
      end

    protected

      def init(settings)
        step = (settings[:upper] - settings[:lower]) / settings[:count]

        (settings[:lower]..settings[:upper]).step(step) do |start|
          @buckets[start] = Bucket.new(settings[:size])
        end
      end

      def default_settings
        {
          :type => :equally_sized,
          :size => 50,
          :lower => 0,
          :upper => 20_000,
          :count => 5
        }
      end
    end
  end
end

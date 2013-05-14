require 'prometheus/client/metric'
require 'prometheus/client/bucket_list'

module Prometheus
  module Client
    class Histogram < Metric
      def initialize(settings = nil, percentiles = nil)
        super()
        @settings = settings
        @percentiles = percentiles || [0.01, 0.05, 0.5, 0.90, 0.99]
      end

      def type
        :histogram
      end

      def get(labels = {})
        if (bucket_list = @values[label_set_for(labels)])
          @percentiles.inject({}) do |memo, percentile|
            memo[percentile] = bucket_list.percentile(percentile)
            memo
          end
        end
      end

      def add(labels, timing)
        label_set = label_set_for(labels)

        synchronize do
          bucket_list = @values[label_set] || BucketList.new(@settings)
          bucket_list.add(timing)
          @values[label_set] = bucket_list
        end
      end

      def measure(labels, &block)
        start = Time.now
        yield
      ensure
        add(labels, Time.now - start)
      end
    end
  end
end

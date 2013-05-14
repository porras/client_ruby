require 'prometheus/client/histogram'
require 'prometheus/client/metric_example'

module Prometheus::Client
  describe Histogram do
    let(:histogram) { Histogram.new }

    it_behaves_like Metric do
      let(:default) { nil }
    end

    describe '#add' do
      it 'adds a value' do
        # histogram.add({}, 4.5)
      end
    end
  end
end

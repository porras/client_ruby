require 'prometheus/client/bucket'

module Prometheus::Client
  describe Bucket do
    let(:size) { 10 }
    let(:bucket) { Bucket.new(size) }

    describe '.new' do
      it 'requires a maximum size' do
        expect do
          Bucket.new
        end.to raise_error(ArgumentError)
      end
    end

    describe '#size' do
      it 'returns the current number of bucket values' do
        bucket.size.should == 0
      end
    end

    describe '#full?' do
      it 'returns false if the bucket is not full' do
        bucket.full?.should == false
      end

      it 'returns true if the bucket is full' do
        size.times { bucket.add(rand) }

        bucket.full?.should == true
      end
    end

    describe '#add' do
      it 'adds a given value to the bucket' do
        expect do
          bucket.add(42)
        end.to change { bucket.size }.by(1)
      end

      it 'is thread-safe' do
        expect do
          10.times.map do
            Thread.new do
              10.times { bucket.add(rand) }
            end
          end.each(&:join)
        end.to change { bucket.observations }.by(100)
      end
    end

    describe '#value_at' do
      it 'returns nil if the bucket has not been used' do
        bucket.value_at(0).should == nil
      end

      it 'returns the value at the given index' do
        10.times { |i| bucket.add(i.to_f) }

        bucket.value_at(0).should == 0.0
        bucket.value_at(3).should == 3.0
        bucket.value_at(9).should == 9.0
      end

      it 'returns the last value if the given index is out of range' do
        bucket.add(3.0)

        bucket.value_at(10).should == 3.0
      end
    end
  end
end

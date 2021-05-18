
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::MovingAverage::Macd do
  before(:all) do
  end
  let( :input_data ){ read_sample_data.each }  #  Enumerator

  context "dry test"   do
    #
    let(:data) { [100, 200, 200, 500] }
    let(:expected)  { 298.4 }
      # factor = 2.0 / (4 + 1) = 0.4
      # s_1 = 100
      # s_2 = 0.4 * 200 + 0.6 * 100 = 140
      # s_3 = 0.4 * 200 + 0.6 * 140 = 164
      # s_4 = 0.4 * 500 + 0.6 * 164 = 298.4
    it "calculate in strict_mode "do
      ema = TechnicalAnalysis::MovingAverage::ExpMA.new period: 4, strict: true 
      dx=data.map { |x| ema.add_item x }
      expect( dx ).to eq [nil, nil, nil, expected ]
      expect(ema.current).to eq expected
      expect(ema.ma).to eq [ expected ] 
    end
    it "calculate warmup "do
      ema = TechnicalAnalysis::MovingAverage::ExpMA.new period: 4, strict: false 
      dx=data.map { |x| ema.add_item x }
      expect( dx ).to eq [100.0, 140.0, 164.0, 298.4]
      expect(ema.current).to eq expected
      expect( ema.ma ).to eq [100.0, 140.0, 164.0, 298.4]
    end
  end

  context  "caclulatei MACD" do
    context "check Input data" do
      subject { input_data }
      its( :size ){ is_expected.to eq 43 }
    end
    context "apply Indicator" do 
      subject { input_data.calculate( :ema, period: 4 ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq 43 }
    end

    context "perform test calculations from synthetic data" do
      let( :sample_data ){ (1 ..200).each }

      it "throws an exception  if period is one" do
        expect{  sample_data.calculate(:ema, period: 1) }.to raise_exception RuntimeError
      end

      it "indicator returns known values if period is three" do
        output = sample_data.calculate(:ema, period: 3, strict: false)
        expected_output = [ 1, 1.5, 2.25, 3.125 ]
        puts output.take(4).inspect
        expect( output.take 4 ).to eq expected_output
      end

      it "indicator is lower then the trend values"  do
        [4,7,10,15].each do | period |
          ema_output = sample_data.calculate(:ema, period: period, strict: true)
          sample_data.drop( period - 1 ).each.with_index do | s, i|
            expect( ema_output[i] ).to be < s
          end
        end
      end
    end
  end
end

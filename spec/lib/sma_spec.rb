
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::MovingAverage::SMA do
  before(:all) do
  end


  context "dry test" do
    it do
      sma = TechnicalAnalysis::MovingAverage::SimpleMA.new period: 4, strict: true 
      data = [100, 200, 200, 500]
      data.each{| d| sma.add_item(d) }
      expected = 250.0
      expect(sma.current).to eq expected

      expect( sma.ma ).to eq [ expected  ] 
    end
  end

  context "Enumerator.caculate" do
    let( :input_data ){ read_sample_data.each }  #  Enumerator
    let( :period ){ 10 }

    context "check Input data" do
      subject { input_data }
      its( :size ){ is_expected.to eq 43 }
    end
    context "apply Indicator" do 
      subject { input_data.calculate( :sma, period: period ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq 43 }
    end

    context "apply Indicator in strict mode" do 
      subject { input_data.calculate( :sma, period: period, strict: true ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq (43-(period-1)) }
    end

    context "perform test calculations from synthetic data" do
      let( :sample_data ){ (1 ..20).each }

      it "indicator raises an Error if period is one" do
        expect{  sample_data.calculate(:ema, period: 1) }.to raise_exception RuntimeError
      end

      it "indicator returns known values if period is four" do
        output= sample_data.calculate(:sma, period: 4, strict: true)
        expected_output = sample_data.drop(2).map( &:to_f)
        expect( output.drop(1) ).to eq expected_output[0..-3]
      end
    end
  end
end

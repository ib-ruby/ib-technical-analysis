
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::MovingAverage::EMA do
  before(:all) do
  end
  let( :input_data ){ read_sample_data.each }  #  Enumerator
  let( :period ){ 10 }

  context "check Input data" do
    subject { input_data }
    its( :size ){ is_expected.to eq 43 }
  end
  context "apply Indicator" do 
    subject { input_data.calculate( :ema, period: period ){ :close } }

    it { is_expected.to be_a Array }
    its( :size ){ is_expected.to eq 34 }
  end
 
  context "perform test calculations from synthetic data" do
    let( :sample_data ){ (1 ..20).each }

#    it "indicator returns original data if period is one" do
#      output= sample_data.calculate(:ema, period: 1)
#      expected_output = sample_data.map &:to_f
#      expect( output ).to eq expected_output
#    end

    it "indicator returns known values if period is three" do
      output= sample_data.calculate(:ema, period: 3)
      expected_output = sample_data.drop(1).map( &:to_f)
      expect( output ).to eq expected_output[0..-2]
    end

    it "indicator is equal to sma if period is three" do
      ema_output= sample_data.calculate(:ema, period: 3)
      sma_output= sample_data.calculate(:sma, period: 3)
    expect( ema_output ).to eq sma_output
    end
  end
end

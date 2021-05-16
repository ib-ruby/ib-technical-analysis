
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::MovingAverage::KAMA do
  before(:all) do
  end
  let( :input_data ){ read_stock_data.each }  #  Enumerator
  let( :period ){ 10 }
  let( :slow ){ 25 }
  let( :fast ){ 3 }

  context "check Input data" do
    subject { input_data }
    its( :size ){ is_expected.to eq 148 }
  end
  context "apply Indicator" do 
    subject { input_data.calculate( :kama, period: period , slow: slow, fast: fast){ :close } }

    it { is_expected.to be_a Array }
    its( :size ){ is_expected.to eq 148 }
  end
 

  context "perform test calculations from synthetic data" do
    let( :sample_data ){ (1 ..150).each }

    # the indicator cacluates the correction factor from the array provided as second argument.
    # Its thus possible to fine-tune kama by providing just the rigth entries in that array.
    it "use sample_data atomically"  do
      sample_item =  100
      kama =  TechnicalAnalysis::MovingAverage::KaMA.new period: period,
                                                         data: sample_data.take(sample_item -1),
                                                         fast: fast,
                                                         slow: slow

      expect(kama.current.round).to eq 96
      expect{ kama.add_item sample_data.to_a[sample_item] }.to change{ kama.current }.by 1.250000000001421

    end



#    it "indicator behaves like ema " do
#      ema_output = sample_data.calculate(:ema, period: 10)
#      kama_output = sample_data.calculate(:kama, period: 10)
#      puts 
#      puts kama_output
#      ema_output.each.with_index{|e,i| next if i <5; expect( (e - kama_output[i]).abs).to be > 3.25 }
#     ema_output.each.with_index{|e,i| next if i <5; expect( (e - kama_output[i]).abs).to be < 3.33 }
#    end
  end
end

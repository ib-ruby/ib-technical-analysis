
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::Momentum::Rsi do
  before(:all) do
  end


  context "dry test" , focus: true do
    it do
      rsi = TechnicalAnalysis::Momentum::Rsi.new period: 10 
      
      data = [100, 200, 100, 500, 600, 900, 800, 700, 600, 500 , 400, 300, 400, 500, 600]
      data.each{| d| rsi.add_item(d) }
      puts rsi.momentum
      expect(rsi.current).to  be < 100
    end
  end

  context "Enumerator.caculate" do
    let( :input_data ){ read_sample_data.each }  #  Enumerator
    let( :period ){ 25 }

    context "check Input data" do
      subject { input_data }
      its( :size ){ is_expected.to eq 43 }
    end
    context "apply Indicator" do 
      subject { input_data.calculate( :rsi, period: 25 ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq (43-(iperiod-1)) }
    end

  end
end

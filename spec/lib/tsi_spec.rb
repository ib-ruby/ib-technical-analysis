
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::Momentum::Tsi do
  before(:all) do
  end


  context "dry test" do
    it do
      tsi = TechnicalAnalysis::Momentum::Tsi.new low: 2, high: 8
      
      data = [100, 200, 200, 500, 600, 900, 800, 700, 600, 500 , 400, 300, 400, 500, 600]
      data.each{| d| tsi.add_item(d) }
      puts tsi.momentum
      expect(tsi.current).to  be < 1
    end
  end

  context "Enumerator.caculate" do
    let( :input_data ){ read_sample_data.each }  #  Enumerator
    let( :high ){ 25 }
    let( :low ){ 10 }

    context "check Input data" do
      subject { input_data }
      its( :size ){ is_expected.to eq 43 }
    end
    context "apply Indicator" do 
      subject { input_data.calculate( :tsi, high: high, low: low ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq (43-(high+low-1)) }
    end

  end
end

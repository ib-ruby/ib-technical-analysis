
require 'spec_helper'
require 'main_helper'

#  activate Enumerable extensions
using TASupport


RSpec.describe TechnicalAnalysis::Momentum::LaneStochastic do
  before(:all) do
  end


  context "dry test" do
    it do
      stochastics = TechnicalAnalysis::Momentum::Lane.new 
      
      data = [100, 200, 200, 500, 600, 900, 800, 700, 600, 500 , 400, 300, 400, 500, 600]
      data.each{| d| stochastics.add_item(d) }
      puts stochastics.lane
      expect(stochastics.current[:fast]).to  be < 1
      expect(stochastics.current[:slow]).to  be < 1
    end
  end

  context "Enumerator.caculate" do
    let( :input_data ){ read_sample_data.each }  #  Enumerator
    let( :fast ){ 5 }
    let( :slow ){ 10 }

    context "check Input data" do
      subject { input_data }
      its( :size ){ is_expected.to eq 43 }
    end
    context "apply Indicator" do 
      subject { input_data.calculate( :lane, fast: fast, slow: slow ){ :close } }

      it { is_expected.to be_a Array }
      its( :size ){ is_expected.to eq (43-(fast+slow-2)) }
    end

  end
end

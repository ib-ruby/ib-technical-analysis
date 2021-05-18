
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
    let(:data) { (1..1000).map{|y| y*1} }
    let(:expected)  { 2.824 }
    # factor = 2.0 / (4 + 1) = 0.4                   # factor =  2.0 / ( 2 + 1 )  =  2/3  (0,6666)
    # factor = 2.0 / (4 + 1) = 0.4                   # factor2=  1 - 2 / ( 2 + 1 )  =  1/3  (0,3333)
    # s_1 = 1                                        #  s1 = 1
    # s_2 = 0.4 * 2 + 0.6 * 1 = 1.4                  #  s2 =  2/3 * 2 + 1/3 * 1 = 1 2/3      (1.67)
    # s_3 = 0.4 * 3 + 0.6 * 1.4 = 2.04               #  s3 =  2/3 * 3 + 1/3 * 1 2/3 = 2 5/9  (2.56)
    # s_4 = 0.4 * 4 + 0.6 * 2.04 = 2.824             #  s3 =  2/3 * 4 + 1/3 * 2 5/9 =  3 14/27  (3.52)
    it "calculate in strict_mode ", focus: true do
      ema = TechnicalAnalysis::MovingAverage::Macd.new period: 4, fast: 2, slow: 4, strict: true 
      dx=data.map { |x| ema.add_item x }
      expect( dx.take(4).map{|y| y.fast &.round(2)}).to eq [nil, nil, nil, 3.52 ]
      expect( dx.take(4).map{|y| y.slow &.round(3)}).to eq [nil, nil, nil, 2.824 ]
      expect( dx.take(4).map{|y| y.macd &.round(3)}).to eq [nil, nil, nil, 0.695 ]  # slow - fast
      expect( dx.take(4).map{|y| y.signal}).to eq [nil, nil, nil, nil]  # slow - fast
    end
  end
end

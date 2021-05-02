module TechnicalAnalysis

  module Momentum 
    RSI = Struct.new :time, :value
    TSI = Struct.new :time, :value

    #
    # Calculates the true strength index (TSI) for the data over the given period
    # https://en.wikipedia.org/wiki/True_strength_index

    #
    # z = Symbols::Futures.mini_dax.eod( duration: '30 d').each
    # e= nil
    # ema= z.map{|y| e= TechnicalAnalysis::MovingAverage.ema( y.close, z.map(&:close), 30, e ) }
    # 
    # or
    #
    # EMA =  Struct.new :time, :ema
    # e = nil
    # ema = z.map do |y|
    #    EMA.new y.time, 
    #            e = TechnicalAnalysis::MovingAverage.ema y.close, z.map(&:close), 30, e
    # end           
    # 

    def self.tsi current_value, tsi_source, low_period = 13, high_period = 25
   
      if current_value.present? 
        tsi_source.push current_value 
      else
        current_value = tsi_source.last
      end

      momentum = tsi_source[-1] - tsi_source[-2]
      
      high_multiplier = (2.0 / (high_period + 1.0))
      low_multiplier = (2.0 / (low_period + 1.0))

      if prev_tsi.nil?
        data.sum / data.size.to_f # Average
      else
        (current_value - prev_ema) * (2.0 / (period + 1.0)) + prev_ema
      end
    end
  end
end

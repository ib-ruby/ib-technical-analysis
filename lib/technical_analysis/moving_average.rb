module TechnicalAnalysis

  module MovingAverage 
    SMA = Struct.new :time, :value
    EMA = Struct.new :time, :value
    WMA = Struct.new :time, :value


    # Calculates the exponential moving average (EMA) for the data over the given period
    # https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
    #
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

    def self.ema current_value, data, period, prev_ema
      if prev_ema.nil?
        data.sum / data.size.to_f # Average
      else
        (current_value - prev_ema) * (2.0 / (period + 1.0)) + prev_ema
      end
    end

    # Calculates the weighted moving average
    #
    # Parameter is the data-array. 
    #
    # Takes an optional Block. Specify a method name that returns  the data item
    #
    # z = Symbols::Futures.mini_dax.eod( duration: '30 d').each
    # TechnicalAnalysis::ArrayCalculation.wma( z ){ :close }
    #
    def self.wma(current_value, wma_source, period)
      interim = 0.0
      wma_source = wma_source[ -period , period ] if wma_source.size > period
      wma_source.map.with_index do |d, i|
        d = d.send yield  if block_given?
        interim += d * (i + 1) / (wma_source.size * (wma_source.size + 1) / 2).to_f
      end
    end


    # calculates the simple moving average of the current value using the data as reference
    #
    # if current_value is 
    def self.sma current_value=nil, data=[], period=15
      sma_source = if current_value.present?
                     data.push  current_value  #  add it as last element
                   else
                     data
                   end
      sma_source = sma_source[ -period , period ] if sma_source.size > period
      sma_source.sum / sma_source.size .to_f  

    end
  end
end


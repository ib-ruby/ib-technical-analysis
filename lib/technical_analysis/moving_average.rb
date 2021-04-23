module TechnicalAnalysis

  module MovingAverage 
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
    def self.wma(data)
      intermediate_values = []
      data.each_with_index do |datum, i|
        datum = datum.send yield  if block_given?
        intermediate_values << datum * (i + 1) / (data.size * (data.size + 1) / 2).to_f
      end
      intermediate_values.sum
    end
  end
end


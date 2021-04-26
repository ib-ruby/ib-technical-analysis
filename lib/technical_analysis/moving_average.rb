module TechnicalAnalysis

  module MovingAverage 
    SMA = Struct.new :time, :value
    EMA = Struct.new :time, :value
    WMA = Struct.new :time, :value
    KAMA = Struct.new :time, :value


    # Calculates the exponential moving average (EMA) for the data over the given period
    # https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
    #
    # Takes a block which replaces the _smooth-constant_
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

    def self.ema current_value, default_value, period,  prev_ema 
      raise "Period must be greater then one" if  period <= 1
      smooth_constant = if block_given? 
                          yield period
                        else
                          (2.0 / (period + 1.0))
                        end

    prev_ema.nil? ?  default_value.to_f : (current_value - prev_ema) * smooth_constant + prev_ema
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


    def self.kama current_value=nil, kama_source=[], period=30, fast=2, slow= 30, prev_kama
			
      # build the SmootingFactor (alpha)
      # fastest = 2 / GDperiod(fast) +1 ;  slowest = 2 / GDperiod(slow) +1 

      smoothConst_fast=2  / (fast +1).to_f
      smoothConst_slow=2  / (slow +1).to_f
      kama_source << current_value   if current_value.present?
      if data.size < 2 || prev_kama.nil?
        data.first			# returnValue
      else
          kama_source = kama_source[ -period , period ] if kama_source.size > period

          period = kama_source.size
          # define the Effiency Ratio to be used by the "kaufmans Adaptive Moving Average" :  kama 
          #				| x(t) - x(t-n) |
          # er = ----------------------------
          #			 sum | x(i) - x(i-1) |
          er=	(kama_source.first - kama_source(period)).abs  /  
            (1..period).map{|x| (kama_source[x] - kama_source[x-1]).abs }.sum  rescue 1

          alpha = (er  * ( smoothConst_fast - smoothConst_slow ) + smoothConst_slow ) ** 2

          alpha  + prev_kama * (kama_source[-1] -prev_kama)        
      end
    end
  end
end

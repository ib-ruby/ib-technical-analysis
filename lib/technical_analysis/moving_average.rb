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
    # Symbols::Futures.mini_dax.eod( duration: '30 d').map do | z |
    #    TechnicalAnalysis::MovingAverage.wma( z ){ :close }
    # end
    #
    def self.wma( current_value=nil, wma_source=[], period=0)
      wma_source.push current_value if current_value.present?
      if wma_source.size < period
        current_value
      else
        wma_source = wma_source[ -period , period ]  if wma_source.size > period && !period.zero?
        denominator =  wma_source.size * (wma_source.size + 1) / 2.0

        wma_source.map.with_index do |d, i|
          d = d.send( yield ).to_f  if block_given?
          d * (i + 1) / denominator
        end.sum
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

 # https://corporatefinanceinstitute.com/resources/knowledge/trading-investing/kaufmans-adaptive-moving-average-kama/
    def self.kama current_value=nil, kama_source=[], period=10, fast=2, slow= 30, prev_kama= nil
			# kama_source: Array of values (length: period)
      #              They are used to calculate trend and volatility

      # build the SmootingFactor (alpha)
      # fast = 2 / GDperiod(fast) +1 ;  slow = 2 / GDperiod(slow) +1 

      # kama_source is updated. 

      smoothConst_fast = 2 / (fast +1).to_f
      smoothConst_slow = 2 / (slow +1).to_f

      if current_value.present? 
        kama_source.push current_value 
      else
        current_value = kama_source.last
      end
      if  prev_kama.nil?
        kama_source.sum / kama_source.size.to_f			# return Average --> sma
      else
        kama_source = kama_source[ -period , period ] if kama_source.size > period
        # define the Effiency Ratio to be used by the "kaufmans Adaptive Moving Average" :  kama 
        # ER is calculated by dividing the absolute difference between the
        # current price and the price at the beginning of the period by the sum
        # of the absolute difference between each pair of closes during the
        # period.
          #				| x(t) - x(t-n) |
          # er = ----------------------------
          #			 sum | x(i) - x(i-1) |
          er=	(kama_source.first - kama_source.last).abs  /  
            (1..kama_source.size-1).map{|x| (kama_source[x] - kama_source[x-1]).abs }.sum # rescue 1
          alpha = (er  * ( smoothConst_fast - smoothConst_slow ) + smoothConst_slow ) ** 2
          prev_kama + alpha * (current_value - prev_kama)        
      end
    end
  end
end

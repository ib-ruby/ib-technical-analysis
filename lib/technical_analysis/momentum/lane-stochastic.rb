module TechnicalAnalysis
  module Momentum
    LANE = Struct.new :time, :value


=begin rdoc
Defines the Lane-Stochastics
           price   -     min(low)[period]
  %k =   -----------------------------------------------
          max(high)[period] -  min(low)[period]

The Stochastics may depend on
*  OHLC-Objects (IB::Bar).

Then <em>"close"</em> is taken as default-value of the current candle.

By specifiying the parameter <em>"take"</em> this can be customized.

=end
    class Lane
      #       attr :oversold, true
      #       attr :overbought, true

      def initialize period: 5,  fast: 3, slow: 3, data: [], strict: true, take: :close
        # note: strict is always true
        raise "Periods must be greater then one" if  period <= 1
        raise "fast must be smaller then slow" if  slow < fast 

        @queue = []
        @buffer = []
        @take =  take
        @smooth_2 = slow               # smooth-Const of StochasticsSlow
        @smooth_1 = fast               # smooth-Const of StochasticsFast
        @period = period               # period       of StochasticsLane
        @stochastics_fast = TechnicalAnalysis::MovingAverage::ExpMA.new( period: @smooth_1, strict: true)
        @stochastics_slow = TechnicalAnalysis::MovingAverage::ExpMA.new( period: @smooth_2, strict: true)
        if !data.empty?
          data.map{|d| add_item d }
        end

      end


      # adds item, calculates the ema, puts value to the buffer and returns the result
      def add_item  value
        is_ohlc = nil
        @queue << if value.is_a? IB::Bar
                    is_ohlc = true 
                    value
        else
          value.to_f
        end

        if @queue.size < @period
          @buffer << nil
        else
          @queue.shift if @queue.size > @period
          the_high = is_ohlc ? @queue.map(&:high).max : @queue.max 
          the_low = is_ohlc ? @queue.map(&:low).min : @queue.min
          # the value is :close by default. But can be :wap, :typical_price aso. 
          the_value = is_ohlc ?  value.send( @take ) : value
          k = ( the_value - the_low )/ ( the_high - the_low )
          @stochastics_fast.add_item k

          out_1 = if @stochastics_fast.current.present?
                    @stochastics_slow.add_item @stochastics_fast.current
                    @stochastics_fast.current
                  else
                    nil
                  end

          #puts "momentum:  #{@emas[:low].current} <--> #{@emas[:low_abs].current}"
          out_2 = if @stochastics_slow.current.present?   # warmup perioda is over
                    @stochastics_slow.current
                  else
                    nil
                  end
        end
        @buffer << { fast: out_1, slow: out_2 }

        current  #  return the last buffer value
      end

      # returns the ema-buffer
      def stochastics
        @buffer
      end

      alias lane stochastics 

      # returns the ema if the last computed item
      def current
        obj = @buffer.last
        if obj.values.compact.empty?
          nil
        else
          obj
        end
      end
    end

    # set alias for the class
    LaneStochastic =  Lane
  end
end

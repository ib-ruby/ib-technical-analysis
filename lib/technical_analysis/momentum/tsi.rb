module TechnicalAnalysis
  module Momentum
    TSI = Struct.new :time, :value

    class Tsi
=begin
                ExpMA(low) ( ExpMA(high ) prices  )
  TSI  =   ----------------------------------------------
            ExpMA(low) ( ExpMA(high ) prices.abs  )


While the TSI output is bound between +1 and −1, most values fall between +0.25 and −0.25. 
Blau suggests interpreting these values as overbought and oversold levels, respectively, 
at which point a trader may anticipate a market turn. 

Trend direction is indicated by the slope of the TSI; 
a rising TSI suggests an up-trend in the market, and a falling TSI suggests a down-trend

=end
    
      def initialize low: 13, high: 25, data: [], strict: true
        # strict is always true

        raise "Periods must be greater then one" if  low <= 1 || high <= 1
        raise "high must be greater then low" if  low > high 

        @queue = []
        @buffer = []
        @low= low
        @high = high

        @emas = { high:  TechnicalAnalysis::MovingAverage::ExpMA.new( period: high, strict: true ),
                  low:       TechnicalAnalysis::MovingAverage::ExpMA.new( period: low, strict: true  ),
                  high_abs:  TechnicalAnalysis::MovingAverage::ExpMA.new( period: high, strict: true  ),
                  low_abs:   TechnicalAnalysis::MovingAverage::ExpMA.new(  period: low, strict: true )  }

        if !data.empty?
          data.map{|d| add_item d }
        end
      end

      # adds item, calculates the ema, puts value to the buffer and returns the result
      def add_item  value
        @queue << value.to_f

        if @queue.size < 2
          @buffer << nil
        else
          momentum =  @queue.last - @queue[-2]
          @emas[:high].add_item momentum
          @emas[:high_abs].add_item momentum.abs

          if @emas[:high].current.present?
            @emas[:low].add_item @emas[:high].current
            @emas[:low_abs].add_item @emas[:high_abs].current
          end

          #puts "momentum:  #{@emas[:low].current} <--> #{@emas[:low_abs].current}"
          if @emas[:low].current.present?   # warmup perioda is over
            @buffer << @emas[:low].current / @emas[:low_abs].current
          end

          current  #  return the last buffer value
        end
      end

      # returns the ema-buffer
      def momentum 
        @buffer
      end

      # returns the ema if the last computed item
      def current
         @buffer.last
      end
    end

  end
end

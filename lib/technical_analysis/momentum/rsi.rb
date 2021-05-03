module TechnicalAnalysis
  module Momentum
    RSI = Struct.new :time, :value

    class Rsi
=begin

  
The RSI is calulated by

             ExpMA( Deltas of up-trending Periods )
  RSI  =   ----------------------------------------------
            ExpMA( Deltas of down-trending Periods )


 If the average of Delta values is zero, then according to the equation, the RS value will approach infinitiy
=end
    
      def initialize period: 15, data: [], strict: true
        # strict is always true

        raise "Periods must be greater then one" if period <= 1

        @queue = []
        @buffer = []
        @period= period

        @emas = [ TechnicalAnalysis::MovingAverage::ExpMA.new( period: period, strict: true ),
                  TechnicalAnalysis::MovingAverage::ExpMA.new( period: period, strict: true  ) ]

        if !data.empty?
          data.map{|d| add_item d }
        end
      end

      # adds item, calculates the ema, puts value to the buffer and returns the result
      def add_item  value
        @queue << value.to_f

        up_or_down =  -> (previous, actual) do
          if actual >= previous
            [actual-previous,0]
          else
            [0,previous-actual]
          end
        end

        if @queue.size < 2
          @buffer << nil
        else
          # up-trend-data are added to @emas.first, downtrend-data to @emas.last
          # the lambda up_and_down always returns positve data (or "0")

          @emas.zip( up_or_down[ *@queue[-2,2] ] ).each { | exp_ma, item | exp_ma.add_item item }

          if @emas.first.current.present?
            @buffer <<  100 - ( 100 / (1 + ( @emas.first.current / @emas.last.current rescue 100 ) ) )
          end

          current   #  return the last buffer value
        end
      end

      # returns the ema-buffer
      def  momentum
        @buffer
      end

      # returns the ema if the last computed item
      def current
        @buffer.last
      end
    end

  end
end

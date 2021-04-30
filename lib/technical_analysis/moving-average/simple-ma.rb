module TechnicalAnalysis
  module MovingAverage
    SMA = Struct.new :time, :value


    # Calculates the exponential moving average (EMA) for the data over the given period
    # https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
    #
    # Takes a block which replaces the _smooth-constant_
    #
    #   z = Symbols::Futures.mini_dax.eod( duration: '90 d')
    #   TechnicalAnalysis::MovingAverage::ExpMA.new( data=z.map(&:close))
    #
    # returns an array with the calculated moving-average data
    #
    #   ema = TechnicalAnalysis::MovingAverage::ExpMA.new( default_value = z.first[:close])
    #   moving_average = z.map{|x| EMA.new x.time,  ema.add_item(x.close)} 
    #
    # returns an array of EMA-Objects
    # 

    class SimpleMA  < Base
      def initialize period: 15, data: [], strict: false

        super

        data.map{|d| add_item d }
      end

      # adds item, calculates the sma, puts value to the buffer and returns the result
      def add_item  value

        @queue << value.to_f
        @queue.shift if @buffer.size > @period

        @buffer <<  @queue.sum / @queue.size    # @queue.sum is always a float. 

       current  #  return the last buffer value
      end
    end
  end
end

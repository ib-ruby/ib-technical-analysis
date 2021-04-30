module TechnicalAnalysis
  module MovingAverage
    EMA = Struct.new :time, :value


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

    class ExpMA  < Base
      def initialize period: 15, data: [], strict: true
        super

        @smooth_constant = if block_given? 
                             yield period
                           else
                             (2.0 / (period + 1.0))
                           end
        if !data.empty?
          data.map{|d| add_item d }
        end
      end

      # adds item, calculates the ema, puts value to the buffer and returns the result
      def add_item  value
        @queue << value
        @queue.shift if @queue.size > @period
        if @buffer.empty?
          @buffer=[value.to_f]
        else
          prev_ema = @buffer.last
          current_value = value.to_f
          @buffer << (current_value - prev_ema) * @smooth_constant + prev_ema
        end
       current  #  return the last buffer value
      end

    end

  end
end

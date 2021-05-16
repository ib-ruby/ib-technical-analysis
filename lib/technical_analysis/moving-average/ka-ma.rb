module TechnicalAnalysis
  module MovingAverage
    KAMA = Struct.new :time, :value


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

    class KaMA
      def initialize period: 10, fast: 2, slow: 30, data: [], **params

        raise "Period must be greater then one" if  period <= 1

        @smoothConst_fast = 2 / (fast +1).to_f
        @smoothConst_slow = 2 / (slow +1).to_f

        @period = period
        @queue = []
        @buffer = []
        
        if !data.empty?
          data.map{|d| add_item d }
        end
      end

      # adds item, calculates the kama, puts value to the buffer and returns the result
      def add_item  value
        begin
        @queue << value.to_f
      rescue NoMethodError => e
        puts "add item only supports single values. Using the :close method"
        @queue << value.send(:close) || value
        end
        if @queue.size < @period
          @buffer = [ @queue.sum / @queue.size ]  # fill buffer with  average
        else
          @queue.shift if @queue.size > @period
          @buffer << calculate
        end
        current #  return the last buffer value
      end

      # returns the kama-buffer
      def kama
        @buffer
      end

      # returns the kama of the last computed item
      def current
         @buffer.last
      end

      private
      def calculate
        # define the Effiency Ratio to be used by the "kaufmans Adaptive Moving Average" :  kama 
        # ER is calculated by dividing the absolute difference between the
        # current price and the price at the beginning of the period by the sum
        # of the absolute difference between each pair of closes during the
        # period.
        #				| x(t) - x(t-n) |
        # er = ----------------------------
        #			 sum | x(i) - x(i-1) |

        er= (@queue.first - @queue.last).abs /
            (1..@queue.size-1).map{|x| (@queue[x] - @queue[x-1]).abs }.sum # rescue 1

        alpha = (er * ( @smoothConst_fast - @smoothConst_slow ) + @smoothConst_slow )**2
        prev_kama = @buffer.last
        current_value = @queue.last

        @buffer.last + alpha * (current_value - prev_kama)
      end

    end

  end
end

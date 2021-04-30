module TechnicalAnalysis
  module MovingAverage



    class  Base
      def initialize period: 15,  data: [], strict: true

        raise "Period must be greater then one" if  period <= 1
        @period = period
        @strict= strict
        # queue for relevant data to process the calculation
        @queue =  []
        # buffer contains the calculated indicator values
        @buffer = []
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

      # returns the moving-average-buffer
      def ma 
        if @strict
          @buffer.drop @period-1
        else
          @buffer
        end
      end


      # returns the ema of the last computed item
      def current 
         if @strict && warmup?
           nil
         else
           @buffer.last
         end
      end

      private

      def warmup?
        @queue.size < @period
      end
    end

  end
end

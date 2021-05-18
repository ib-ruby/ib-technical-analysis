module TechnicalAnalysis
  module MovingAverage



    class  Base
      def initialize period: 15,  data: [], strict: true, **parans

        raise "Period must be greater then one" if  period <= 1
        @period = period
        @strict= strict
        # queue for relevant data to process the calculation
        @queue =  []
        # buffer contains the calculated indicator values
        @buffer = []
      end

      # adds item, calculates the ma, puts value to the buffer and returns the result
      # needs to be overloaded
      def add_item  value
        @queue << value
        @queue.shift if @queue.size > @period
        @buffer << value
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


      # returns the ma of the last computed item
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

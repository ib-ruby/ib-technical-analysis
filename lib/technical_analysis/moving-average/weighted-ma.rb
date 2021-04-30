module TechnicalAnalysis
  module MovingAverage

    WMA = Struct.new :time, :value

    class Wma < Base
      def initialize period: 15, data: [], strict: true
        super
        @denominator =  (1..@period).sum
        data.map{|d| add_item d }
      end

      # adds item, calculates the sma, puts value to the buffer and returns the result
      def add_item  value

        @queue << value.to_f
        @queue.shift if @queue.size > @period
        weights = (1..@queue.size).to_a
        nominator = weights.zip(@queue).map { |w, x| w * x }.sum
        @buffer << nominator / @denominator 
       current  #  return the last buffer value
      end
    end
  end
end

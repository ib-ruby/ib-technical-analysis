require 'dry/core/class_attributes'

module TechnicalAnalysis
  module BarCalculation

    def true_range previous_close
      [
        (high - low),
        (high - previous_close).abs,
        (low - previous_close).abs
      ].max
    end

    def typical_price
      ( high + low + close ) / 3.0
    end
  end



  module MovingAverage 
    EMA = Struct.new :time, :value
    WMA = Struct.new :time, :value


    # Calculates the exponential moving average (EMA) for the data over the given period
    # https://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
    #
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

    def self.ema current_value, data, period, prev_ema
      if prev_ema.nil?
        data.sum / data.size.to_f # Average
      else
        (current_value - prev_ema) * (2.0 / (period + 1.0)) + prev_ema
      end
    end

    # Calculates the weighted moving average
    #
    # Parameter is the data-array. 
    #
    # Takes an optional Block. Specify a method name that returns  the data item
    #
    # z = Symbols::Futures.mini_dax.eod( duration: '30 d').each
    # TechnicalAnalysis::ArrayCalculation.wma( z ){ :close }
    #
    def self.wma(data)
      intermediate_values = []
      data.each_with_index do |datum, i|
        datum = datum.send yield  if block_given?
        intermediate_values << datum * (i + 1) / (data.size * (data.size + 1) / 2).to_f
      end
      intermediate_values.sum
    end
  end
end

## reopen IB::Bar and include BarCalculation  ( as Mixin  )

module IB
  class Bar
    include TechnicalAnalysis::BarCalculation
  end
    # z= Symbols::Futures.mini_dax.eod( duration: '30 d').each
    #
    # loop do
    #  bar= z.next
    # puts bar.time, z.peek.true_range(bar.close)
    # end.

    # z.rewind
    #
    # z.map{ |y| x.typical_price }
    #
end           # module

module  TASupport
  refine Enumerator do
    #
    # first include 
    #   using TASupport
    # in your script.
    #
    # After fetching stock-data from a file, a database or the broker  and 
    # converting it into an Enumerator (simply using array.each)
    # 
    #   calculate
    #
    # is just performed on the object
    #
    # The result is returned as array of structs. 
    #
    # z = Symbols::Futures.mini_dax.eod( duration: '50 d').each
    # z.calculate { :close }
    #
    # zz= z.calculate( :ema ){ :typical_price }
    # 
    # zz= z.calculate( :ema, period: 3 ) { :close } 
    # zz.first
    #  => #<struct TechnicalAnalysis::MovingAverage::EMA time=Wed, 10 Mar 2021, value=0.149441e5
    def calculate indicator= :ema,  **params
      struct =  TechnicalAnalysis::MovingAverage.send :const_get, indicator.to_s.upcase 
      buffer, start = nil, []
      choice = if block_given? 
                 yield  
               elsif peek.respond_to?(:time)
                 :close
               else
                 nil
               end
      data = choice.nil? ? self.to_a : map{|y| y.send choice }
      period = params[:period] || 30
      calc_ema =  ->(item){ buffer= TechnicalAnalysis::MovingAverage.ema item, data, period, buffer  }

      if peek.respond_to? :time 
        map{ | d |
          value = case indicator
                  when :ema
                    calc_ema[ d.send choice  ]
                  when :wma
                    TechnicalAnalysis::MovingAverage.wma start << d.send( choice )
                  end
          struct.new d.time , value
        }#map
      else
        case indicator
        when :ema
          map{ | d |  calc_ema[  choice.nil? ?  d : d.send( choice ) ] }
        when :wma
          map{ |d| TechnicalAnalysis::MovingAverage.wma( start << choice.nil? ?  d : d.send( choice )  ) }
        end # case
      end   # branch    
    end     # def
  end       # refine
end         # module


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
      struct = TechnicalAnalysis::MovingAverage.send :const_get, indicator.to_s.upcase
      buffer, start, default_value = nil, [], nil
      choice = if block_given? 
                 yield  
               elsif peek.respond_to?(:time)
                 :close
               else
                 nil
               end
      period = params[:period] || 30
      fast = params[:fast] || 2
      slow= params[:slow] || 30

      calc_default_value = ->( warmup ){  ( choice.nil? ? take(warmup) : take(warmup).map{ |x| x.send choice }).sum / warmup }
      calc_ema = ->(item) do
        # calculate the start-value only if necessary
        buffer = TechnicalAnalysis::MovingAverage.ema item, default_value, period, buffer 
      end
      calc_kama = ->(item) { start << item;  buffer = TechnicalAnalysis::MovingAverage.kama item, start, period, fast, slow, buffer }
      #
      ## take a look to the first dataset ot the time series.
      ## and determine the date-field for the input-data
      a = peek
      date_field = if a.respond_to? :time
                     :time
                   elsif a.respond_to? :date_time
                     :date_time
                   elsif a.respond_to? :date
                     :date
                   else
                     nil
                   end

      ## iterate across the enumerator and return the result of the calculations
      map.with_index { | d, i |
        raw_data = if date_field.present? || choice.present?
                     d.send(choice)
                   else
                     d
                   end
        value = case indicator
                when :sma
                  if i+1 < period    # warmup period
                    default_value ||= calc_default_value[period]
                    start.push raw_data
                    next  #  just produce a nil element
                  else
                    TechnicalAnalysis::MovingAverage.sma nil, start.push( raw_data ), period
                  end
                when :ema
                  if i+1 < period 
                    default_value ||= calc_default_value[period]
                    next  #  just produce a nil object
                  else 
                  calc_ema[ raw_data ]
                  end
                when :kama
                  calc_ema[ raw_data ]
                when :wma
                  TechnicalAnalysis::MovingAverage.wma nil, start.push( raw_data ), period
                end
        ## data-format of the returned array-elements
        if date_field.present?
          struct.new d.send(date_field), value
        else
          value
        end
      }.compact     # map
    end     # def
  end       # refine
end         # module

##  notes on Enumerators
#-  z:= An Enumerator
#-  z.size == z.count
#-  z.entries == z.to_a
#-  z.take n   returns an array of the first n elements
#-  z.sum, if enumerator-objects define a "+" method
#

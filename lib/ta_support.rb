
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
    #
    #  Input-data are converted to float and then applied to the indicator-calculations
    def calculate indicator= :ema,  **params
      struct = if indicator.to_s[-2,2]=='ma'
                 TechnicalAnalysis::MovingAverage.send :const_get, indicator.to_s.upcase 
               elsif indicator.to_s[-2,2]=='si'
                 TechnicalAnalysis::Momentum.send :const_get, indicator.to_s.upcase 
               end
      buffer, start, default_value = nil, [], nil
      
      ## strict-mode
      strict_mode =  params[:strict] || false

      choice = if block_given? 
                 yield  
               elsif peek.respond_to?(:time)
                 :close
               else
                 nil
               end
      ## fill in defaults
      case indicator
      when :ema, :wma, :sma
        period = params[:period] || 15
      when :kama
        period = params[:period] || 15
        fast = params[:fast] || 2
        slow= params[:slow] || 30
      when :tsi
        high = params[:high] || 25
        low = params[:low] || 13
      end 

      # start (array of processed values) is updated in every iteration
      # applies to indicators 
      # kama
      # sma
      # wma
      #
      a =  peek
      date_field = if a.respond_to? :time
                     :time
                   elsif a.respond_to? :date_time
                     :date_time
                   elsif a.respond_to? :date
                     :date
                   else
                     nil
                   end
      indicator_method =  case indicator
                          when :sma, :simple_ma
                            TechnicalAnalysis::MovingAverage::SimpleMA.new period: period, strict: strict_mode
                          when :ema, :exp_ma
                            TechnicalAnalysis::MovingAverage::ExpMA.new period: period, strict: strict_mode
                          when :wma 
                            TechnicalAnalysis::MovingAverage::Wma.new period: period, strict: strict_mode
                          when :kama
                            TechnicalAnalysis::MovingAverage::KaMA.new period: period, strict: strict_mode,
                               fast: fast, slow: slow
                          when :tsi
                            TechnicalAnalysis::Momentum::Tsi.new  low: low, high: high, strict: strict_mode

                          end
      ## iterate across the enumerator and return the result of the calculations
      map.with_index { | d, i |
        # central point to convert to float
        raw_data = if date_field.present? || choice.present?
                     d.send(choice).to_f
                   else
                     d.to_f
                   end
        indicator_method.add_item(raw_data)
        next if indicator_method.current.nil? # creates a nil entry 
        value = indicator_method.current      # return this value
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

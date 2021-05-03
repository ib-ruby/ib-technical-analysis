
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
    # z = Symbols::Futures.mini_dax.eod( duration: '150 d').each
    # z.calculate use: :close 
    #
    # zz= z.calculate :ema, use: :typical_price 
    # 
    # zz= z.calculate( :ema, period: 3, use: :close 
    # zz.first
    #  => #<struct TechnicalAnalysis::MovingAverage::EMA time=Wed, 10 Mar 2021, value=0.149441e5
    #
    # Input-data are converted to float and then applied to the indicator-calculations
    #
    # A block can be provided to execute commands after calculating each single indicator value
    # This is provided to enable backtests on the data
    #
    # The block gets the input-data **and** the calculated indicator struct. 
    #
    # i.e.
    # buffer=[]
    # zz= z.calculate( :ema, use: :typical_price ) do | raw, struct | 
    #    buffer << struct.value
    #    buffer.shift if buffer.size >2
    #    momentum_indicator =  (buffer.first - buffer.last) <=> 0
    #    crossing = case momentum_indicator
    #         when +1
    #           buffer.first > raw.close && buffer.last < raw.close
    #         when -1
    #           buffer.first < raw.close && buffer.last > raw.close
    #         end
    #    buy_or_sell =  momentum_indicator == 1 ? "buy" : "sell"
    #    puts "#{buy_or_sell}-Signal: EMA-Indicator-Crossing @ #{struct.time}" if crossing
    # end
    #
    #
    def calculate indicator= :ema,  **params
      struct = if indicator.to_s[-2,2]=='ma'
                 TechnicalAnalysis::MovingAverage.send :const_get, indicator.to_s.upcase 
               elsif indicator.to_s[-2,2]=='si' || indicator== :lane
                 TechnicalAnalysis::Momentum.send :const_get, indicator.to_s.upcase 
               end
      buffer, start, default_value = nil, [], nil
      
      ## strict-mode
      strict_mode =  params[:strict] || false

      choice = if params[:use].present? 
                 params[:use]
               elsif peek.respond_to?(:time)
                 :close
               else
                 nil
               end
      ## fill in defaults
      case indicator
      when :ema, :wma, :sma, :rsi
        period = params[:period] || 15
      when :kama
        period = params[:period] || 15
        fast = params[:fast] || 2
        slow= params[:slow] || 30
      when :tsi
        high = params[:high] || 25
        low = params[:low] || 13
      when :lane
        period = params[:period] || 10
        fast = params[:fast] || 3
        slow= params[:slow] || 3

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
                          when :rsi
                            TechnicalAnalysis::Momentum::Rsi.new  period: period 
                          when :tsi
                            TechnicalAnalysis::Momentum::Tsi.new  low: low, high: high
                          when :lane
                            TechnicalAnalysis::Momentum::Lane.new  slow: slow, fast: fast, period: period,
                              take: choice
                          end
      ## iterate across the enumerator and return the result of the calculations
      map.with_index { | d, i |
        # central point to convert to float
        unless indicator == :lane
          raw_data = if date_field.present? || choice.present?
                     d.send(choice).to_f
                   else
                     d.to_f
                   end
          indicator_method.add_item(raw_data)
        else
          indicator_method.add_item(d)
        end

        next if indicator_method.current.nil? # creates a nil entry 
        value = indicator_method.current      # return this value
        ## data-format of the returned array-elements
        result =  if date_field.present?
                    struct.new d.send(date_field), value
                  else
                    value
                  end
        # expose the input-data and the calculated indicator to the block
        yielder = yield( d, result)  if block_given?
        yielder.nil? ?  result  : yielder   #  return the expression from the block  if present
      }.compact     # map
    end     # def

=begin
 Iterates through the Enumerator and returns predefined signals

 Parameters: what:  a signal, defined as proc
             indicators: a Hash: { indicator-symbol => { parameter that define the indicator } }
=end
    def analyse what, **indicators
      
    end
  end       # refine
end         # module

##  notes on Enumerators
#-  z:= An Enumerator
#-  z.size == z.count
#-  z.entries == z.to_a
#-  z.take n   returns an array of the first n elements
#-  z.sum, if enumerator-objects define a "+" method
#

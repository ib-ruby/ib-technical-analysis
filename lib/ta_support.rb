
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
      buffer, start = nil, []
      choice = if block_given? 
                 yield  
               elsif peek.respond_to?(:time)
                 :close
               else
                 nil
               end
      data = choice.nil? ? self.to_a : map {|y| y.send choice }
      period = params[:period] || 30
      calc_ema = ->(item) { buffer = TechnicalAnalysis::MovingAverage.ema item, data, period, buffer }
      calc_sma = ->(data_items) { TechnicalAnalysis::MovingAverage.sma nil, data_items, period }
      if peek.respond_to? :time 
        map{ | d |
          value = case indicator
                  when :sma
                    calc_sma[ start.push( d.send( choice)) ]
                  when :ema
                    calc_ema[ d.send choice ]
                  when :wma
                    TechnicalAnalysis::MovingAverage.wma( nil, start.push( d.send( choice )), period )
                  end
          struct.new d.time , value
        }#map
      else
        case indicator
        when :sma
          map{ | d | start.push( choice.nil? ? d : d.send( choice )) ; calc_sma[ start ] }
        when :ema
          map{ | d | calc_ema[ choice.nil? ? d : d.send( choice ) ] }
        when :wma
          map{ |d| TechnicalAnalysis::MovingAverage.wma(nil,  start.push( choice.nil? ? d : d.send( choice ) ), period ) }
        end # case
      end   # branch    
    end     # def
  end       # refine
end         # module

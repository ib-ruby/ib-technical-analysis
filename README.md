# IB-Technical-Analysis
A library for performing technical analysis

This Gem is inspired by the [intrinio package](https://github.com/intrinio/technical-analysis). However, `IB-Technical-Analysis` focusses on 
calculation of indicators from a stream of data. 

It fits perfectly into the **_IB-Ruby_** suite, but can be used isolated, too.

### Indicator classes

Indicators live in the `TechnicalAnalysis` namespace:
```ruby
TechnicalAnalysis::MovingAverage::SimpleMA
TechnicalAnalysis::MovingAverage::ExpMA
TechnicalAnalysis::MovingAverage::Wma
TechnicalAnalysis::MovingAverage::Macd
TechnicalAnalysis::MovingAverage::KaMA
TechnicalAnalysis::Momentum::Rsi
TechnicalAnalysis::Momentum::Tsi
TechnicalAnalysis::Momentum::Lanea (Stochastics)
```

Additional calculations on single Bars are defined as extension of `IB::Bar`:
 
* typical_price
* pivot
* true_range

##### Common Interface
The indicators are initialized by
```ruby
  indicator = TechnicalAnalysis::MovingAverage::KaMA.new period: 30, fast: 5, slow: 15, data: {an Array}
```

If an Array is passed, the indicator is calculated immediately.

Subsequent data elements are passed by `indicator.add_item {value}`. 
The calculated indicator is returned for further processing. 






### Perform calculation on time-series


`IB-Technical-Analysis` calculations are embedded in the `Enumerator`-class.

The List is simply iterated. 

Thus
```ruby
require 'bundler/setup'
require 'ib-gateway'
require 'ib/eod'
require 'ib/symbols'
require 'technical-analysis'

using TASupport

z = Symbols::Futures.mini_dax.eod( duration: '50 d').each
zz= z.calculate( :ema, period: 15 , use: :close 
zz.first
=> #<struct TechnicalAnalysis::MovingAverage::EMA time=Wed, 10 Mar 2021, value=0.149524e5> 

```
calculates the _Exponential Moving Average_ on the _close_ property of each item in the 
Enumerator returned by the [contract.eod](https://ib-ruby.github.io/ib-doc/Historical_data.html) method.

The same using a conventional array:
```ruby
u =  z.map( &:close ).each
uu=  u.calculate( :ema, period: 15 ) 
uu.first
=> 0.149524e5 
```

### Signals and Backtesting

The `calculate`-method of Enumerator passes raw-data and calculated indicator-values to an optional block.
This enables the formulation of signal generators.

```ruby
buffer=[]
zz= z.calculate( :ema, period: 5, use: :typical_price ) do | raw, struct | 
   buffer << struct.value
   buffer.shift if buffer.size >2
   momentum_indicator =  (buffer.first - buffer.last) <=> 0
   crossing = case momentum_indicator
        when +1
          buffer.first > raw.close && buffer.last < raw.close
        when -1
          buffer.first < raw.close && buffer.last > raw.close
        end
   buy_or_sell =  momentum_indicator == 1 ? "buy" : "sell"
   puts "#{buy_or_sell}-Signal: EMA-Indicator-Crossing @ #{struct.time}" if crossing
end

```


### Implemented Indicators

* Simple Moving Average                   
```ruby
zz = z.calculate :sma, period: 15, use: :close 
```
* Exponential Moving Average
```ruby
zz = z.calculate :ema, period: 15  
```
* Weighted Moving Average
```ruby
zz = z.calculate :wma, period: 15 
```
*  Moving Average Convergence Divergence
```ruby
zz = z.calculate :macd, signal: 9, fast: 12, slow: 24 
zz = z.calculate :macd, period: 9, fast: 12, slow: 24 
```
* Kaufman Moving Average
```ruby
zz = z.calculate :kama, period: 15, fast: 10, slow: 3 
```
* Relative Strength Index
```ruby
zz = z.calculate :rsi, period: 15 
```
* True Strength Index
```ruby
zz = z.calculate :tsi, high: 15, low: 7 
```
* Lane Stochastic  
```ruby
zz = z.calculate :lane, period: 10, fast: 3, slow: 3 , use: :wap 
```





(work in progress)




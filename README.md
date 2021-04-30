# ib-technical-analysis
A library for performing technical analysis

This Gem is inspired by the [intrinio package](https://github.com/intrinio/technical-analysis). However, `IB-Technical-Anaysis` focusses on 
calculation of indicators from a stream of data. 

It fits perfectly into the **_IB-Ruby_** suite, but can be used isolated, too.

### Indicator classes

Indicators live in the `TechnicalAnalysis` namespace:
```ruby
TechnicalAnalysis::MovingAverage::SimpleMA
TechnicalAnalysis::MovingAverage::EspMA
TechnicalAnalysis::MovingAverage::Wma
TechnicalAnalysis::MovingAverage::KaMA
TechnicalAnalysis::Momentum::Tsi
```
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
zz= z.calculate( :ema, period: 15 ){ :close }
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


### Implemented Indicators

* Simple Moving Average                   
```ruby
zz = z.calculate( :sma, period: 15 ) { :close }
```
* Exponential Moving Average
```ruby
zz = z.calculate( :ema, period: 15 ) { :close }
```
* Weighted Moving Average
```ruby
zz = z.calculate( :wma, period: 15 ) { :close }
```
* Kaufman Moving Average
```ruby
zz = z.calculate( :kama, period: 15, fast: 10, slow: 3 ) { :close }
```
* True Strength Index
```ruby
zz = z.calculate( :tsi, high: 15, low: 7 ) { :close }
```





(work in progress)




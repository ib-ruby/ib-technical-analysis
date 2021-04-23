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
end

module IB
  class Bar
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

    def pivot 
      { pp: p=( high + close + low ).to_f / 3 ,
        r1: ( 2 * p ).to_f - low.to_f,
        r2: p + ( high - low ).to_f,
        s1:  ( 2 * p ).to_f - high.to_f,
        s2: p - ( high - low ).to_f }
    end
  end
end

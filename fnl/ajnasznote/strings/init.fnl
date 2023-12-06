(fn trim [s]
  (string.gsub (string.gsub s "%s+$" "") "^%s+" "" ))

{ :trim trim }

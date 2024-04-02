(fn remove_accent_chars [name]
  (let [chars {
               "á" "a"
               "é" "e"
               "í" "i"
               "ó" "o"
               "ö" "o"
               "ő" "o"
               "ú" "u"
               "ü" "u"
               "ű" "u"
               "Á" "A"
               "É" "E"
               "Í" "I"
               "Ó" "O"
               "Ö" "O"
               "Ő" "O"
               "Ú" "U"
               "Ü" "U"
               "Ű" "U"
               }]
    (var n name)
    (each [key char (pairs chars)]
      (set n (vim.fn.substitute n key char "g"))
      ) n)
  )

(fn remove_leading_char [char input]
  (if (= char (string.sub input 1 1))
    (remove_leading_char char (string.sub input 2))

    input))
(fn to_en_only_file_name [name]
  (string.lower
    (remove_leading_char
      "_"
      (string.gsub (remove_accent_chars name) "[^%a%d_-]+" "_"))))



(fn to_safe_file_name [name]
  (to_en_only_file_name name)
  )

{ :to_safe_file_name to_safe_file_name }

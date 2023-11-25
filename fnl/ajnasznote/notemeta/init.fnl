(fn getbufoneline [bufnr line] (vim.fn.getbufoneline bufnr line))
; it should find yaml metadata from the beginning of the file
; and ignore the rest of the file
; and return a dict of the metadata
; metadata starts with line --- and ends with line ---
(fn meta_read [bufnr start_line end_line]
  (var meta_dict {})
  (var line start_line)
  (var current_key nil)
  (while (< line end_line)
    (local line_str (getbufoneline bufnr line))

    (if (vim.startswith line_str "  -")
      (do
        (let [val (vim.fn.trim (vim.fn.substitute line_str "^  -" "" ""))]
          (when (= (. meta_dict current_key) nil) (do (tset meta_dict current_key [])))
          (table.insert (. meta_dict current_key) val))
        )
      (do
        (local line_list (vim.fn.split line_str ": "))
        (set current_key (vim.fn.trim (vim.fn.substitute (. line_list 1) ":$" "" "")))
        (tset meta_dict current_key nil)
        (when (. line_list 2)
          (let [value (vim.fn.trim (. line_list 2))] (tset meta_dict current_key value))
          )))
    (set line (+ line 1))
  )
  meta_dict
)

(fn get_meta_end_line [bufnr]
  (var meta_end_line nil)
  (let [
        last_line (vim.fn.line "$")
        ]
    (var line 2)
    (while (and (= meta_end_line nil) (<= line last_line))
      (if
        (= (vim.fn.getline line) "---")
        (set meta_end_line line)
        (set line (+ line 1)))
      )
    )
  meta_end_line
  )

(fn get_meta_dict [bufnr]
  (if (= (getbufoneline (or bufnr (vim.fn.bufnr "")) 1) "---")
    (let [end_line (get_meta_end_line (or bufnr (vim.fn.bufnr "")))]
      (when end_line (meta_read (or (vim.fn.bufnr "") 1) 2 end_line))
      )
  nil)
)

{
 :get_meta_dict get_meta_dict
 :get_meta_end_line get_meta_end_line
 }

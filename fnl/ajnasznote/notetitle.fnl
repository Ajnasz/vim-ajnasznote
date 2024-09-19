
(fn strip_md_from_title [title]
  (vim.fn.substitute title "^#\\+\\s*" "" ""))

(fn get_buf_title [bufnr]
  (local notemeta (require :ajnasznote.notemeta))
  (let [ meta_title (notemeta.get_meta_title bufnr) ]
    (or meta_title (notemeta.get_h1 bufnr))
    )
  )


(fn get_title [bufnr]
  (strip_md_from_title (get_buf_title (or bufnr 0))))

(fn get_note_title [path]
    (or (get_title (vim.fn.bufnr path true)) (vim.fn.fnamemodify path ":t")))

{
 :get_note_title get_note_title
 :get_title get_title
 }

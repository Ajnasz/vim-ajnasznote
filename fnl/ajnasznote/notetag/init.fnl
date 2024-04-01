(local list (require "ajnasznote.list"))

(fn tolist [list] (if (= (type list) "table") list [list]))

(fn buffer_has_tag [tags tag]
  (var has_tag false)
  (each [_ ltag (ipairs tags) :until has_tag]
    (set has_tag (= tag ltag)))
  has_tag)

(fn find_matching_tag [tags buffer_tags]
  (when (> (length tags) 0)
    (let [ pattern (. (. tags 1) :pattern) ]
      (list.find
        (fn [tag]
          (let [patterns (. tag :pattern)]
            (list.has_all (tolist patterns) buffer_tags)))
        tags))))


(fn get_tags []
  (local notemeta (require "ajnasznote.notemeta"))
  (local meta_tags (notemeta.get_tags))
  (if (and meta_tags (> (length meta_tags) 0))
    (icollect [_ v (ipairs meta_tags)] (.. "@" v))
    (vim.fn.split (vim.fn.getline 3) "\\s\\+"))
  )

(fn buffer_get_tags []
  (accumulate
    [
     out []
     _ word (ipairs (get_tags))
     ]
    (if (= (string.sub word 1 1) "@")
      (do (tset out (+ 1 (length out)) word) out)
      out)
    )
  )

(fn get_matching_tag [tags]
  (let [matching_tag (find_matching_tag tags (buffer_get_tags))]
    (when matching_tag (. matching_tag "path")))
  )

(fn get_tag_path_file_dir [tag_path]
  (vim.fn.fnameescape (vim.fn.expand (string.format "%s/%s" vim.g.ajnasznote_directory tag_path))))

(fn add_match_tags [tags]
  (when (not vim.g.ajnasznote_match_tags)
    (set vim.g.ajnasznote_match_tags []))
  (set vim.g.ajnasznote_match_tags (vim.list_extend vim.g.ajnasznote_match_tags tags)))



{
 :get_tag_path_file_dir get_tag_path_file_dir
 :add_match_tags add_match_tags
 :get_matching_tag get_matching_tag
 }

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


(fn get_tag_path [tags buffer_tags]
  (let [matching_tag (find_matching_tag tags buffer_tags)]
    (when matching_tag (. matching_tag "path"))))


(fn get_tags [] (vim.fn.getline 3))

(fn buffer_get_tags []
  (accumulate
    [
     out []
     _ word (ipairs (vim.fn.split (get_tags) "\\s\\+"))
     ]
    (if (= (string.sub word 1 1) "@")
      (do (tset out (+ 1 (length out)) word) out)
      out)
    )
  )

(fn get_matching_tag [tags]
  (get_tag_path tags (buffer_get_tags)))

(fn get_tag_path_file_dir [tag_path]
  (vim.fn.fnameescape (vim.fn.expand (string.format "%s/%s" vim.g.ajnasznote_directory tag_path))))

(fn add_match_tags [tags]
  (when (not vim.g.ajnasznote_match_tags)
    (set vim.g.ajnasznote_match_tags []))
  (set vim.g.ajnasznote_match_tags (vim.list_extend vim.g.ajnasznote_match_tags tags)))


{
 :get_tags get_tags
 :get_tag_path_file_dir get_tag_path_file_dir
 :add_match_tags add_match_tags
 :get_matching_tag get_matching_tag
 }

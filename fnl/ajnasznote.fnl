; local path = require('pl.path')

; function handle_search(one, other, line)
; 	return path.relpath(one, other)
; end

; return {
; 	handle_search = handle_search,
; }


(local path (require :pl.path))

(fn get_title []
  (vim.fn.substitute (vim.fn.getline 1) "^#\\+\\s*" "" ""))

(fn get_tags [] (vim.fn.getline 3))

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

(fn to_safe_file_name [name]
  (string.lower (remove_leading_char
    "_"
    (string.gsub (remove_accent_chars name) "[^%a%d_-]+" "_"))))

(fn generate_new_alt_note_name [old_name new_name count]
  (let [
        file_name (vim.fn.fnamemodify new_name ":t:r")
        file_directory (vim.fn.fnamemodify ":h")
        formatted_new_name (vim.fn.resolve (vim.fn.printf "%s/%s_%d.md") file_directory file_name count)
        ]

    (if (or (= formatted_new_name new_name) (vim.fn.filereadable formatted_new_name)) formatted_new_name

      (if (> count 10) (do (vim.api.nvim_command "echoerr 'M002: Too many variations of file'") "")
        (generate_new_alt_note_name old_name new_name (+ count 1)))
      )))

(fn generate_new_name [old_name new_name]
  (if vim.fn.filereadable new_name (do (generate_new_alt_note_name old_name new_name 1)) new_name))

(fn handle_search [one other]
  (path.relpath one other))

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

(fn buffer_get_commands []
  (accumulate
    [
     out []
     _ word (ipairs (vim.fn.split (get_tags) "\\s\\+"))
     ]
    (if (= (string.sub word 1 1) "+")
      (let [cmd_parts (vim.fn.split word ":")]
        (tset out (+ 1 (length out)) {:cmd (. cmd_parts 1) :args (. cmd_parts 2)})
        out)
      out)
    )
  )

(fn buffer_has_tag [tags tag]
  (var has_tag false)
  (each [_ ltag (ipairs tags) :until has_tag]
    (set has_tag (= tag ltag)))
  has_tag)


(fn move_note [old_name_arg new_name_arg]
  (when (= "" new_name) (vim.api.nvim_command "echoerr 'M006: Note name cannot be empty'"))
  (let [
        resolved_old_name (vim.fn.resolve old_name_arg)
        resolved_new_name (vim.fn.resolve new_name_arg)
        ]
    (when (not (= resolved_old_name resolved_new_name))
      (let [new_name (generate_new_name resolved_old_name resolved_new_name)]
        (if (= "" resolved_old_name) (vim.api.nvim_command (vim.fn.printf "write %s" new_name))
          (do
            (vim.api.nvim_command "bd")
            (if (= 0 (vim.fn.rename resolved_old_name new_name))
              (do
                (vim.api.nvim_command (vim.fn.printf "edit %s" new_name))
                (vim.api.nvim_command "filetype detect")
                )
              (vim.api.nvim_command "echoerr 'M003: Rename failed'")
              )))
          ))
      )
    )

(fn get_matching_tag [tags]
  (let [buffer_tags (buffer_get_tags)]
    (each [_ match_tag (ipairs tags)]
      (let [pattern (. match_tag :pattern)] (do)))
    (do)))
{
 :get_matching_tag get_matching_tag
 :move_note move_note
 :handle_search handle_search
 :generate_new_name generate_new_name
 :fix_filename fix_filename
 :buffer_get_tags buffer_get_tags
 :buffer_get_commands buffer_get_commands
 :buffer_has_tag buffer_has_tag
 :get_title get_title
 :remove_accent_chars remove_accent_chars
 :to_safe_file_name to_safe_file_name
 }

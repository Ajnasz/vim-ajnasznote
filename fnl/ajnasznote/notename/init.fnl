(fn generate_new_alt_note_name [old_name new_name count]
  (let [
        file_name (vim.fn.fnamemodify new_name ":t:r")
        file_directory (vim.fn.fnamemodify ":h")
        formatted_new_name (vim.fn.resolve (string.format "%s/%s_%d.md") file_directory file_name count)
        ]

    (if (or (= formatted_new_name new_name) (vim.fn.filereadable formatted_new_name)) formatted_new_name

      (if (> count 10) (do (vim.api.nvim_command "echoerr 'M002: Too many variations of file'") "")
        (generate_new_alt_note_name old_name new_name (+ count 1)))
      )))

(fn generate_new_name [old_name new_name]
  (if vim.fn.filereadable new_name (do (generate_new_alt_note_name old_name new_name 1)) new_name))


{
 :new generate_new_name
 }

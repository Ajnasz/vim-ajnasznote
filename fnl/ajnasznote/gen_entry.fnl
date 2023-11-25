(local Path (require "plenary.path"))

(fn handle_entry_index [opts t k]
  (local override (. (or (. (or opts {}) :entry_index) {}) k))
  (if override
    (do (local (val save) (override t opts))
    (when save (rawset t k val))
      val)))

(fn get_coordinates [entry disable_coordinates]
  (if disable_coordinates
    ":"
    (if (. entry lnum)
      (if (. entry :col)
        (string.format ":%s:%s:" (. entry :lnum) (. entry :col))
        (string.format ":%s:" (. entry :lnum)))
      ":")
    )
  )

(fn is_absolute [t]
  (local filename (. t :filename))
  (local p (Path:new filename))
  (p:is_absolute)
  )

(fn execute_key_path [t]
  (if (is_absolute t)
    [(. t :filename) false]
    [((. (Path:new [ (. t :cwd) (. t :filename)]) :absolute)) false]
    )
  )

(fn execute_key_common [parse num]
  (fn [t] (unpack (. (parse t) num) true)))

(fn mt_vimgrep_entry_display [opts entry]
  (local disable_coordinates (. opts "disable_coordinates"))
  (local disable_devicons (. opts "disable_devicons"))
  (local display_filename (utils.transform_path opts (. entry :filename)))
  (local coordinates (get_coordinates entry disable_coordinates))
  (local display_string "%s%s%s")
  (local (display hl_group icon) (utils.transform_devicons
                                   (. entry :filename)
                                   (string.format display_string display_filename coordinates (. entry :text))
                                   disable_devicons
                                   ))

  (if hl_group
    (unpack display [ [ [ 0 (len icon) ] hl_group ] ] )
    display)
  )

(fn mt_vimgrep_entry__index [opts t k]
  (local override (handle_entry_index opts t k))
  (if override override
    (do
      (local raw (rawget mt_vimgrep_entry k))
      (if raw raw
        (do
          (local executor (rawget execute_keys k))
          (if executor
            (do (local (val save) (executor t))
              (when save (rawset t k val))
              val
              )
            (do

              (local lookup_keys { value 1 ordinal 1 })
              (rawget t (rawget lookup_keys k)))
            )
          ))
      ))
  )

(fn gen_from_vimgrep [opts]
  (local opts (or opts {}))

  (local parse (if (= true (. opts "__matches"))
                 (. (require "telescope.make_entry") :parse_with_col)
                 (if (= true (. opts "__inverted"))
                   parse_with_col))
    )

  (local only_sort_text (. opts "only_sort_text"))

  (local execute_keys
    {
     :path execute_key_path
     :filename (execute_key_common parse 1)
     :lnum (execute_key_common parse 2)
     :col (execute_key_common parse 3)
     :text (execute_key_common parse 4)
     }
  )

  (when only_sort_text (set execute_keys.ordinal (fn [t] (. t :text))))

  (local mt_vimgrep_entry
    {
     :cwd (vim.fn.expand (or opts.cwd (vim.loop.cwd)))
     :display (fn [entry] (mt_vimgrep_entry_display opts entry))
     :__index (fn [t k]
                (local override (handle_entry_index opts t k))
                (if override override
                  (do
                    (local raw (rawget mt_vimgrep_entry k))
                    (if raw raw
                      (do
                        (local executor (rawget execute_keys k))
                        (if executor
                          (do (local (val save) (executor t))
                            (when save (rawset t k val))
                            val
                            )
                          (do

                            (local lookup_keys { value 1 ordinal 1 })
                            (rawget t (rawget lookup_keys k)))
                          )
                        ))
                    ))
                )
     })

  (fn [line] (setmetatable [line] mt_vimgrep_entry))
)

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


(fn get_tags []
  (local query "
    (block_mapping_pair
      key: (flow_node) @key (#eq? @key \"tags\")
      value: (block_node
               (block_sequence
                 (block_sequence_item (flow_node) @tag))))")
  (local parser (vim.treesitter.get_parser 0 "yaml"))
  (local q (vim.treesitter.query.parse "yaml" query))
  (local tags [])

  (each [_ tree (ipairs (parser:trees))]
    (each [_ qmatch _  (q:iter_matches (tree:root) (parser:source))]
      (when qmatch
        (each [id node (pairs qmatch)]
          (local name (. q.captures id))
          (when (= name "tag")
            (local tag (vim.treesitter.get_node_text node (parser:source)))
            (table.insert tags tag)))
        )))
  tags)

(fn get-node-at [id parser query]
  (let [
        lang (parser:lang)
        q (vim.treesitter.query.parse lang query)
        tree (. (parser:trees) 1)
        ]
    (var retnode nil)
    (each [nid node  (q:iter_captures (tree:root) (parser:source)) &until retnode]
        (when (= nid id)
          (set retnode node)))
    retnode)
  )

(fn get-first-matching-node [parser query]
  (let [
        lang (parser:lang)
        q (vim.treesitter.query.parse lang query)
        tree (. (parser:trees) 1)
        (_id node) ((q:iter_captures (tree:root) (parser:source)))
        ]
    node)
  )

(fn get-meta-title-node [parser]
  (get-node-at 2 parser "(block_mapping_pair key: (flow_node) @key (#eq? @key \"title\") value: (flow_node) @value)")
  )

(fn get-meta-title []
  (local parser (vim.treesitter.get_parser 0 "yaml"))
  (local node (get-meta-title-node parser))
  (when node
    (vim.treesitter.get_node_text node (parser:source)))
  )

(fn get-h1-node [parser]
  (get-first-matching-node parser "(atx_heading (atx_h1_marker) heading_content: (inline) @h1)")
  )

(fn get-h1 []
  (local parser (vim.treesitter.get_parser))
  (vim.treesitter.get_node_text (get-h1-node parser) (parser:source))
  )

{
 :get_h1 get-h1
 :get_meta_title get-meta-title
 :get_tags get_tags
 :get_meta_dict get_meta_dict
 :get_meta_end_line get_meta_end_line
 }

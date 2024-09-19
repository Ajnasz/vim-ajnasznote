local function getbufoneline(bufnr, line)
  return vim.fn.getbufoneline(bufnr, line)
end
local function meta_read(bufnr, start_line, end_line)
  local meta_dict = {}
  local line = start_line
  local current_key = nil
  while (line < end_line) do
    local line_str = getbufoneline(bufnr, line)
    if vim.startswith(line_str, "  -") then
      local val = vim.fn.trim(vim.fn.substitute(line_str, "^  -", "", ""))
      if (meta_dict[current_key] == nil) then
        meta_dict[current_key] = {}
      else
      end
      table.insert(meta_dict[current_key], val)
    else
      local line_list = vim.fn.split(line_str, ": ")
      current_key = vim.fn.trim(vim.fn.substitute(line_list[1], ":$", "", ""))
      do end (meta_dict)[current_key] = nil
      if line_list[2] then
        local value = vim.fn.trim(line_list[2])
        do end (meta_dict)[current_key] = value
      else
      end
    end
    line = (line + 1)
  end
  return meta_dict
end
local function get_meta_end_line(bufnr)
  local meta_end_line = nil
  do
    local last_line = vim.fn.line("$")
    local line = 2
    while ((meta_end_line == nil) and (line <= last_line)) do
      if (vim.fn.getline(line) == "---") then
        meta_end_line = line
      else
        line = (line + 1)
      end
    end
  end
  return meta_end_line
end
local function get_meta_dict(bufnr)
  if (getbufoneline((bufnr or vim.fn.bufnr("")), 1) == "---") then
    local end_line = get_meta_end_line((bufnr or vim.fn.bufnr("")))
    if end_line then
      return meta_read((vim.fn.bufnr("") or 1), 2, end_line)
    else
      return nil
    end
  else
    return nil
  end
end
local function get_tags()
  local query = "\n    (block_mapping_pair\n      key: (flow_node) @key (#eq? @key \"tags\")\n      value: (block_node\n               (block_sequence\n                 (block_sequence_item (flow_node) @tag))))"
  local parser = vim.treesitter.get_parser(0, "yaml")
  local q = vim.treesitter.query.parse("yaml", query)
  local tags = {}
  for _, tree in ipairs(parser:trees()) do
    for _0, qmatch, _1 in q:iter_matches(tree:root(), parser:source()) do
      if qmatch then
        for id, node in pairs(qmatch) do
          local name = q.captures[id]
          if (name == "tag") then
            local tag = vim.treesitter.get_node_text(node, parser:source())
            table.insert(tags, tag)
          else
          end
        end
      else
      end
    end
  end
  return tags
end
local function get_node_at(id, parser, query)
  local lang = parser:lang()
  local q = vim.treesitter.query.parse(lang, query)
  local tree = parser:trees()[1]
  local retnode = nil
  for nid, node in q:iter_captures(tree:root(), parser:source()) do
    if retnode then break end
    if (nid == id) then
      retnode = node
    else
    end
  end
  return retnode
end
local function get_first_matching_node(parser, query)
  local lang = parser:lang()
  local q = vim.treesitter.query.parse(lang, query)
  local tree = parser:trees()[1]
  local _id, node = q:iter_captures(tree:root(), parser:source())()
  return node
end
local function get_meta_title_node(parser)
  return get_node_at(2, parser, "(block_mapping_pair key: (flow_node) @key (#eq? @key \"title\") value: (flow_node) @value)")
end
local function get_meta_title(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "yaml")
  local node = get_meta_title_node(parser)
  if node then
    return vim.treesitter.get_node_text(node, parser:source())
  else
    return nil
  end
end
local function get_h1_node(parser)
  return get_first_matching_node(parser, "(atx_heading (atx_h1_marker) heading_content: (inline) @h1)")
end
local function get_h1(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  return vim.treesitter.get_node_text(get_h1_node(parser), parser:source())
end
return {get_h1 = get_h1, get_meta_title = get_meta_title, get_tags = get_tags, get_meta_dict = get_meta_dict, get_meta_end_line = get_meta_end_line}

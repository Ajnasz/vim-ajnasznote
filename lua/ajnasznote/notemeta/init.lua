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
return {get_meta_dict = get_meta_dict, get_meta_end_line = get_meta_end_line}

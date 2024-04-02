local function strip_md_from_title(title)
  return vim.fn.substitute(title, "^#\\+\\s*", "", "")
end
local function get_buf_title()
  local notemeta = require("ajnasznote.notemeta")
  local meta_title = notemeta.get_meta_title()
  return (meta_title or notemeta.get_h1())
end
local function get_title(bufnr)
  return strip_md_from_title(get_buf_title((bufnr or 0)))
end
local function get_note_title(path)
  get_title(vim.fn.bufnr(path, true))
  return vim.fn.fnamemodify(path, ":t")
end
return {get_note_title = get_note_title, get_title = get_title}

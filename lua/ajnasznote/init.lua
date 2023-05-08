local path = require("pl.path")
local list = require("ajnasznote.list")
local function tolist(list0)
  if (type(list0) == "table") then
    return list0
  else
    return {list0}
  end
end
local function find_matching_tag(tags, buffer_tags)
  if (#tags > 0) then
    local pattern = (tags[1]).pattern
    local function _2_(tag)
      local patterns = tag.pattern
      return list.has_all(tolist(patterns), buffer_tags)
    end
    return list.find(_2_, tags)
  else
    return nil
  end
end
local function get_tag_path(tags, buffer_tags)
  local matching_tag = find_matching_tag(tags, buffer_tags)
  if matching_tag then
    return matching_tag.path
  else
    return nil
  end
end
local function get_title()
  return vim.fn.substitute(vim.fn.getline(1), "^#\\+\\s*", "", "")
end
local function get_tags()
  return vim.fn.getline(3)
end
local function remove_accent_chars(name)
  local chars = {["\195\161"] = "a", ["\195\169"] = "e", ["\195\173"] = "i", ["\195\179"] = "o", ["\195\182"] = "o", ["\197\145"] = "o", ["\195\186"] = "u", ["\195\188"] = "u", ["\197\177"] = "u", ["\195\129"] = "A", ["\195\137"] = "E", ["\195\141"] = "I", ["\195\147"] = "O", ["\195\150"] = "O", ["\197\144"] = "O", ["\195\154"] = "U", ["\195\156"] = "U", ["\197\176"] = "U"}
  local n = name
  for key, char in pairs(chars) do
    n = vim.fn.substitute(n, key, char, "g")
  end
  return n
end
local function remove_leading_char(char, input)
  if (char == string.sub(input, 1, 1)) then
    return remove_leading_char(char, string.sub(input, 2))
  else
    return input
  end
end
local function to_safe_file_name(name)
  return string.lower(remove_leading_char("_", string.gsub(remove_accent_chars(name), "[^%a%d_-]+", "_")))
end
local function generate_new_alt_note_name(old_name, new_name, count)
  local file_name = vim.fn.fnamemodify(new_name, ":t:r")
  local file_directory = vim.fn.fnamemodify(":h")
  local formatted_new_name = vim.fn.resolve(vim.fn.printf("%s/%s_%d.md"), file_directory, file_name, count)
  if ((formatted_new_name == new_name) or vim.fn.filereadable(formatted_new_name)) then
    return formatted_new_name
  else
    if (count > 10) then
      vim.api.nvim_command("echoerr 'M002: Too many variations of file'")
      return ""
    else
      return generate_new_alt_note_name(old_name, new_name, (count + 1))
    end
  end
end
local function generate_new_name(old_name, new_name)
  if vim.fn.filereadable then
    return new_name
  else
    local _8_
    do
      _8_ = generate_new_alt_note_name(old_name, new_name, 1)
    end
    if _8_ then
      return new_name
    else
      return nil
    end
  end
end
local function handle_search(lines)
  local line = lines[1]
  local x = print("line: ", line)
  local tail = vim.fn.matchstrpos(line, ":")
  local link = string.sub(line, 1, tail[2])
  local linked = vim.fn.fnamemodify(link, ":t")
  local current = vim.fn.expand("%:p:h")
  local p = path.relpath(link, current)
  return vim.cmd(vim.fn.printf("normal! a[%s](%s)", linked, p))
end
local function buffer_get_tags()
  local out = {}
  for _, word in ipairs(vim.fn.split(get_tags(), "\\s\\+")) do
    if (string.sub(word, 1, 1) == "@") then
      out[(1 + #out)] = word
      out = out
    else
      out = out
    end
  end
  return out
end
local function buffer_get_commands()
  local out = {}
  for _, word in ipairs(vim.fn.split(get_tags(), "\\s\\+")) do
    if (string.sub(word, 1, 1) == "+") then
      local cmd_parts = vim.fn.split(word, ":")
      do end (out)[(1 + #out)] = {cmd = cmd_parts[1], args = cmd_parts[2]}
      out = out
    else
      out = out
    end
  end
  return out
end
local function buffer_has_tag(tags, tag)
  local has_tag = false
  for _, ltag in ipairs(tags) do
    if has_tag then break end
    has_tag = (tag == ltag)
  end
  return has_tag
end
local function move_note(old_name_arg, new_name_arg)
  if ("" == new_name) then
    vim.api.nvim_command("echoerr 'M006: Note name cannot be empty'")
  else
  end
  local resolved_old_name = vim.fn.resolve(old_name_arg)
  local resolved_new_name = vim.fn.resolve(new_name_arg)
  if not (resolved_old_name == resolved_new_name) then
    local new_name = generate_new_name(resolved_old_name, resolved_new_name)
    if ("" == resolved_old_name) then
      return vim.api.nvim_command(vim.fn.printf("write %s", new_name))
    else
      vim.api.nvim_command("bd")
      if (0 == vim.fn.rename(resolved_old_name, new_name)) then
        vim.api.nvim_command(vim.fn.printf("edit %s", new_name))
        return vim.api.nvim_command("filetype detect")
      else
        return vim.api.nvim_command("echoerr 'M003: Rename failed'")
      end
    end
  else
    return nil
  end
end
local function get_matching_tag(tags)
  return get_tag_path(tags, buffer_get_tags())
end
local function get_default_file_dir()
  local file_path = vim.fn.fnameescape(vim.fn.resolve(vim.fn.expand("%:h")))
  if (file_path == "") then
    return vim.fn.expand(vim.g.ajnasznote_directory)
  else
    return file_path
  end
end
local function get_tag_path_file_dir(tag_path)
  return vim.fn.fnameescape(vim.fn.expand(vim.fn.printf("%s/%s", vim.g.ajnasznote_directory, tag_path)))
end
local function get_note_dir()
  local tag_path = get_matching_tag(vim.g.ajnasznote_match_tags)
  if tag_path then
    return get_tag_path_file_dir(tag_path)
  else
    return get_default_file_dir()
  end
end
local function mk_note_dir(dirname)
  if (0 == vim.fn.exists(dirname)) then
    vim.fn.mkdir(dirname, "p")
  else
  end
  if (0 == vim.fn.isdirectory(dirname)) then
    return vim.api.nvim_command("M004: Not a directory")
  else
    return nil
  end
end
local function get_new_file_name()
  local title = to_safe_file_name(vim.fn.getline(1))
  if not (title == "") then
    local file_path = get_note_dir()
    if file_path then
      return vim.fn.fnamemodify(vim.fn.printf("%s/%s.md", file_path, title), ":p")
    else
      return nil
    end
  else
    return nil
  end
end
local function rename_note()
  local new_name = get_new_file_name()
  if new_name then
    mk_note_dir(get_note_dir())
    return move_note(vim.fn.expand("%:p"), new_name)
  else
    return nil
  end
end
local function add_match_tags(tags)
  if not vim.g.ajnasznote_match_tags then
    vim.g["ajnasznote_match_tags"] = {}
  else
  end
  vim.g["ajnasznote_match_tags"] = vim.list_extend(vim.g.ajnasznote_match_tags, tags)
  return nil
end
local function create_note()
  return vim.cmd(vim.fn.printf("edit %s/%s.md", vim.fn.expand(vim.g.ajnasznote_directory), vim.fn.strftime("%Y-%m-%d_%H%M%s")))
end
local function insert_note()
  local fzf = require("fzf-lua")
  print("insert lua link")
  return fzf.fzf_live("rg --column --line-number --no-heading --color=always --smart-case <query> /home/ajnasz/Documents/Notes", {actions = {default = handle_search}})
end
return {buffer_get_commands = buffer_get_commands, rename_note = rename_note, add_match_tags = add_match_tags, create_note = create_note, insert_note = insert_note}

local path = require("pl.path")
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
    local _4_
    do
      _4_ = generate_new_alt_note_name(old_name, new_name, 1)
    end
    if _4_ then
      return new_name
    else
      return nil
    end
  end
end
local function handle_search(one, other)
  return path.relpath(one, other)
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
  local buffer_tags = buffer_get_tags()
  for _, match_tag in ipairs(tags) do
    local pattern = match_tag.pattern
  end
  return nil
end
return {get_matching_tag = get_matching_tag, move_note = move_note, handle_search = handle_search, generate_new_name = generate_new_name, fix_filename = fix_filename, buffer_get_tags = buffer_get_tags, buffer_get_commands = buffer_get_commands, buffer_has_tag = buffer_has_tag, get_title = get_title, remove_accent_chars = remove_accent_chars, to_safe_file_name = to_safe_file_name}

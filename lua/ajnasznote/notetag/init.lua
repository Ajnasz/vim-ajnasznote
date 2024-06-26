local list = require("ajnasznote.list")
local function tolist(list0)
  if (type(list0) == "table") then
    return list0
  else
    return {list0}
  end
end
local function buffer_has_tag(tags, tag)
  local has_tag = false
  for _, ltag in ipairs(tags) do
    if has_tag then break end
    has_tag = (tag == ltag)
  end
  return has_tag
end
local function find_matching_tag(tags, buffer_tags)
  if (#tags > 0) then
    local pattern = tags[1].pattern
    local function _2_(tag)
      local patterns = tag.pattern
      return list.has_all(tolist(patterns), buffer_tags)
    end
    return list.find(_2_, tags)
  else
    return nil
  end
end
local function get_tags()
  local notemeta = require("ajnasznote.notemeta")
  local meta_tags = notemeta.get_tags()
  if (meta_tags and (#meta_tags > 0)) then
    local tbl_18_auto = {}
    local i_19_auto = 0
    for _, v in ipairs(meta_tags) do
      local val_20_auto = ("@" .. v)
      if (nil ~= val_20_auto) then
        i_19_auto = (i_19_auto + 1)
        do end (tbl_18_auto)[i_19_auto] = val_20_auto
      else
      end
    end
    return tbl_18_auto
  else
    return vim.fn.split(vim.fn.getline(3), "\\s\\+")
  end
end
local function buffer_get_tags()
  local out = {}
  for _, word in ipairs(get_tags()) do
    if (string.sub(word, 1, 1) == "@") then
      out[(1 + #out)] = word
      out = out
    else
      out = out
    end
  end
  return out
end
local function get_matching_tag(tags)
  local matching_tag = find_matching_tag(tags, buffer_get_tags())
  if matching_tag then
    return matching_tag.path
  else
    return nil
  end
end
local function get_tag_path_file_dir(tag_path)
  return vim.fn.fnameescape(vim.fn.expand(string.format("%s/%s", vim.g.ajnasznote_directory, tag_path)))
end
local function add_match_tags(tags)
  if not vim.g.ajnasznote_match_tags then
    vim.g.ajnasznote_match_tags = {}
  else
  end
  vim.g.ajnasznote_match_tags = vim.list_extend(vim.g.ajnasznote_match_tags, tags)
  return nil
end
return {get_tag_path_file_dir = get_tag_path_file_dir, add_match_tags = add_match_tags, get_matching_tag = get_matching_tag}

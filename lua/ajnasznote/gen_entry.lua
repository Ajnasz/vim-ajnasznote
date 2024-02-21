local Path = require("plenary.path")
local function handle_entry_index(opts, t, k)
  local override = ((opts or {}).entry_index or {})[k]
  if override then
    local val, save = override(t, opts)
    if save then
      rawset(t, k, val)
    else
    end
    return val
  else
    return nil
  end
end
local function get_coordinates(entry, disable_coordinates)
  if disable_coordinates then
    return ":"
  else
    if entry[lnum] then
      if entry.col then
        return string.format(":%s:%s:", entry.lnum, entry.col)
      else
        return string.format(":%s:", entry.lnum)
      end
    else
      return ":"
    end
  end
end
local function is_absolute(t)
  local filename = t.filename
  local p = Path:new(filename)
  return p:is_absolute()
end
local function execute_key_path(t)
  if is_absolute(t) then
    return {t.filename, false}
  else
    return {Path:new({t.cwd, t.filename}).absolute(), false}
  end
end
local function execute_key_common(parse, num)
  local function _7_(t)
    return unpack(parse(t)[num], true)
  end
  return _7_
end
local function mt_vimgrep_entry_display(opts, entry)
  local disable_coordinates = opts.disable_coordinates
  local disable_devicons = opts.disable_devicons
  local display_filename = utils.transform_path(opts, entry.filename)
  local coordinates = get_coordinates(entry, disable_coordinates)
  local display_string = "%s%s%s"
  local display, hl_group, icon = utils.transform_devicons(entry.filename, string.format(display_string, display_filename, coordinates, entry.text), disable_devicons)
  if hl_group then
    return unpack(display, {{{0, len(icon)}, hl_group}})
  else
    return display
  end
end
local function mt_vimgrep_entry__index(opts, t, k)
  local override = handle_entry_index(opts, t, k)
  if override then
    return override
  else
    local raw = rawget(mt_vimgrep_entry, k)
    if raw then
      return raw
    else
      local executor = rawget(execute_keys, k)
      if executor then
        local val, save = executor(t)
        if save then
          rawset(t, k, val)
        else
        end
        return val
      else
        local lookup_keys = {[value] = 1, [ordinal] = 1}
        return rawget(t, rawget(lookup_keys, k))
      end
    end
  end
end
local function gen_from_vimgrep(opts)
  local opts0 = (opts or {})
  local parse
  if (true == opts0.__matches) then
    parse = require("telescope.make_entry").parse_with_col
  else
    if (true == opts0.__inverted) then
      parse = parse_with_col
    else
      parse = nil
    end
  end
  local only_sort_text = opts0.only_sort_text
  local execute_keys = {path = execute_key_path, filename = execute_key_common(parse, 1), lnum = execute_key_common(parse, 2), col = execute_key_common(parse, 3), text = execute_key_common(parse, 4)}
  if only_sort_text then
    local function _15_(t)
      return t.text
    end
    execute_keys.ordinal = _15_
  else
  end
  local mt_vimgrep_entry
  local function _17_(entry)
    return mt_vimgrep_entry_display(opts0, entry)
  end
  local function _18_(t, k)
    local override = handle_entry_index(opts0, t, k)
    if override then
      return override
    else
      local raw = rawget(mt_vimgrep_entry, k)
      if raw then
        return raw
      else
        local executor = rawget(execute_keys, k)
        if executor then
          local val, save = executor(t)
          if save then
            rawset(t, k, val)
          else
          end
          return val
        else
          local lookup_keys = {[value] = 1, [ordinal] = 1}
          return rawget(t, rawget(lookup_keys, k))
        end
      end
    end
  end
  mt_vimgrep_entry = {cwd = vim.fn.expand((opts0.cwd or vim.loop.cwd())), display = _17_, __index = _18_}
  local function _23_(line)
    return setmetatable({line}, mt_vimgrep_entry)
  end
  return _23_
end
return gen_from_vimgrep

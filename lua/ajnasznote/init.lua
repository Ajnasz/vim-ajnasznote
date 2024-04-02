local notetag = require("ajnasznote.notetag")
local notepath = require("ajnasznote.notepath")
local notetitle = require("ajnasznote.notetitle")
local function get_rel_path(p)
  local current = vim.fn.expand("%:p:h")
  return require("pl.path").relpath(p, current)
end
local function format_link(notepath0)
  local rel_path = get_rel_path(notepath0)
  return string.format("[%s](%s)", notetitle.get_note_title(notepath0), rel_path)
end
local function insert_note(lines)
  return vim.cmd(string.format("normal! a%s", format_link(lines[1])))
end
local function buffer_get_commands()
  local out = {}
  for _, word in ipairs(vim.fn.split(notetag.get_tags(), "\\s\\+")) do
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
local function move_note(old_name_arg, new_name_arg)
  if ("" == new_name_arg) then
    vim.api.nvim_command("echoerr 'M006: Note name cannot be empty'")
  else
  end
  local resolved_old_name = vim.fn.resolve(old_name_arg)
  local resolved_new_name = vim.fn.resolve(new_name_arg)
  if not (resolved_old_name == resolved_new_name) then
    local new_name = require("ajnasznote.notename").new(resolved_old_name, resolved_new_name)
    if ("" == resolved_old_name) then
      return vim.api.nvim_command(string.format("write %s", new_name))
    else
      local function _3_()
        return vim.api.nvim_command("bd")
      end
      pcall(_3_)
      if (0 == vim.fn.rename(resolved_old_name, new_name)) then
        vim.api.nvim_command(string.format("edit %s", new_name))
        return vim.api.nvim_command("filetype detect")
      else
        return vim.api.nvim_command("echoerr 'M003: Rename failed'")
      end
    end
  else
    return nil
  end
end
local function get_default_file_dir()
  local file_path = vim.fn.fnameescape(vim.fn.resolve(vim.fn.expand("%:h")))
  if (file_path == "") then
    return vim.fn.expand(vim.g.ajnasznote_directory)
  else
    return file_path
  end
end
local function get_note_dir()
  local tag_path = notetag.get_matching_tag(vim.g.ajnasznote_match_tags)
  if tag_path then
    return notetag.get_tag_path_file_dir(tag_path)
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
local function get_new_file_name(bufnr)
  local title = notepath.to_safe_file_name(notetitle.get_title(bufnr))
  if not (title == "") then
    local file_path = get_note_dir()
    if file_path then
      return vim.fn.fnamemodify(string.format("%s/%s.md", file_path, title), ":p")
    else
      return nil
    end
  else
    return nil
  end
end
local function rename_note()
  local new_name = get_new_file_name(vim.fn.bufnr(""))
  if new_name then
    mk_note_dir(get_note_dir())
    return move_note(vim.fn.expand("%:p"), new_name)
  else
    return nil
  end
end
local function create_note()
  return vim.cmd(string.format("edit %s/%s.md", vim.fn.expand(vim.g.ajnasznote_directory), vim.fn.strftime("%Y-%m-%d_%H%M%s")))
end
local function exec_insert_note()
  local function _14_(prompt_bufnr, map)
    local function _15_()
      require("telescope.actions").close(prompt_bufnr)
      return insert_note({require("telescope.actions.state").get_selected_entry().path})
    end
    map("i", "<cr>", _15_)
    return true
  end
  return require("telescope.builtin").live_grep({cwd = vim.g.ajnasznote_directory, attach_mappings = _14_})
end
local function note_explore()
  return vim.cmd(string.format("Lexplore %s", vim.g.ajnasznote_directory))
end
local function grep_in_notes()
  return require("telescope.builtin").live_grep({cwd = vim.g.ajnasznote_directory, disable_devicons = true, disable_coordinates = true})
end
local function find_links()
  return require("telescope.builtin").grep_string({cwd = vim.g.ajnasznote_directory, use_regex = true, search = ("\\[[^]]*" .. vim.fn.expand("%:t") .. "\\]\\([^)]+\\)")})
end
local function remove_note(opts)
  do
    local file_path
    if (#opts.args > 0) then
      file_path = opts.args
    else
      file_path = vim.fn.expand("%")
    end
    vim.uv.fs_unlink(file_path)
  end
  vim.api.nvim_command("echo 'Note removed'")
  return vim.api.nvim_command("bd")
end
local function setup(config)
  if not vim.g.ajnasznote_directory then
    vim.g.ajnasznote_directory = config.directory
  else
  end
  if not vim.g.ajnasznote_match_tags then
    vim.g.ajnasznote_match_tags = (config.match_tags or {})
  else
  end
  vim.api.nvim_create_user_command("NoteCreate", create_note, {})
  vim.api.nvim_create_user_command("NoteExplore", note_explore, {})
  vim.api.nvim_create_user_command("InsertLink", exec_insert_note, {})
  vim.api.nvim_create_user_command("NoteRemove", remove_note, {})
  vim.keymap.set("n", "<leader>nn", create_note, {})
  vim.keymap.set("n", "<leader><esc>", grep_in_notes, {})
  vim.keymap.set("n", "<leader>l", find_links, {})
  local augroup = vim.api.nvim_create_augroup("ajnasznote", {})
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile", "BufEnter"}, {group = augroup, pattern = {(vim.g.ajnasznote_directory .. "/*.md")}, command = "set conceallevel=2 wrap lbr tw=80 wrapmargin=0 showbreak=\\\\n>"})
  return vim.api.nvim_create_autocmd({"BufWritePost"}, {group = augroup, pattern = {(vim.g.ajnasznote_directory .. "/*.md")}, callback = rename_note})
end
return {buffer_get_commands = buffer_get_commands, rename_note = rename_note, add_match_tags = notetag.add_match_tags, create_note = create_note, insert_note = exec_insert_note, setup = setup, get_title = notetitle.get_title, find_links = find_links}

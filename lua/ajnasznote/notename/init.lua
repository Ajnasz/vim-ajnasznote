local function generate_new_alt_note_name(old_name, new_name, count)
  local file_name = vim.fn.fnamemodify(new_name, ":t:r")
  local file_directory = vim.fn.fnamemodify(":h")
  local formatted_new_name = vim.fn.resolve(string.format("%s/%s_%d.md"), file_directory, file_name, count)
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
    local _3_
    do
      _3_ = generate_new_alt_note_name(old_name, new_name, 1)
    end
    if _3_ then
      return new_name
    else
      return nil
    end
  end
end
return {new = generate_new_name}

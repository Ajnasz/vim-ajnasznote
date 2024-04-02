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
local function to_en_only_file_name(name)
  return string.lower(remove_leading_char("_", string.gsub(remove_accent_chars(name), "[^%a%d_-]+", "_")))
end
local function to_safe_file_name(name)
  return to_en_only_file_name(name)
end
return {to_safe_file_name = to_safe_file_name}

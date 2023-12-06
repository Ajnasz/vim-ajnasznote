local function trim(s)
  return string.gsub(string.gsub(s, "%s+$", ""), "^%s+", "")
end
return {trim = trim}

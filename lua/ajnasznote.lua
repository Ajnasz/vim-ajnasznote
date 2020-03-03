local path = require"pl.path"

local function generate_new_alt_note_name(old_name, new_name, count)
	local file_name = path.basename(new_name, ":t:r")
	local file_directory = path.dirname(new_name)

	local formatted_new_name = path.join(file_directory, string.format('%s_%d.md', file_name, count))

	if old_name == formatted_new_name or not path.exists(formatted_new_name) then
		return formatted_new_name
	end

	if count > 10 then
		vim.api.nvim_command('echoerr "too many recursion"')
		return
	end

	return generate_new_alt_note_name(old_name, formatted_new_name, count + 1)
end

local function generate_new_note_name(old_name, new_name)
	if old_name == new_name or not path.exists(new_name) then
		return new_name
	end

	return generate_new_alt_note_name(old_name, new_name, 1)
end

local function get_tags()
	local tags = {}
	local i = 1
	for k in string.gmatch(vim.fn.getline(3), '([^%s]+)') do
		tags[i] = k
		i = i + 1
	end
	return tags
end

local function has_tag(tags, tag)
	for k, ltag in ipairs(tags) do
		if ltag == tag then
			return true
		end
	end

	return false
end

local function get_matching_tag(tags)
end


return {
	generate_new_note_name = generate_new_note_name,
	get_tags = get_tags,
	get_matching_tag = get_matching_tag,
	has_tag = has_tag,
}

local path = require"pl.path"

local function generate_new_alt_note_name(old_name, new_name, count)
	local file_name, file_ext = path.splitext(path.basename(new_name))
	local file_directory = path.dirname(new_name)

	if not file_ext then
		file_ext = ".md"
	end

	local formatted_new_name = path.join(file_directory, string.format('%s_%d%s', file_name, count, file_ext))

	if old_name == formatted_new_name or not path.exists(formatted_new_name) then
		return formatted_new_name
	end

	if count > 10 then
		vim.api.nvim_command('echoerr "too many recursion"')
		return
	end

	return generate_new_alt_note_name(old_name, new_name, count + 1)
end

local function generate_new_note_name(old_name, new_name)
	if old_name == new_name or not path.exists(new_name) then
		return new_name
	end

	return generate_new_alt_note_name(old_name, new_name, 1)
end

local function get_tags(line)
	local tags = {}
	local i = 1
	for k in string.gmatch(line, '([^%s]+)') do
		tags[i] = k
		i = i + 1
	end
	return tags
end

local function get_buffer_tags()
	return get_tags(vim.fn.getline(3))
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
	local buffer_tags = get_buffer_tags()

	for k, match_tag in ipairs(tags) do
		local pattern = match_tag['pattern']
		local has_all_tags = true
		local pattern_type = type(pattern)

		if pattern_type == 'string' then
			has_all_tags = has_tag(buffer_tags, pattern)
		elseif pattern_type == 'table' then
			local tags = pattern

			for l, tag in ipairs(tags) do
				if not has_tag(buffer_tags, tag) then
					has_all_tags = false
					break
				end
			end
		else
			vim.fn.echoerr('M005: Invalid pattern')
		end

		if has_all_tags then
			return match_tag['path']
		end
	end

	return ''
end
function fix_filename(name)
	local chars = {
		{ 'á', 'a' },
		{ 'é', 'e' },
		{ 'í', 'i' },
		{ 'ó', 'o' },
		{ 'ö', 'o' },
		{ 'ő', 'o' },
		{ 'ú', 'u' },
		{ 'ü', 'u' },
		{ 'ű', 'u' },
		{ 'Á', 'A' },
		{ 'É', 'E' },
		{ 'Í', 'I' },
		{ 'Ó', 'O' },
		{ 'Ö', 'O' },
		{ 'Ő', 'O' },
		{ 'Ú', 'U' },
		{ 'Ü', 'U' },
		{ 'Ű', 'U' },
	}

	local new_name = name

	for k, achar in ipairs(chars) do
		new_name = string.gsub(new_name, achar[1], achar[2])
	end

	return new_name
end

return {
	generate_new_note_name = generate_new_note_name,
	get_matching_tag = get_matching_tag,
	fix_filename = fix_filename,
}

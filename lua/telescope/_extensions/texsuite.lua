local actions = require "telescope.actions"
local action_state = require("telescope.actions.state")
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local bufnr = 0


local function get_latex_element(query_string)
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()
	local query = vim.treesitter.query.parse('latex', query_string)
	local result = {}
	for _,match,_ in query:iter_matches(root,bufnr, 0, -1) do
		for _, node in pairs(match) do
			local text = vim.treesitter.get_node_text(node,0)
			local line = node:range()+1
			table.insert(result,{
				text = text,
				line = line})
		end
	end
	return result
end

local function get_newcommands()
	local query = "(new_command_definition) @new_command"
	local commands = {}
	local results = get_latex_element(query)
	for _,result in pairs(results) do
		local entry = {
			text = result.text,
			line = result.line,
			path = vim.api.nvim_buf_get_name(0)

		}
		table.insert(commands, entry)
	end
	return commands
end

local function get_labels()
	local query = "(label_definition (curly_group_text (text) @label_title))"
	local labels = {}
	local results = get_latex_element(query)
	for _,result in pairs(results) do
		local entry = {
			text = result.text,
			line = result.line,
			path = vim.api.nvim_buf_get_name(0)

		}
		table.insert(labels, entry)
	end
	return labels
end

local function get_headings()
    local headings = {}
    local matches = {
        'part',
        'chapter',
        'section',
        'subsection',
        'subsubsection',
        'paragraph',
        'subparagraph',
    }

	for _,type in pairs(matches) do
		local results = get_latex_element("("..type.."(curly_group (text) @section))")
		for _,result in pairs(results) do
			local entry = {
				type = type,
				text = result.text,
				line = result.line,
				path = vim.api.nvim_buf_get_name(0)
			}
			table.insert(headings, entry)
		end
	end
    return headings
end

local function get_frames()
    local frames = {}
	local frames_query ='(generic_environment (begin (curly_group_text (text) @frame (#eq? @frame "frame") generic_command (command_name) @command )))'
	
	local results = get_latex_element(frames_query)
	for _,result in pairs(results) do
		local entry = {
			type = type,
			text = result.text,
			line = result.line,
			path = vim.api.nvim_buf_get_name(0)
		}
		table.insert(frames, entry)
	end
	return frames
end


local function telescope_newcommands(opts)
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = 'Select newcommand definition',
		results_title = 'Newcommand',
		finder = finders.new_table {
			results = get_newcommands(),
			entry_maker = function(entry)
				return {
					value = entry.text,
					display = entry.text,
					ordinal = entry.text,
					filename = entry.path,
					lnum = entry.line
				}
			end
		},
		previewer = conf.qflist_previewer(opts),
		sorter = conf.file_sorter(opts),
		-- attach_mappings = function(prompt_bufnr, _)
		-- 	actions.select_default:replace(function()
		-- 		actions.close(prompt_bufnr)
		-- 		local selection = action_state.get_selected_entry()
		-- 		-- local pattern = "{([^{}]+)}"
		-- 		-- local resultTable = {}
		-- 		-- for match in selection[1]:gmatch(pattern) do
		-- 		-- 	table.insert(resultTable, match)
		-- 		-- end
		-- 		print(vim.inspect(selection))
		-- 		-- vim.api.nvim_put({ resultTable[2] }, "", false, true)
		-- 		vim.api.nvim_put({ selection[2] }, "", false, true)
		-- 	end)
		-- 	return true
		-- end,
	})
	:find()
end

local function telescope_labels(opts)
	opts = opts or {}
	pickers.new(opts, {
		prompt_title = 'Select a label',
		results_title = 'Labels',
		finder = finders.new_table {
			results = get_labels(),
			entry_maker = function(entry)
				return {
					value = entry.text,
					display = entry.text,
					ordinal = entry.text,
					filename = entry.path,
					lnum = entry.line
				}
			end
		},
		previewer = conf.qflist_previewer(opts),
		sorter = conf.file_sorter(opts),
	}):find()
end

local function add_template_file(file)
	local current_path = vim.fn.expand('%:p:h')
	local current_file = vim.fn.expand('%:t')
	local filename = file:match("^.+/(.+)$")
	os.execute("cp "..file.." "..current_path.."/"..filename)
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(0, pos[1]-1, pos[1]-1, false, {"\\include{"..file.."}"})
end

local function telescope_templates(opts)
	local temp_path = os.getenv("HOME").."/Phd/Templates"
	local command = "fdfind -t f . '"..temp_path.."'"
	local lines = {}
	local file = io.popen(command)
	for line in file:lines() do
		table.insert(lines, line)
	end
    file:close()

	pickers.new({}, {
		prompt_title = "Templates",
		finder = finders.new_table{ results = lines},
		sorter = conf.generic_sorter(opts),
		previewer = conf.qflist_previewer(opts),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				add_template_file(selection[1])
			end)
			return true
		end,
	}):find()
end


local function telescope_frames(opts)
	local frames = get_frames()
	pickers.new(opts, {
		prompt_title = 'Select frame',
		results_title = 'Frames',
		finder = finders.new_table {
			results = frames,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.text,
					ordinal = entry.text,
					filename = entry.path,
					lnum = entry.line
				}
			end
		},
		previewer = conf.qflist_previewer(opts),
		sorter = conf.file_sorter(opts),
	})
	:find()
end

local function telescope_headings(opts)
	local headings = get_headings()
	pickers.new(opts, {
		prompt_title = 'Select a heading',
		results_title = 'Headings',
		finder = finders.new_table {
			results = headings,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.type ..": "..entry.text,
					ordinal = entry.type ..": "..entry.text,
					filename = entry.path,
					lnum = entry.line
				}
			end
		},
		previewer = conf.qflist_previewer(opts),
		sorter = conf.file_sorter(opts),
	})
	:find()
end


return require("telescope").register_extension({
	setup = function(ext_config, config)
		-- Do not know how to use it.
	end,
	exports = {
		headings = telescope_headings,
		labels = telescope_labels,
		newcommands = telescope_newcommands,
		templates = telescope_templates,
		frames = telescope_frames
	},
})

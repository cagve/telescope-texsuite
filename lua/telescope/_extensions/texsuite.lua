local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local ts_utils = require 'nvim-treesitter.ts_utils'
local bufnr = 0

local function get_latex_element(query_string)
	local parser = vim.treesitter.get_parser(bufnr, "latex")
	local root = parser:parse()[1]:root()
	local query = vim.treesitter.query.parse('latex', query_string)
	local result = {}
	for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
		for _, node in pairs(match) do
			local text = vim.treesitter.get_node_text(node, 0)
			local line = node:range() + 1
			table.insert(result, {
				text = text,
				line = line,
				node = node,
			})
		end
	end
	return result
end

local function get_newcommands()
	local query = "(new_command_definition) @new_command"
	local commands = {}
	local results = get_latex_element(query)
	for _, result in pairs(results) do
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
	for _, result in pairs(results) do
		local entry = {
			text = result.text,
			line = result.line,
			path = vim.api.nvim_buf_get_name(0)

		}
		table.insert(labels, entry)
	end
	return labels
end

local function get_frames()
	local frames = {}
	local query = '(generic_environment (begin (curly_group_text (text (word) @frame (#eq? @frame "frame"))))) @general'
	local results = get_latex_element(query)
	local counter = 0
	local frame = 0
	for _, result in pairs(results) do
		if counter % 2 ~= 0 then -- to get just one captures instead of 2
			frame = frame +1
			local node = result.node
			local frame_title_node = node:child(1)
			local title = " "
			if frame_title_node ~= nil then
				local node_text = vim.treesitter.get_node_text(frame_title_node, 0)
				if string.find(node_text, "frametitle") then
					title = ": "..node_text:match("{(.-)}")
				end
			end

			local entry = {
				type = type,
				text = "Frame "..frame..title,
				line = result.line,
				path = vim.api.nvim_buf_get_name(0)
			}
			table.insert(frames, entry)
		end
		counter = counter + 1
	end
	print(frames)
	return frames
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

	for _, type in pairs(matches) do
		local results = get_latex_element("(" .. type .. "(curly_group (text) @section))")
		for _, result in pairs(results) do
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

local function telescope_frames(opts)
	local headings = get_frames()
	pickers.new(opts, {
		prompt_title = 'Select frame',
		results_title = 'Frames',
		finder = finders.new_table {
			results = headings,
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
					display = entry.type .. ": " .. entry.text,
					ordinal = entry.type .. ": " .. entry.text,
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
		frames = telescope_frames,
		newcommands = telescope_newcommands
	},
})

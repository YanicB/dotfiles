-- Line-specific notes plugin
local M = {}

local notes_file = ".nvim-notes.json"

-- Get project root (git root or cwd)
local function get_project_root()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if vim.v.shell_error == 0 and git_root then
        return git_root
    end
    return vim.fn.getcwd()
end

-- Get notes file path
local function get_notes_path()
    return get_project_root() .. "/" .. notes_file
end

-- Load notes from file
local function load_notes()
    local path = get_notes_path()
    local file = io.open(path, "r")
    if not file then
        return {}
    end
    local content = file:read("*a")
    file:close()
    if content == "" then
        return {}
    end
    local ok, data = pcall(vim.json.decode, content)
    return ok and data or {}
end

-- Save notes to file
local function save_notes(notes)
    local path = get_notes_path()
    local file = io.open(path, "w")
    if not file then
        vim.notify("Failed to save notes", vim.log.levels.ERROR)
        return
    end
    file:write(vim.json.encode(notes))
    file:close()
end

-- Get relative path from project root
local function get_relative_path()
    local root = get_project_root()
    local full = vim.fn.expand("%:p")
    if full:sub(1, #root) == root then
        return full:sub(#root + 2)
    end
    return full
end

-- Define sign for notes
vim.fn.sign_define("NvimNote", { text = "󰍨", texthl = "DiagnosticInfo" })

-- Update signs for current buffer
local function update_signs()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.fn.sign_unplace("nvim_notes", { buffer = bufnr })

    local notes = load_notes()
    local rel_path = get_relative_path()
    local file_notes = notes[rel_path]

    if not file_notes then
        return
    end

    for line, _ in pairs(file_notes) do
        vim.fn.sign_place(0, "nvim_notes", "NvimNote", bufnr, { lnum = tonumber(line), priority = 10 })
    end
end

-- Add note at current line
function M.add_note()
    local rel_path = get_relative_path()
    local line = vim.fn.line(".")
    local notes = load_notes()

    -- Get existing note if any
    local existing = ""
    if notes[rel_path] and notes[rel_path][tostring(line)] then
        existing = notes[rel_path][tostring(line)]
    end

    vim.ui.input({ prompt = "Note: ", default = existing }, function(input)
        if input == nil then
            return
        end

        if input == "" then
            -- Delete note if empty
            if notes[rel_path] then
                notes[rel_path][tostring(line)] = nil
                if vim.tbl_isempty(notes[rel_path]) then
                    notes[rel_path] = nil
                end
            end
            vim.notify("Note deleted", vim.log.levels.INFO)
        else
            notes[rel_path] = notes[rel_path] or {}
            notes[rel_path][tostring(line)] = input
            vim.notify("Note saved", vim.log.levels.INFO)
        end

        save_notes(notes)
        update_signs()
    end)
end

-- View note at current line
function M.view_note()
    local rel_path = get_relative_path()
    local line = vim.fn.line(".")
    local notes = load_notes()

    if not notes[rel_path] or not notes[rel_path][tostring(line)] then
        vim.notify("No note on this line", vim.log.levels.INFO)
        return
    end

    local note = notes[rel_path][tostring(line)]

    -- Create floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(note, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local width = math.min(60, math.max(20, #note + 4))
    local height = #lines

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " Note ",
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })

    -- Close on any key
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf })
    vim.keymap.set("n", "<Esc>", function()
        vim.api.nvim_win_close(win, true)
    end, { buffer = buf })
end

-- List all notes in project
function M.list_notes()
    local notes = load_notes()
    local items = {}

    for file, file_notes in pairs(notes) do
        for line, note in pairs(file_notes) do
            table.insert(items, {
                filename = get_project_root() .. "/" .. file,
                lnum = tonumber(line),
                text = note,
            })
        end
    end

    if #items == 0 then
        vim.notify("No notes in project", vim.log.levels.INFO)
        return
    end

    vim.fn.setqflist(items)
    vim.cmd("copen")
end

-- Setup autocmd to update signs
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    callback = update_signs,
})

return {
    dir = ".",
    name = "notes",
    lazy = false,
    keys = {
        { "<leader>na", function() M.add_note() end, desc = "Add note" },
        { "<leader>nv", function() M.view_note() end, desc = "View note" },
        { "<leader>nl", function() M.list_notes() end, desc = "List notes" },
    },
    config = function()
        -- Signs are set up on module load
    end,
}

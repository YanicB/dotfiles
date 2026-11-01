-- Local LLM integration using Ollama
local M = {}

-- Configuration
local config = {
    model = "qwen2.5-coder:3b", -- Small, fast model for quick explanations
    host = "http://localhost:11434",
}

-- Get selected text or current line
local function get_text()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" then
        vim.cmd('noau normal! "vy')
        return vim.fn.getreg("v")
    else
        return vim.fn.getline(".")
    end
end

-- Create floating window for response
local function show_response(response)
    local lines = vim.split(response, "\n")
    local max_width = 80
    local width = math.min(max_width, math.max(40, #lines[1] or 40))
    local height = math.min(20, #lines)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " LLM ",
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("wrap", true, { win = win })

    vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

-- Ask LLM for explanation
function M.explain()
    local text = get_text()
    if text == "" then
        vim.notify("No text to explain", vim.log.levels.WARN)
        return
    end

    local ft = vim.bo.filetype
    local prompt = string.format(
        "Explain this %s code in one short sentence. Be concise:\n\n%s",
        ft ~= "" and ft or "code",
        text
    )

    vim.notify("Asking LLM...", vim.log.levels.INFO)

    local cmd = string.format(
        [[curl -s %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}']],
        config.host,
        config.model,
        vim.json.encode(prompt)
    )

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and data[1] and data[1] ~= "" then
                local ok, result = pcall(vim.json.decode, data[1])
                if ok and result.response then
                    vim.schedule(function()
                        show_response(result.response)
                    end)
                elseif ok and result.error then
                    vim.schedule(function()
                        vim.notify("LLM error: " .. result.error, vim.log.levels.ERROR)
                    end)
                end
            end
        end,
        on_stderr = function(_, data)
            if data and data[1] and data[1] ~= "" then
                vim.schedule(function()
                    vim.notify("LLM error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
                end)
            end
        end,
    })
end

-- Ask custom question about selected code
function M.ask()
    local text = get_text()
    if text == "" then
        vim.notify("No text selected", vim.log.levels.WARN)
        return
    end

    vim.ui.input({ prompt = "Ask about code: " }, function(question)
        if not question or question == "" then
            return
        end

        local ft = vim.bo.filetype
        local prompt = string.format(
            "Answer briefly about this %s code:\n\nCode:\n%s\n\nQuestion: %s",
            ft ~= "" and ft or "code",
            text,
            question
        )

        vim.notify("Asking LLM...", vim.log.levels.INFO)

        local cmd = string.format(
            [[curl -s %s/api/generate -d '{"model": "%s", "prompt": %s, "stream": false}']],
            config.host,
            config.model,
            vim.json.encode(prompt)
        )

        vim.fn.jobstart(cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data and data[1] and data[1] ~= "" then
                    local ok, result = pcall(vim.json.decode, data[1])
                    if ok and result.response then
                        vim.schedule(function()
                            show_response(result.response)
                        end)
                    elseif ok and result.error then
                        vim.schedule(function()
                            vim.notify("LLM error: " .. result.error, vim.log.levels.ERROR)
                        end)
                    end
                end
            end,
        })
    end)
end

-- Set model
function M.set_model(model)
    config.model = model
    vim.notify("LLM model set to: " .. model, vim.log.levels.INFO)
end

return {
    dir = ".",
    name = "llm",
    lazy = false,
    keys = {
        { "<leader>le", function() M.explain() end, mode = { "n", "v" }, desc = "LLM explain code" },
        { "<leader>la", function() M.ask() end, mode = { "n", "v" }, desc = "LLM ask about code" },
    },
    config = function()
        vim.api.nvim_create_user_command("LLMModel", function(opts)
            M.set_model(opts.args)
        end, { nargs = 1 })
    end,
}

-- telescope
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

-- Code Actions
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })


-- tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

-- nvim-comment
vim.keymap.set({ "n", "v" }, "<leader>/", ":CommentToggle<cr>")

-- format code using LSP
vim.keymap.set("n", "<leader>fmd", vim.lsp.buf.format)

-- debug
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)

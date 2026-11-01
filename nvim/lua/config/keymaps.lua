vim.g.mapleader = " "

-- Buffer navigation
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")

-- Diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)

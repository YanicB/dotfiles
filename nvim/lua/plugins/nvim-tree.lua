return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
        { "<leader>e", ":NvimTreeFindFileToggle<cr>", desc = "Toggle file tree" },
    },
    config = function()
        require("nvim-tree").setup({
            filters = { dotfiles = false },
            git = { enable = true, ignore = false },
            view = { side = "right", width = 40 },
        })
    end,
}

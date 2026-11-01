return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>ff", ":Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fp", ":Telescope git_files<cr>", desc = "Git files" },
        { "<leader>fz", ":Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fo", ":Telescope oldfiles<cr>", desc = "Recent files" },
    },
}

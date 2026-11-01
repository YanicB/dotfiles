return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
        { "<leader>fmd", function() require("conform").format() end, desc = "Format file" },
    },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                css = { "prettierd" },
                html = { "prettierd" },
                json = { "prettierd" },
                yaml = { "prettierd" },
                markdown = { "prettierd" },
                lua = { "stylua" },
            },
            format_on_save = true,
        })
    end,
}

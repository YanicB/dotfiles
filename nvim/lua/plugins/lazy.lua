local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- gruvbox theme
    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                transparent_mode = true,
            })
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- File Tree
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup({
                filters = {
                    dotfiles = false,
                },
                git = {
                    enable = true,
                    ignore = false,
                },
                view = {
                    side = "right",
                    width = 40,
                },
            })
        end,
    },

    -- Bufferline
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
    },

    -- Comment plugin
    {
        'terrortylor/nvim-comment',
        config = function()
            require("nvim_comment").setup({ create_mappings = false })
        end
    },

    -- LSP Zero core
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = false,
        init = function()
            vim.g.lsp_zero_extend_cmp = 0
            vim.g.lsp_zero_extend_lspconfig = 0
        end,
    },

    -- Mason
    {
        'williamboman/mason.nvim',
        lazy = false,
        config = true,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_cmp()

            local cmp = require('cmp')
            local cmp_action = lsp_zero.cmp_action()

            cmp.setup({
                formatting = lsp_zero.cmp_format({ details = true }),
                mapping = cmp.mapping.preset.insert({
                    ['<C-y>'] = cmp.mapping.complete(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
                })
            })
        end
    },

    -- LSP Configs
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({ buffer = bufnr })
            end)

            require('mason-lspconfig').setup({
                ensure_installed = {
                    'pyright', -- Python
                    'ts_ls',   -- JavaScript/TypeScript
                    'gopls',   -- Golang
                    'clangd',
                },
                handlers = {
                    lsp_zero.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp_zero.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                    clangd = function()
                        require('lspconfig').clangd.setup({
                            cmd = { "clangd", "--header-insertion=iwyu" },
                        })
                    end,
                }
            })
        end
    },
    -- Auto-close brackets, quotes, etc.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()
        end,
    },

    -- Auto-close and rename HTML/XML tags
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
                per_filetype = {
                    ["html"] = {
                        enable_close = true, -- set to true unless you want to disable HTML support
                    },
                },
            })
        end,
    },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = { "lua", "html", "javascript", "tsx" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup {
                options = {
                    theme = 'gruvbox',
                    component_separators = '',
                    section_separators = '',
                    globalstatus = true, -- cleaner global statusline
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff' },
                    lualine_c = { { 'filename', path = 1 } }, -- 0 = just filename, 1 = relative path
                    lualine_x = { 'diagnostics', 'encoding', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                }
            }
        end
    },
    {
        "stevearc/conform.nvim",
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
})

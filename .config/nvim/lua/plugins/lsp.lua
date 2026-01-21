return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "ts_ls", "intelephense" },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "mason-lspconfig.nvim" },
        config = function()
            -- Keymaps
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local opts = function(desc) return { buffer = args.buf, desc = desc } end
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("[LSP] Go to definition"))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("[LSP] Hover docs"))
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("[LSP] Code action"))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("[LSP] Rename symbol"))
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("[LSP] Find references"))
                    vim.keymap.set("n", "<leader>fb", vim.lsp.buf.format, opts("[LSP] Format buffer"))
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts("[LSP] Prev diagnostic"))
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts("[LSP] Next diagnostic"))
                end
            })

            -- Configure servers using nvim 0.11 API
            vim.lsp.config.lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                    },
                },
            }

            vim.lsp.config.intelephense = {
                settings = {
                    intelephense = {
                        environment = {
                            includePaths = { "vendor" },
                        },
                        diagnostics = {
                            unusedSymbols = false,
                        },
                    },
                },
            }

            -- Disable phpactor (use intelephense instead for PHP)
            vim.lsp.enable("phpactor", false)

            -- Enable servers
            vim.lsp.enable({ "lua_ls", "ts_ls", "intelephense" })
        end
    },
}

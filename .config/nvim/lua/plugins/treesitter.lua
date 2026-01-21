return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter').setup({
            ensure_installed = { "javascript", "typescript", "c", "lua", "php" },
        })
    end
}

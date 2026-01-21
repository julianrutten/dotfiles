return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
        require('telescope').setup {
            defaults = {
                preview = {
                    treesitter = false,
                },
            },
        }
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "[Telescope] Find files" })
        vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = "[Telescope] Git files" })
        vim.keymap.set('n', '<leader>fs', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end, { desc = "[Telescope] Grep search" })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "[Telescope] Help tags" })
    end
}

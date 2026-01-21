vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "[Netrw] Open file explorer" })
vim.keymap.set("n", "<leader>rl", "<cmd>source $MYVIMRC<cr>", { desc = "Reload nvim config" })

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Exit terminal mode and move to left window
vim.keymap.set("t", "<M-h>", "<C-\\><C-n><C-w>h", { desc = "Exit terminal mode and move left" })

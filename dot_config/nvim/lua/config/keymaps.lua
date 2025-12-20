-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap.set
keymap("i", "jk", "<ESC>")
-- keymap("n", "<C-P>", "<cmd>Telescope projects<CR>")
keymap("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

-- vim.keymap.del("n", "<leader>cal")
-- vim.keymap.del("n", "<leader>caL")

-- Keymaps are automatically loaded on the VeryLazy eventconform
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- For the groupription on keymaps, I have a function getOptions(group) which returns noremap=true, silent=true and group=group. Then call: keymap(mode, keymap, command, getOptions("some randome group")

local keymap = vim.keymap.set
keymap("i", "jk", "<ESC>")
-- keymap("n", "<C-P>", "<cmd>Telescope projects<CR>")
keymap("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })

vim.keymap.del("n", "<leader>cal")
vim.keymap.del("n", "<leader>caL")

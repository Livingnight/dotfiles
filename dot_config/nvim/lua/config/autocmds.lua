-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- vim.api.nvim_create_autocmd("WinEnter", {
--   callback = function()
--     local floating = vim.api.nvim_win_get_config(0).relative ~= ""
--     vim.diagnostic.config({
--       virtual_text = false,
--       virtual_lines = not floating,
--     })
--   end,
-- })
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = "*.tmpl",
--   callback = function()
--     if vim.fn.expand("%:p"):match("chezmoi") then
--       vim.bo.filetype = "sh.chezmoitmpl"
--     end
--   end,
-- })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sh.tmpl",
  desc = "changing chezmoi template files to have the proper filetype for highlighting",
  callback = function()
    vim.bo.filetype = "sh.chezmoitmpl"
  end,
})

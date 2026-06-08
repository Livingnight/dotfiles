---@diagnostic disable: undefined-doc-name
-- nvim/lua/plugins/lsp/bash.lua
return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        bashls = {
          -- Default bashls filetypes are { "bash", "sh" }.
          -- We extend them to handle chezmoi templates too.
          filetypes = { "bash", "sh" },
        },
        jdtls = false,
      },
    },
  },
}

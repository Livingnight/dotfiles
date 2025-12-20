-- local inlay_hint = require("vim.lsp.inlay_hint")
-- Using autocmd launch (default)
-- Default uses jars from mason or ~/.vscode/extensions/vmware.vscode-spring-boot-x.x.x
return {
  "JavaHello/spring-boot.nvim",
  ft = { "java", "yaml", "jproperties" },
  dependencies = {
    "mfussenegger/nvim-jdtls",
  },
  enabled = LazyVim.has("mason.nvim") and require("mason-registry").is_installed("vscode-spring-boot-tools"),
  ---@type bootls.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    settings = {
      diagnostics = {
        inlay_hints = false,
      },
    },
  },
}
-- Using ftplugin or custom launch
-- Recommended if using nvim-jdtls with ftplugin/java.lua setup
-- {
--   "JavaHello/spring-boot.nvim",
--   lazy = true,
--   dependencies = {
--     "mfussenegger/nvim-jdtls", -- or nvim-java, nvim-lspconfig
--   },
--   config = false,
-- }

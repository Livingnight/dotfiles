return {
  "stevearc/conform.nvim",
  opts = function()
    return {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        markdown = { "prettier" },
        telekasten = { "prettier" },
        java = { "google-java-format" },
        sql = { "sqlfluff_custom" },
        xml = { "xmlformatter" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- sqlfluff = function()
        --   return nil
        -- end,
        sqlfluff_custom = {
          override_builtin = true,
          command = "sqlfluff",
          args = {
            "fix",
            -- "--config",
            -- "/home/livingnight/dev/.sqlfluff",
            "-vvv",
            "-",
          },
          -- stdin = true,
          -- ignore_exitcode = true,
          cwd = require("conform.util").root_file({ ".sqlfluff", ".git", "pom.xml", "package.json", ".editorconfig" }),
        },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
      log_level = vim.log.levels.DEBUG,
    }
  end,
}

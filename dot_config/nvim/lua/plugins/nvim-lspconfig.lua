return {
  "neovim/nvim-lspconfig",
  event = "LazyFile",
  dependencies = {
    "mason.nvim",
  },
  opts = function()
    -- require("spring_boot").init_lsp_commands()
    -- require("lspconfig").jdtls.setup({
    --   init_options = {
    --     bundles = require("spring_boot").java_extensions(),
    --   },
    -- })
    -- if LazyVim.has("mason-lspconfig") then
    --   require("mason-lspconfig.server_configurations.java_language_server.init")
    --
    -- end
    return {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        },
        -- virtual_lines = true,
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
        exclude = { "vue", "java" }, -- filetypes for which you don't want to enable inlay hints
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP Server Settings
      ---@type lspconfig.options
      servers = {
        yamlls = {
          on_attach = function(client, bufnr)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            vim.notify("Skipping YAML LSP for: " .. filename, vim.log.levels.DEBUG)
            vim.notify("The result of the match is: " .. filename:match("application.*%.ya?ml$"), vim.log.levels.DEBUG)
            if filename:match("application.*%.ya?ml$") then
              vim.notify("Skipping YAML LSP for: " .. filename, vim.log.levels.DEBUG)
              client.stop() -- Stop the client if it's for application.yml or application.yaml
              return
            end
          end,
        },
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          -- ---@type LazyKeysSpec[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
        -- yammlls = function(_, opts)
        --   require("yamllls").setup({ server = opts })
        -- opts.on_attach = function(client, bufnr)
        --   local filename = vim.api.nvim_buf_get_name(bufnr)
        --   if filename:match("^application.*%.ya?ml$") then
        --     vim.notify(print(filename))
        --     client.stop() -- Stop the client if it's for application.yml or application.yaml
        --   end
        -- end
        -- end,
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    }
  end,
}

return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
      "mfussenegger/nvim-dap",
      "mason-org/mason.nvim",
      "folke/which-key.nvim",
    },
    opts = function()
      local cmd = { vim.fn.exepath("jdtls") }

      -- Lombok support (Mason 2.0 compatible)
      if LazyVim.has("mason.nvim") then
        local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")
        if vim.uv.fs_stat(lombok_jar) then
          table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
        end
      end

      return {
        root_dir = function(path)
          return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
        end,
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
        end,
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
        end,
        cmd = cmd,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local c = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(c, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return c
        end,
        dap = { hotcodereplace = "auto", config_overrides = {} },
        dap_main = {},
        test = true,
        settings = {
          java = {
            inlayHints = {
              parameterNames = { enabled = "all" },
            },
          },
        },
      }
    end,

    config = function(_, opts)
      -- === Build bundles for DAP and test (Mason 2.0 compatible) ===
      local bundles = {}

      if LazyVim.has("mason.nvim") then
        local jar_patterns = {}

        -- java-debug-adapter (DAP)
        local debug_adapter_path = vim.fn.expand("$MASON/packages/java-debug-adapter")
        if vim.uv.fs_stat(debug_adapter_path) then
          table.insert(jar_patterns, debug_adapter_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
        end

        -- java-test (test runner)
        local java_test_path = vim.fn.expand("$MASON/packages/java-test")
        if vim.uv.fs_stat(java_test_path) then
          table.insert(jar_patterns, java_test_path .. "/extension/server/*.jar")
        end

        for _, pattern in ipairs(jar_patterns) do
          for _, jar in ipairs(vim.split(vim.fn.glob(pattern), "\n")) do
            if jar ~= "" then
              table.insert(bundles, jar)
            end
          end
        end
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)
        local config = {
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          settings = opts.settings,
          capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities() or nil,
        }

        -- Add spring-boot.nvim extensions if available
        if LazyVim.has("spring-boot.nvim") then
          local spring_boot = require("spring_boot")
          if spring_boot and spring_boot.java_extensions then
            config.init_options.extendedClientCapabilities = spring_boot.java_extensions()
          end
        end

        require("jdtls").start_or_attach(config)
      end

      -- Attach on FileType for subsequent buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = attach_jdtls,
      })

      -- Setup keymaps and DAP on LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")

            -- Extract and organize imports keymaps
            wk.add({
              mode = "n",
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
              { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
              { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
              { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
              { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
            })

            -- Visual mode extracts
            wk.add({
              mode = "v",
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              {
                "<leader>cxm",
                [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                desc = "Extract Method",
              },
              {
                "<leader>cxv",
                [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                desc = "Extract Variable",
              },
              {
                "<leader>cxc",
                [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                desc = "Extract Constant",
              },
            })

            -- DAP and test keymaps
            if LazyVim.has("nvim-dap") and opts.dap then
              require("jdtls").setup_dap(opts.dap)

              if opts.dap_main then
                require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
              end

              -- Test keymaps
              if opts.test then
                wk.add({
                  mode = "n",
                  buffer = args.buf,
                  { "<leader>t", group = "test" },
                  {
                    "<leader>tt",
                    function()
                      require("jdtls.dap").test_class({
                        config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                      })
                    end,
                    desc = "Run All Tests",
                  },
                  {
                    "<leader>tr",
                    function()
                      require("jdtls.dap").test_nearest_method({
                        config_overrides = type(opts.test) ~= "boolean" and opts.test.config_overrides or nil,
                      })
                    end,
                    desc = "Run Nearest Test",
                  },
                  { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test (Pick)" },
                })
              end
            end
          end
        end,
      })

      -- Attach the first time (FileType autocmd won't fire for the first file)
      attach_jdtls()
    end,
  },

  -- Spring Boot LSP for application.properties/.yml
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "properties" },
    dependencies = {
      "mfussenegger/nvim-jdtls",
    },
    opts = {},
  },

  -- Ensure Mason installs required packages
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "jdtls",
        "java-debug-adapter",
        "java-test",
        "vscode-spring-boot-tools",
      },
    },
  },

  -- Ensure java in treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },

  -- Optional: DAP configuration for remote debugging
  {
    "mfussenegger/nvim-dap",
    optional = true,
    config = function()
      local dap = require("dap")
      dap.configurations.java = {
        {
          type = "java",
          request = "attach",
          name = "Debug (Attach) - Remote",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
    end,
  },
}

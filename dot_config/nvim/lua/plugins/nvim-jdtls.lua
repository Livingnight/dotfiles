---@diagnostic disable: undefined-field
local java_filetypes = { "java" }

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
--@param config table
--@param custom function | table | nil

-- local function extend_or_override(config, custom, ...)
--   if type(custom) == "function" then
--     config = custom(config, ...) or config
--   elseif custom then
--     config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
--   end
--   return config
-- end

local function is_osgi_bundle(path)
  local name = vim.fn.fnamemodify(path, "t")
  -- Allow only known valid OSGI plugin
  return name:match("^com%.microsoft%.java%.debug%.plugin")
    or name:match("^com%.microsoft%.java%.test%.plugin")
    or name:match("^org%.eclipse%.jdt%.junit%d.runtime")
end

local function get_valid_bundles(paths)
  local valid = {}
  for _, path in ipairs(paths) do
    if is_osgi_bundle(path) then
      table.insert(valid, path)
    end
  end
  return valid
end

-- local function sanitize_bundles(bundlesToSanitize)
--   local seen = {}
--   local clean = {}
--   local skip = {
--     ["jdt-ls-commons.jar"] = true,
--     ["jdt-ls-extension.jar"] = true,
--     ["reactor-core.jar"] = true,
--     ["reactive-streams.jar"] = true,
--     ["sts-gradle-tooling.jar"] = true,
--   }
--   for _, path in ipairs(bundlesToSanitize) do
--     local name = vim.fn.fnamemodify(path, ":t")
--     if not seen[name] and not skip[name] then
--       seen[name] = true
--       table.insert(clean, path)
--     end
--   end
--   return clean
-- end

return {
  "mfussenegger/nvim-jdtls",
  dependencies = { "folke/which-key.nvim" },
  ft = java_filetypes,
  opts = function()
    local cmd = { vim.fn.exepath("jdtls") }
    if LazyVim.has("mason.nvim") then
      local mason_registry = require("mason-registry")
      local lombok_jar = mason_registry.get_package("jdtls"):get_install_path() .. "/lombok.jar"
      table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
    end
    return {
      jdtls = {
        handlers = {
          ["$/progress"] = function() end,
        },
      },
      settings = {
        java = {
          eclipse = { downloadSources = true },
          configuration = {
            updateBuildConfiguration = "interactive",
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/home/livingnight/.sdkman/candidates/java/8.0.362-tem",
              },
              {
                name = "JavaSE-11",
                path = "/home/livingnight/.sdkman/candidates/java/11.0.18-tem",
              },
              {
                name = "JavaSE-17",
                path = "/home/livingnight/.sdkman/candidates/java/17.0.6-tem",
              },
              {
                name = "JavaSE-21",
                path = "/home/livingnight/.sdkman/candidates/java/21.0.6-tem",
              },
            },
          },
          maven = { downloadSources = true },
          implementationsCodeLens = { enabled = true },
          referencesCodeLens = { enabled = true },
          inlayHints = { parameterNames = { enabled = true } },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
          },
        },
      },
      -- How to find the root dir for a given filename. The default comes from
      -- lspconfig which provides a function specifically for java projects.
      root_dir = LazyVim.lsp.get_raw_config("jdtls").default_config.root_dir,

      -- How to find the project name for a given root dir.
      project_name = function(root_dir)
        return root_dir and vim.fs.basename(root_dir)
      end,

      -- Where are the config and workspace dirs for a project?
      jdtls_config_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
      end,
      jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
      end,

      -- How to run jdtls. This can be overridden to a full java command-line
      -- if the Python wrapper script doesn't suffice.
      cmd = cmd,
      full_cmd = function(opts)
        local fname = vim.api.nvim_buf_get_name(0)
        local root_dir = opts.root_dir(fname)
        local project_name = opts.project_name(root_dir)
        local opt_cmd = vim.deepcopy(opts.cmd)
        if project_name then
          vim.list_extend(opt_cmd, {
            "-configuration",
            opts.jdtls_config_dir(project_name),
            "-data",
            opts.jdtls_workspace_dir(project_name),
          })
        end
        return opt_cmd
      end,

      -- These depend on nvim-dap, but can additionally be disabled by setting false here.
      dap = { hotcodereplace = "auto", config_overrides = {} },
      -- Can set this to false to disable main class scan, which is a performance killer for large project
      dap_main = {},
      test = true,
      -- settings = {
      --   java = {},
      -- },
    }
  end,
  config = function(_, opts)
    -- Find the extra bundles that should be passed on the jdtls command-line
    -- if nvim-dap is enabled with java debug/test.
    local bundles = {} ---@type string[]
    --
    -- vim.notify("spring boot package")
    -- vim.notify(vim.inspect(require("spring_boot")))

    -- vim.notify("java extensions maybe?")
    -- vim.notify(vim.inspect(spring_boot_extensions))

    -- vim.notify(vim.inspect(jar_patterns))

    if LazyVim.has("mason.nvim") then
      local mason_registry = require("mason-registry")
      local spring_boot = require("spring_boot")

      if spring_boot and mason_registry.is_installed("vscode-spring-boot-tools") then
        -- local spring_boot_pkg = mason_registry.get_package("vscode-spring-boot-tools")
        -- local spring_boot_path = spring_boot_pkg:get_install_path()

        -- vim.notify("spring boot pkg")
        -- vim.notify(vim.inspect(spring_boot_pkg))
        --
        -- vim.notify("spring boot path: " .. spring_boot_path)

        -- vim.list_extend(jar_patterns, {
        --   spring_boot_path .. "/extension/language-server/lib/*.jar",
        -- })

        -- vim.notify("jar patterns")
        -- vim.notify(vim.inspect(jar_patterns))

        if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
          local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
          local java_dbg_path = java_dbg_pkg:get_install_path()
          local jar_patterns = {
            java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
          }
          -- java-test also depends on java-debug-adapter.
          if opts.test and mason_registry.is_installed("java-test") then
            local java_test_pkg = mason_registry.get_package("java-test")
            local java_test_path = java_test_pkg:get_install_path()
            vim.list_extend(jar_patterns, {
              java_test_path .. "/extension/server/*.jar",
            })
          end

          -- vim.notify("jar patterns")
          -- vim.list_extend(jar_patterns, require("spring_boot").java_extensions())
          -- vim.notify(vim.inspect(require("spring_boot").java_extensions()))

          for _, jar_pattern in ipairs(jar_patterns) do
            for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
              table.insert(bundles, bundle)
            end
          end
          -- vim.notify(vim.inspect(bundles, { newline = "," }))
        end
      end
    end

    local function attach_jdtls()
      local fname = vim.api.nvim_buf_get_name(0)

      -- Configuration can be augmented and overridden by opts.jdtls
      local config = {
        cmd = opts.full_cmd(opts),
        root_dir = opts.root_dir(fname),
        init_options = {
          bundles = get_valid_bundles(bundles),
        },
        settings = opts.settings,
        -- enable CMP capabilities
        capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities() or nil,
      }

      -- vim.notify(vim.inspect(config.init_options.bundles))

      -- Existing server will be reused if the root_dir matches.
      require("jdtls").start_or_attach(config)
      -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
    end

    -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
    -- depending on filetype, so this autocmd doesn't run for the first file.
    -- For that, we call directly below.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = java_filetypes,
      callback = attach_jdtls,
    })

    -- Setup keymap and dap after the lsp is fully attached.
    -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
    -- https://neovim.io/doc/user/lsp.html#LspAttach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "jdtls" then
          local wk = require("which-key")
          wk.add({
            {
              mode = "n",
              buffer = args.buf,
              { "<leader>cx", group = "extract" },
              { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
              { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
              { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
              { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
              { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
            },
          })
          wk.add({
            {
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
            },
          })

          if LazyVim.has("mason.nvim") then
            local mason_registry = require("mason-registry")
            if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
              -- custom init for Java debugger
              require("jdtls").setup_dap(opts.dap)
              if opts.dap_main then
                require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
              end

              -- Java Test require Java debugger to work
              if opts.test and mason_registry.is_installed("java-test") then
                -- custom keymaps for Java test runner (not yet compatible with neotest)
                wk.add({
                  {
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
                      desc = "Run All Test",
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
                    { "<leader>tT", require("jdtls.dap").pick_test, desc = "Run Test" },
                  },
                })
              end
            end
          end

          -- User can set additional keymaps in opts.on_attach
          if opts.on_attach then
            opts.on_attach(args)
          end
        end
      end,
    })

    -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
    attach_jdtls()
  end,
}

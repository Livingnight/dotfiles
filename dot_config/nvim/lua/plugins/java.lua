return {
  -- Plugin repo. Lazy.nvim sees this string and knows to fetch
  -- github.com/mfussenegger/nvim-jdtls.
  "mfussenegger/nvim-jdtls",

  -- Only load this plugin for Java buffers.
  -- Lazy.nvim watches 'FileType' events and loads the plugin when
  -- a buffer has filetype "java".
  ft = { "java" },

  -- Other plugins this one depends on.
  dependencies = {
    "mfussenegger/nvim-dap", -- Debug Adapter Protocol client for Neovim.
    "mason-org/mason.nvim", -- External tool installer (jdtls, debug jars, etc.).
    "folke/which-key.nvim", -- Keybinding hints / grouping.
  },

  -- opts(): build the configuration table for jdtls.
  -- Lazy.nvim will call this once and then pass the result into config().
  opts = function()
    -- vim.fn.exepath("jdtls"):
    --   * Calls Vim's exepath() function through the Lua bridge vim.fn.
    --   * Returns the absolute path to the executable "jdtls" if it's on $PATH. [web:430]
    -- We wrap it in a table because LSP "cmd" expects { "binary", "arg1", ... }.
    local cmd = { vim.fn.exepath("jdtls") }

    -- Compute path to the Lombok agent JAR inside Mason.
    -- vim.fn.expand("$MASON/...") expands environment variables and ~ etc. [web:430]
    local lombok_jar = vim.fn.expand("$MASON/share/jdtls/lombok.jar")

    -- vim.uv.fs_stat(path):
    --   * Neovim's wrapper around libuv's fs_stat; returns a table of metadata
    --     (size, type, etc.) if the path exists, or nil if it doesn't. [web:421][web:429]
    if vim.uv.fs_stat(lombok_jar) then
      -- table.insert(list, value) appends to the end of the Lua array-like table.
      table.insert(cmd, string.format("--jvm-arg=-javaagent:%s", lombok_jar))
    end

    -- Return an options table with helpers for root detection, workspace paths,
    -- command building, DAP options, and jdtls settings.
    return {
      ---------------------------------------------------------------------------
      -- PROJECT ROOT DETECTION
      ---------------------------------------------------------------------------

      -- Hard-coded root markers for Java projects.
      -- vim.fs.root(path, markers) will search upward from "path" for any of
      -- these entries and call that directory the project root. [web:221][web:432]
      root_markers = {
        ".git",
        "mvnw",
        "gradlew",
        "settings.gradle",
        "settings.gradle.kts",
        "build.xml",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
      },

      -- Given a file path and this opts table, find the root dir using
      -- vim.fs.root(). This walks up the directory tree until it finds a
      -- marker from root_markers. [web:221][web:422]
      root_dir = function(path, opts)
        return vim.fs.root(path, opts.root_markers)
      end,

      -- Derive a project name from the root_dir by taking its last path segment.
      -- vim.fs.basename("/a/b/c") → "c".
      project_name = function(root_dir)
        return root_dir and vim.fs.basename(root_dir)
      end,

      -- Per-project jdtls config directory, under Neovim's cache dir.
      -- vim.fn.stdpath("cache") is something like ~/.local/state/nvim. [web:430]
      jdtls_config_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
      end,

      -- Per-project jdtls workspace directory.
      jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
      end,

      -- Base command (jdtls binary + optional Lombok JVM arg).
      cmd = cmd,

      -- Build the full jdtls command for a given buffer:
      --   * Get the buffer's filename.
      --   * Find the project root and name.
      --   * Deep-copy the base cmd table.
      --   * Append "-configuration" and "-data" args that point to
      --     per-project config and workspace dirs.
      full_cmd = function(opts, bufnr)
        -- vim.api.nvim_buf_get_name(bufnr) → absolute path of that buffer. [web:430]
        local fname = vim.api.nvim_buf_get_name(bufnr)

        -- NOTE: we pass opts in because root_dir is defined as (path, opts).
        local root_dir = opts.root_dir(fname, opts)
        local project_name = opts.project_name(root_dir)

        -- vim.deepcopy(table) makes a deep copy, so we don't mutate opts.cmd.
        local c = vim.deepcopy(opts.cmd)

        if project_name then
          -- vim.list_extend(dest, src_list) appends all elements of src_list to dest.
          vim.list_extend(c, {
            "-configuration",
            opts.jdtls_config_dir(project_name),
            "-data",
            opts.jdtls_workspace_dir(project_name),
          })
        end

        return c
      end,

      ---------------------------------------------------------------------------
      -- DAP / TEST OPTIONS PASSED TO nvim-jdtls
      ---------------------------------------------------------------------------

      -- DAP options used by require("jdtls").setup_dap().
      dap = { hotcodereplace = "auto", config_overrides = {} },

      -- Placeholder if you want to predefine main-class configs.
      dap_main = {},

      -- Flag to enable test mappings / behavior in your LspAttach handler.
      test = true,

      -- Native jdtls "settings" section.
      settings = {
        java = {
          inlayHints = {
            parameterNames = { enabled = "all" },
          },
        },
      },
    }
  end,

  -- config(): runs after opts(); hooks into Neovim, sets up DAP, autocommands,
  -- and calls jdtls.start_or_attach when appropriate.
  config = function(_, opts)
    ---------------------------------------------------------------------------
    -- BUILD BUNDLES (java-debug + java-test jars from Mason)
    ---------------------------------------------------------------------------

    local bundles = {}

    -- Helper: glob jars that match a pattern and append them to bundles.
    local function add_glob(pattern)
      -- vim.fn.glob(pattern) returns a newline-separated list of matches. [web:430]
      -- vim.split(str, "\n") splits into a Lua array.
      for _, jar in ipairs(vim.split(vim.fn.glob(pattern), "\n")) do
        if jar ~= "" then
          table.insert(bundles, jar)
        end
      end
    end

    -- Only attempt Mason paths if mason.nvim is installed in LazyVim.
    if LazyVim.has("mason.nvim") then
      local debug_adapter_path = vim.fn.expand("$MASON/packages/java-debug-adapter")
      if vim.uv.fs_stat(debug_adapter_path) then
        add_glob(debug_adapter_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
      end

      local java_test_path = vim.fn.expand("$MASON/packages/java-test")
      if vim.uv.fs_stat(java_test_path) then
        add_glob(java_test_path .. "/extension/server/*.jar")
      end
    end

    ---------------------------------------------------------------------------
    -- attach_jdtls(): start_or_attach jdtls for a given buffer
    ---------------------------------------------------------------------------

    local function attach_jdtls(bufnr)
      -- Safety: check buffer still exists (avoids "invalid buffer id" LSP errors
      -- if a callback fires after the buffer is wiped). [web:99][web:356]
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
      end

      local fname = vim.api.nvim_buf_get_name(bufnr)
      if fname == "" then
        return false
      end

      -- NOTE: this should be opts.root_dir(fname, opts) to match your definition.
      local root_dir = opts.root_dir(fname, opts)
      if not root_dir then
        return false
      end

      local config = {
        -- Use your buffer-specific full_cmd so each project gets its own
        -- jdtls workspace/config args.
        cmd = opts.full_cmd(opts, bufnr),

        root_dir = root_dir,

        -- init_options.bundles tells jdtls to load java-debug + java-test,
        -- enabling debugger and test runner integration. [web:112][web:67]
        init_options = {
          bundles = bundles,
        },

        -- jdtls settings from opts.
        settings = opts.settings,

        -- LSP client capabilities:
        -- if cmp-nvim-lsp is installed, ask it to augment capabilities so
        -- completion and snippets work nicely; otherwise use base capabilities. [web:90]
        capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities()
          or vim.lsp.protocol.make_client_capabilities(),
      }

      -- Optional: extend client capabilities with spring-boot.nvim.
      if LazyVim.has("spring-boot.nvim") then
        -- pcall(f, ...) calls f(...) in protected mode, catching any error. [web:428][web:425]
        -- If spring-boot.nvim isn't installed, this won't crash your config.
        local ok, spring_boot = pcall(require, "spring_boot")
        if ok and spring_boot.java_extensions then
          config.init_options.extendedClientCapabilities = spring_boot.java_extensions()
        end
      end

      -- Core nvim-jdtls entrypoint: start a new jdtls for this root, or attach
      -- to an existing one if already running. [web:107][web:88]
      require("jdtls").start_or_attach(config)
      return true
    end

    ---------------------------------------------------------------------------
    -- FileType autocmd: start jdtls once per Java buffer
    ---------------------------------------------------------------------------

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "java" }, -- only for buffers with ft=java
      callback = function(args)
        -- args.buf is the buffer id that triggered this autocmd.

        -- Buffer-local flag: if we've already started jdtls for this buffer,
        -- don't attempt it again.
        if vim.b[args.buf].jdtls_started then
          return
        end

        -- pcall(attach_jdtls, args.buf) ensures that if attach_jdtls throws
        -- any Lua error, it won't kill the entire autocmd system. [web:428][web:431]
        local ok = pcall(attach_jdtls, args.buf)
        if ok then
          vim.b[args.buf].jdtls_started = true
        end
      end,
    })

    ---------------------------------------------------------------------------
    -- LspAttach autocmd: keymaps + DAP wiring once jdtls attaches
    ---------------------------------------------------------------------------

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        -- args.data.client_id is numeric id of LSP client that attached. [web:232]
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- Bail out if this isn't jdtls.
        if not (client and client.name == "jdtls") then
          return
        end

        -- Disable semantic tokens for jdtls to avoid invalid-buffer races
        if client.server_capabilities.semanticTokensProvider then
          client.server_capabilities.semanticTokensProvider = nil
        end

        -- Buffer-local flag: only set up Java-specific mappings once per buffer.
        if vim.b[args.buf].jdtls_keys_set then
          return
        end
        vim.b[args.buf].jdtls_keys_set = true

        local wk = require("which-key")

        ----------------------------------------------------------------------
        -- Normal-mode mappings (Java refactors, imports, navigation)
        ----------------------------------------------------------------------

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

        ----------------------------------------------------------------------
        -- Visual-mode mappings (extract method/variable/constant from selection)
        ----------------------------------------------------------------------

        wk.add({
          mode = "v",
          buffer = args.buf,
          { "<leader>cx", group = "extract" },
          -- These visual mappings send <ESC> to exit visual mode then call jdtls APIs.
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

        ----------------------------------------------------------------------
        -- DAP wiring (one-time per client)
        ----------------------------------------------------------------------

        if LazyVim.has("nvim-dap") and opts.dap and not client._jdtls_dap_setup then
          -- Mark on the client that we've already done DAP setup, so we don't
          -- run this again for other buffers attached to the same client. [web:112][web:67]
          client._jdtls_dap_setup = true

          -- This registers the Java adapter and integrates jdtls with nvim-dap. [web:112]
          require("jdtls").setup_dap(opts.dap)

          -- This asks jdtls to compute main-class launch configurations and
          -- populate dap.configurations.java. [web:112][web:67]
          if opts.dap_main then
            require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
          end
        end

        ----------------------------------------------------------------------
        -- Test keymaps via jdtls.dap
        ----------------------------------------------------------------------

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
      end,
    })
  end,
}

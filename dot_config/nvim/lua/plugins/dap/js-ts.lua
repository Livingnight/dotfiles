return {
  {
    "mfussenegger/nvim-dap",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    opts = {
      adapter_name = "pwa-node",
      languages = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      configurations = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch current file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          sourceMaps = true,
          console = "integratedTerminal",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = function()
            return require("dap.utils").pick_process()
          end,
          cwd = "${workspaceFolder}",
          sourceMaps = true,
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"

      dap.adapters[opts.adapter_name] = dap.adapters[opts.adapter_name]
        or {
          type = "server",
          host = "127.0.0.1",
          port = "${port}",
          executable = {
            command = "node",
            args = { mason_path, "${port}", "127.0.0.1" },
          },
        }

      for _, lang in ipairs(opts.languages) do
        dap.configurations[lang] = opts.configurations
      end
    end,
  },
}

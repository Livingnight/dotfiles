return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI
      { "igorlfs/nvim-dap-view", opts = {} },
      -- Optional: virtual text overlays for variables etc.
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      {
        "db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint Condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "do",
        function()
          require("dap").step_out()
        end,
        desc = "Step out",
      },
      {
        "dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },

      -- nvim-dap-view: toggle UI window
      -- :DapViewToggle! is the standard toggle command
      {
        "du",
        "<cmd>DapViewToggle!<CR>",
        desc = "Toggle DAP View",
      },
    },
    config = function()
      local dap = require("dap")
      local dv = require("dap-view")
      local vt = require("nvim-dap-virtual-text")

      -- Visible signs
      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DiagnosticSignWarn",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "▶",
        texthl = "DiagnosticSignInfo",
        linehl = "Visual",
        numhl = "DiagnosticSignInfo",
      })

      -- Virtual text overlays (optional)
      vt.setup({
        enabled = true,
        enable_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
      })

      -- nvim-dap-view basic setup
      dv.setup({})

      dap.listeners.before.attach["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.before.launch["dap-view-config"] = function()
        dv.open()
      end
      dap.listeners.before.event_terminated["dap-view-config"] = function()
        dv.close()
      end
      dap.listeners.before.event_exited["dap-view-config"] = function()
        dv.close()
      end
    end,
  },
}

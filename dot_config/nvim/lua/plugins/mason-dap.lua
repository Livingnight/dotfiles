return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "java-debug-adapter",
        "java-test",
        "js-debug-adapter",
      },
      automatic_installation = true,
      handlers = {},
    },
  },
}

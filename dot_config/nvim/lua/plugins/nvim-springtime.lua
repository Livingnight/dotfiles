return {
  "javiorfo/nvim-springtime",
  ft = { "java" },
  dependencies = {
    "mfussenegger/nvim-jdtls",
  },
  keys = {
    {
      "<leader>jn",
      function()
        require("springtime").create_project()
      end,
      desc = "Create Spring Project",
    },
  },
}

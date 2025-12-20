return {
  "elmcgill/springboot-nvim",
  ft = { "java" },
  depedencies = {
    "mfussenegger/nvim-jdtls",
  },
  keys = {
    {
      "<leader>jS",
      function()
        require("springboot").start()
      end,
      desc = "Start springboot App",
    },
    {
      "<leader>js",
      function()
        require("springboot").stop()
      end,
      desc = "Stop Spring Boot App",
    },
    {
      "<leader>jr",
      function()
        require("springboot").restart()
      end,
      desc = "Restart Spring Boot App",
    },
  },
}

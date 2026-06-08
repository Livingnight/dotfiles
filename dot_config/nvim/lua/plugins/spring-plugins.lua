return {
  -- Spring project generator
  {
    "jkeresman01/spring-initializr.nvim",
    cmd = { "SpringInitializr", "SpringGenerateProject" },
    ft = { "java" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      {
        "<leader>jn",
        "<cmd>SpringInitializr<cr>",
        desc = "New Spring Project",
      },
      {
        "<leader>jg",
        "<cmd>SpringGenerateProject<cr>",
        desc = "Generate Project",
      },
    },
  },

  -- Spring Boot auto-reload
  {
    "elmcgill/springboot-nvim",
    cmd = { "SpringBoot" },
    ft = { "java" },
    keys = {
      {
        "<leader>jR",
        "<cmd>SpringBoot<cr>",
        desc = "Toggle Auto-Reload",
      },
    },
  },
}

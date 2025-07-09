return {
  "folke/snacks.nvim",
  picker = {
    projects = {
      finder = "recent_projects",
      format = "file",
      dev = { "~/dev" },
      -- confirm = "load_session",
      patterns = {
        ".git",
        "mvnw",
        "package.json",
        "node_modules",
        ".mvn/",
        "pom.xml",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
      },
      -- recent = true,
      matcher = {
        frecency = true, -- use frecency boosting
        sort_empty = true, -- sort even when the filter is empty
        cwd_bonus = false,
      },
      sort = { fields = { "score:desc", "idx" } },
      win = {
        preview = { minimal = true },
        input = {
          keys = {
            -- every action will always first change the cwd of the current tabpage to the project
            ["<c-e>"] = { { "tcd", "picker_explorer" }, mode = { "n", "i" } },
            ["<c-f>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
            ["<c-g>"] = { { "tcd", "picker_grep" }, mode = { "n", "i" } },
            ["<c-r>"] = { { "tcd", "picker_recent" }, mode = { "n", "i" } },
            ["<c-w>"] = { { "tcd" }, mode = { "n", "i" } },
            ["<c-t>"] = {
              function(picker)
                vim.cmd("tabnew")
                Snacks.notify("New tab opened")
                picker:close()
                Snacks.picker.projects()
              end,
              mode = { "n", "i" },
            },
          },
        },
      },
    },
  },
}

require("nvim-tree").setup {
  filters = {
    custom = {
      "^main$",
      "br.sh",
      ".git",
    }
  }
}


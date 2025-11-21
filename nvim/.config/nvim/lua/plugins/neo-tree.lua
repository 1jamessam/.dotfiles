return {
  "nvim-neo-tree/neo-tree.nvim",
  disabled = true,
  opts = {
    window = {
      mappings = {
        ["y"] = {
          function(state)
            local node = state.tree:get_node()
            local abs_path = node:get_id()
            local rel_path = vim.fn.fnamemodify(abs_path, ":.")
            vim.fn.setreg("+", rel_path, "c")
          end,
        },
      },
    },
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
    },
  },
}

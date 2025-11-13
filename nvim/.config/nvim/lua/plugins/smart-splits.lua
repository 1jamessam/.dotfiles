return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  enabled = false,
  opts = {
    multiplexer_integration = true,
    wrap_at_edge = false,
  },
  keys = {
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      mode = { "i", "n", "v" },
      desc = "Move to left window",
    },{
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      mode = { "i", "n", "v" },
      desc = "Move to right window",
    }
  },
  -- config = function(_, opts)
  --   local sp = require('smart-splits')
  --   vim.keymap.set('n', '<C-h>', sp.move_cursor_left)
  --   vim.keymap.set('n', '<C-j>', sp.move_cursor_down)
  --   vim.keymap.set('n', '<C-k>', sp.move_cursor_up)
  --   vim.keymap.set('n', '<C-l>', sp.move_cursor_right)
  --   vim.keymap.set('n', '<C-\\>', sp.move_cursor_previous)
  --   sp.setup(opts)
  -- end
}

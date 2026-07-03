return {
  {
    "coder/claudecode.nvim",
    -- Claude runs in a WezTerm split pane (see lua/claude_wezterm.lua), not an
    -- in-editor terminal, so the snacks/native terminal providers are unused.
    -- claudecode still owns the IDE side: the WebSocket server, the lockfile, and
    -- the selection/diff/diagnostics integration all live in Neovim regardless of
    -- where the CLI window is.
    opts = function()
      -- Drop the cached module so `:Lazy reload claudecode.nvim` picks up edits to
      -- lua/claude_wezterm.lua (a plain require would hand back the stale copy).
      package.loaded["claude_wezterm"] = nil
      return {
        terminal = {
          provider = require("claude_wezterm"),
          split_side = "right",
          split_width_percentage = 0.4,
        },
        diff_opts = {
          layout = "vertical",
          open_in_new_tab = true,
        },
      }
    end,
    keys = {
      { "<C-'>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude" },
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Open/focus Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}

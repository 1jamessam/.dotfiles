return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    -- Neovim's built-in :terminal (libvterm) doesn't support synchronized output
    -- (DEC mode 2026), so Claude's incremental cursor-positioned updates garble
    -- in the split. Full-repaint redraws the whole screen each frame instead,
    -- which renders cleanly without relying on synchronized output.
    init = function()
      vim.env.CLAUDE_CODE_ALT_SCREEN_FULL_REPAINT = "1"
    end,
    opts = {
      terminal = {
        split_width_percentage = 0.4,
      },
      diff_opts = {
        layout = "vertical",
        keep_terminal_focus = true,
        open_in_new_tab = true,
        -- hide_terminal_in_new_tab = true,
      },
    },
    keys = {
      { "<C-'>", "<cmd>ClaudeCode<cr>", mode = { "n", "t" }, desc = "Toggle Claude" },
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
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

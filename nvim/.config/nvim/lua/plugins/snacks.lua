-- <C-hjkl> inside a Snacks/Neovim terminal: navigate with smart-splits so the motion
-- can cross out of Neovim into an adjacent WezTerm pane (e.g. the Claude pane on the
-- right). LazyVim's default terminal nav (lazyvim/plugins/util.lua) runs plain
-- `wincmd`, which stops at Neovim's edge and never reaches the WezTerm pane -- that's
-- why <C-l> from the terminal couldn't switch to Claude. Float terminals keep the raw
-- key. Mirrors the smart-splits normal-mode mappings in the smart-splits.nvim spec.
local function term_nav(dir)
  local move = ({ h = "move_cursor_left", j = "move_cursor_down", k = "move_cursor_up", l = "move_cursor_right" })[dir]
  ---@param self snacks.terminal
  return function(self)
    if self:is_floating() then
      return "<c-" .. dir .. ">"
    end
    vim.schedule(function()
      require("smart-splits")[move]()
    end)
  end
end

-- <C-j>/<C-k> in the Snacks explorer: move between windows instead of moving the list
-- selection, so you can drop from the explorer down into the terminal (and back up).
-- Scoped to the explorer only -- transient pickers keep <C-j>/<C-k> as list nav for use
-- while typing. The explorer still has <C-n>/<C-p>/<Down>/<Up> for list movement.
--
-- The explorer list is a *floating* window (anchored over the sidebar), and Neovim's
-- directional `wincmd`/smart-splits resolves "down" from a float unreliably (it lands on
-- the editor to the right instead of the terminal below). So navigate by screen geometry:
-- pick the nearest window whose rectangle actually lies in the requested direction, with
-- overlap on the perpendicular axis. Skip the explorer's own float(s) and the layout-box
-- backdrop. If there's no window that way (e.g. nothing above the explorer), stay put --
-- don't fall through to the flaky float `wincmd`, and there's no WezTerm pane above/below
-- to cross into anyway.
--
-- NOTE: this is the Neovim-side twin of has_neighbor() in
-- wezterm/.config/wezterm/nav.lua -- same "nearest neighbour in direction X with
-- perpendicular overlap" test, against Neovim windows instead of WezTerm panes. Fix
-- edge-case bugs in both.
local function pick_nav(dir)
  return function()
    local cur = vim.api.nvim_get_current_win()
    local cp = vim.api.nvim_win_get_position(cur)
    local a = { top = cp[1], left = cp[2], h = vim.api.nvim_win_get_height(cur), w = vim.api.nvim_win_get_width(cur) }
    local best, best_dist
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
      if win ~= cur and ft ~= "snacks_layout_box" and not ft:match("^snacks_picker") then
        local p = vim.api.nvim_win_get_position(win)
        local b = { top = p[1], left = p[2], h = vim.api.nvim_win_get_height(win), w = vim.api.nvim_win_get_width(win) }
        local h_overlap = b.left < a.left + a.w and a.left < b.left + b.w
        local v_overlap = b.top < a.top + a.h and a.top < b.top + b.h
        local dist
        if dir == "j" and b.top >= a.top + a.h and h_overlap then
          dist = b.top - (a.top + a.h)
        elseif dir == "k" and b.top + b.h <= a.top and h_overlap then
          dist = a.top - (b.top + b.h)
        elseif dir == "l" and b.left >= a.left + a.w and v_overlap then
          dist = b.left - (a.left + a.w)
        elseif dir == "h" and b.left + b.w <= a.left and v_overlap then
          dist = a.left - (b.left + b.w)
        end
        if dist and (not best_dist or dist < best_dist) then
          best, best_dist = win, dist
        end
      end
    end
    if best then
      vim.api.nvim_set_current_win(best)
    end
  end
end

-- Keep the bottom terminal docked full-width regardless of open order. The Snacks
-- explorer sidebar is a full-height left split: opening it while a bottom terminal
-- already exists gives the explorer the entire left column and shrinks the terminal to
-- sit only under the editor. (Opening them in the other order -- explorer, then
-- terminal -- puts the terminal full-width along the bottom, which is what we want.)
-- On explorer show, re-dock any bottom-terminal split with `wincmd J` so the layout is
-- identical either way. Skip float terminals (relative ~= "") -- they don't tile.
local function dock_terminal_bottom()
  vim.schedule(function()
    local cur = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative == "" and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_terminal" then
        vim.api.nvim_set_current_win(win)
        vim.cmd("wincmd J")
      end
    end
    pcall(vim.api.nvim_set_current_win, cur)
  end)
end

return {
  "folke/snacks.nvim",
  init = function()
    vim.api.nvim_create_autocmd("StdinReadPre", {
      callback = function() vim.g.started_with_stdin = true end,
    })
    -- snacks dims files under dot-dirs (e.g. .github/) as "hidden" and untracked
    -- files, both linked to NonText (grey). Make hidden files read normally and
    -- untracked files green; keep genuinely ignored files dim. Re-apply on every
    -- colorscheme load so it survives theme switches.
    local function fix_snacks_hl()
      vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "SnacksPickerFile" })
      vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Added" })
    end
    vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_snacks_hl })
    fix_snacks_hl()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() > 0 or vim.g.started_with_stdin then
          return
        end
        Snacks.explorer()
      end,
    })
  end,
  opts = {
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
        },
      },
    },
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".mypy_cache", "__pycache__", ".venv" },
        },
        grep = {
          hidden = true,
          ignored = true,
          exclude = { ".mypy_cache", "__pycache__", ".venv" },
        },
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { ".mypy_cache", "__pycache__", ".venv" },
          on_show = dock_terminal_bottom,
          win = {
            list = {
              keys = {
                ["<c-j>"] = { pick_nav("j"), mode = "n", desc = "Go to Lower Window" },
                ["<c-k>"] = { pick_nav("k"), mode = "n", desc = "Go to Upper Window" },
              },
            },
            input = {
              keys = {
                ["<c-j>"] = { pick_nav("j"), mode = { "i", "n" }, desc = "Go to Lower Window" },
                ["<c-k>"] = { pick_nav("k"), mode = { "i", "n" }, desc = "Go to Upper Window" },
              },
            },
          },
        },
      },
      win = {
        input = {
          keys = {
            ["<a-c>"] = { "toggle_cwd", mode = { "n", "i" } },
          },
        },
      },
      actions = {
        ---@param p snacks.Picker
        toggle_cwd = function(p)
          local root = LazyVim.root { buf = p.input.filter.current_buf, normalize = true }
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
          local current = p:cwd()
          p:set_cwd(current == root and cwd or root)
          p:find()
        end,
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- { "<leader>/", LazyVim.pick("grep"), desc = "Grep (Root Dir)" },
    { "<leader>/", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader><space>", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    -- { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    -- { "<leader><space>", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
    { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
    { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
    { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent" },
    { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- git
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
    { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Git Diff (origin)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
    -- Grep
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    { "<leader>sw", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    { "<leader>sW", LazyVim.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
    -- ui
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
  },
}

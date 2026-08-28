-- Neovim ships ftplugin/sql.vim (which sets commentstring) but nothing for sqlx,
-- so `gcc` would produce no comment leader at all. One leader is not enough
-- either: config/js blocks and ${} interpolation are JavaScript (//), the rest of
-- the file is SQL (--). Derive it from the syntax stack at the cursor.

local JS_GROUPS = {
  sqlxJsBlock = true,
  sqlxBrace = true,
  sqlxInterp = true,
  sqlxProperty = true,
  sqlxJsFunc = true,
}

local function in_javascript()
  local lnum = vim.fn.line(".")
  -- Prefer the first non-blank column: for a linewise `gcc` that describes the
  -- line better than wherever the cursor happens to sit.
  local col = vim.fn.match(vim.fn.getline(lnum), "\\S") + 1
  if col < 1 then
    col = vim.fn.col(".")
  end
  local stack = vim.fn.synstack(lnum, math.max(col, 1))
  -- A line that opens or closes `${ ... }` reads as SQL even though the braces
  -- themselves are JS: `-- ${ref(...)}` is what you want when disabling a FROM.
  -- Only the interior lines of a multiline interpolation are really JavaScript.
  local top = stack[#stack]
  if top and vim.fn.synIDattr(top, "name") == "sqlxDelim" then
    return false
  end
  for _, id in ipairs(stack) do
    local name = vim.fn.synIDattr(id, "name")
    if JS_GROUPS[name] or name:find("^javaScript") then
      return true
    end
  end
  return false
end

local function update()
  vim.bo.commentstring = in_javascript() and "// %s" or "-- %s"
end

update()

local group = vim.api.nvim_create_augroup("sqlx_commentstring", { clear = false })
vim.api.nvim_clear_autocmds({ buffer = 0, group = group })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = group,
  buffer = 0,
  callback = update,
})

vim.b.undo_ftplugin = "setlocal commentstring<"

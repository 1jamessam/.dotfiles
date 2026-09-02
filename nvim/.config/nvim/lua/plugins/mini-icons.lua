-- Dataform .sqlx files (filetype registered in init.lua) aren't known to mini.icons,
-- so they render with the generic file glyph in the Snacks explorer/pickers. Give them
-- SQL's database glyph in azure so they stay distinguishable from plain .sql (grey).
-- The `extension` entry short-circuits the lookup; the `filetype` entry is what the
-- extension resolves to and also covers non-path lookups (statusline, buffer lists).
return {
  "echasnovski/mini.icons",
  opts = {
    extension = { sqlx = "sqlx" },
    filetype = { sqlx = { glyph = "󰆼", hl = "MiniIconsAzure" } },
  },
}

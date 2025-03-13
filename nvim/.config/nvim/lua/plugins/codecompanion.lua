-- OllamaList
vim.api.nvim_create_user_command("OllamaList", function()
  local output = vim.fn.system("ollama list")
  print(output)
end, {})

-- OllamaStart
_G.ollama_job_id = nil
vim.api.nvim_create_user_command("OllamaStart", function(opts)
  local model = opts.args
  if model == "" then
    print("Usage :OllamaStart <model>")
    return
  end

  if _G.ollama_job_id then
    print("Ollama server is already running. Stop ir first with :OllamaStop")
    return
  end

  _G.ollama_job_id = vim.fn.jobstart("ollama run " .. model, {
    detach = true,
    on_exit = function(_, code, _)
      if code == 0 then
        print("Ollama server stopped successfully.")
      else
        print("Ollama server exited with error code: " .. code)
      end
    end,
  })
  print("Started Ollama server with model: " .. model)
end, { nargs = 1 })

-- OllamaStop
vim.api.nvim_create_user_command("OllamaStop", function()
  if _G.ollama_job_id then
    vim.fn.jobstop(_G.ollama_job_id)
    print("Stopping Ollama server...")
  else
    print("No Ollama server is running.")
  end
end, {})

local wk = require("which-key")
wk.add({
  { "<leader>a", group = "+AI" },
  { "<leader>ao", group = "+Ollama" },
  { "<leader>aol", "<CMD>OllamaList<CR>", desc = "List Ollama models" },
})

return {
  "olimorris/codecompanion.nvim",
  config = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ai", "<CMD>CodeCompanion<CR>", desc = "Open the inline assistant" },
    { "<leader>ac", "<CMD>CodeCompanionChat<CR>", desc = "Open a chat buffer" },
    { "<leader>aa", "<CMD>CodeCompanionActions<CR>", desc = "Open the Action Palette" },
  },
  opts = {
    adapters = {
      deepseek = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {},
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "",
        keymaps = {
          send = {
            modes = { n = "<C-s>", i = "<C-s>" },
          },
          close = {
            modes = { n = "<C-c>", i = "<C-c>" },
          },
        },
      },
      inline = {
        keymaps = {
          accept_change = {
            modes = { n = "ga" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gr" },
            description = "Reject the suggested change",
          },
        },
      },
    },
  },
}

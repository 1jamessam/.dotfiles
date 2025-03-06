return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")

      require("dapui").setup()
      require("nvim-dap-virtual-text").setup({
        commented = true, -- Show virtual text alongside comment
      })

      -- dap_python.setup(LazyVim.get_pkg_path("debugpy"))
      dap_python.setup("python")

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      local opts = { noremap = true, silent = true }

      vim.keymap.set("n", "<leader>dm", function()
        dap_python.test_method()
      end, { desc = "Debug Test Method" })

      -- Toggle breakpoint
      vim.keymap.set("n", "<leader>db", function()
        dap.toggle_breakpoint()
      end, { desc = "Toggle Breakpoint" })

      -- Continue / Start
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Continue" })

      -- Step Over
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Step Over" })

      -- Step Into
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Step Into" })

      -- Step Out
      vim.keymap.set("n", "<leader>dO", function()
        dap.step_out()
      end, { desc = "Step Out" })

      -- Keymap to terminate debugging
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").terminate()
      end, { desc = "Terminate" })

      -- Toggle DAP UI
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { desc = "Toggle" })
    end,
  },
}

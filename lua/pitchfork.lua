local M = require("module")
M.config = {
  window_width = 60,
  window_height = 8,

  duplicate_current_keymap = "<leader>pn",
  toggle_window_keymap = "<leader>pw",

  remove_cursor_in_window_keymap = "d",
  switch_cursor_in_window_keymap = "<enter>",
}

require("vcursors")
require("window")

---@param opts table
M.setup = function(opts)
  M.config = vim.tbl_deep_extend('keep', M.config, opts)
  vim.keymap.set('n', M.config.duplicate_current_keymap, M.duplicate_current)
  vim.keymap.set('n', M.config.toggle_window_keymap, M.toggle_window)
  vim.keymap.set('n', "pl", function() vim.print(M) end)

  vim.api.nvim_create_autocmd( {"CursorMoved", "CursorMovedI"}, {
    desc = "Update the vcursor when moving the vim cursor",
    group = vim.api.nvim_create_augroup("update-vcursor", { clear = true }),
    callback = M.cursor_moved_callback
  })

  vim.api.nvim_create_autocmd( "WinLeave", {
    desc = "Keep track of the last non-floating window",
    group = vim.api.nvim_create_augroup("check-window", { clear = true }),
    callback = function()
      local current = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_config(current).relative == "" then
        M.last_non_floating = current
      end
    end
  })
end

return M

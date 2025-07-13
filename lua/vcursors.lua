local M = require("module")

-- Table of vcurosrs. Do not modify them directly, unless you know what you're doing
M.vcursors = {{
  line = vim.fn.line('.'),
  col = vim.fn.col('.'),
  buf = vim.api.nvim_get_current_buf(),
}}
M.current_index = 1

M.duplicate_current = function()
  local new_vcursor_index = table.maxn(M.vcursors) + 1
  table.insert(M.vcursors, new_vcursor_index, {
    line = vim.fn.line('.'),
    col = vim.fn.col('.'),
    buf = vim.api.nvim_get_current_buf(),
  })
  M.current_index = new_vcursor_index
end

---@param index integer
M.switch_vcursor = function(index)
  local windows = vim.fn.win_findbuf( M.vcursors[index].buf )
  local windows_len = table.maxn(windows)

  if windows_len == 0 then
    if vim.api.nvim_win_get_config(0).relative ~= "" then
      vim.api.nvim_set_current_win(M.last_non_floating)
    end
    vim.api.nvim_set_current_buf( M.vcursors[index].buf )
  else
    vim.api.nvim_set_current_win( windows[windows_len] )
  end

  vim.fn.cursor( M.vcursors[index].line, M.vcursors[index].col, 0 )
  M.current_index = index
end

---@param index integer
M.remove_vcursor = function(index)
  if index > M.current_index then
    table.remove(M.vcursors, index)
  elseif index < M.current_index then
    table.remove(M.vcursors, index)
    M.switch_vcursor(M.current_index - 1)
  elseif M.current_index == 1 then
    if table.maxn(M.vcursors) == 1 then
      error("You can't remove the only vcursor")
    else
      table.remove(M.vcursors, 1)
      M.switch_vcursor(2)
    end
  else
    table.remove(M.vcursors, index)
    M.switch_vcursor(M.current_index - 1)
  end
end

M.cursor_moved_callback = function()
  if vim.api.nvim_win_get_config(0).relative == "" then
    M.vcursors[M.current_index].line = vim.fn.line('.')
    M.vcursors[M.current_index].col = vim.fn.col('.')
    M.vcursors[M.current_index].buf = vim.api.nvim_get_current_buf()
  end
end

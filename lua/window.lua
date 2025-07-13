local M = require("module")
local win = nil

M.toggle_window = function()
  if win and vim.api.nvim_win_is_valid(win) then
    M.close_window()
  else
    M.open_window()
  end
end

M.open_window = function()
  local buf = vim.api.nvim_create_buf(false, true)

  for i = 1, table.maxn(M.vcursors), 1 do
    local vcursor = M.vcursors[i]
    local bufname = vim.fn.bufname(vcursor.buf)
    if bufname == "" then bufname = "[Unnamed]" end
    local text = ""
      .. tostring(i) .. ". "
      .. tostring(vcursor.line) .. ":" .. tostring(vcursor.col) .. " "
      .. bufname
    vim.api.nvim_buf_set_lines(buf, i-1, i, false, {text})
  end

  win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    col = math.floor(vim.o.columns / 2 - M.config.window_width / 2.),
    row = math.floor(vim.o.lines / 2 - M.config.window_height / 2.),
    width = math.floor(M.config.window_width),
    height = math.floor(M.config.window_height),
    style = 'minimal',
    border = 'rounded'
  })

  vim.keymap.set('n', M.config.switch_cursor_in_window_keymap, function()
      M.switch_vcursor(vim.fn.line('.'))
      M.close_window()
    end,
    { silent = true, noremap = true, buffer = buf }
  )

  vim.keymap.set('n', M.config.remove_cursor_in_window_keymap, function()
      M.remove_vcursor(vim.fn.line('.'))
      M.refresh_window()
    end,
    { silent = true, noremap = true, buffer = buf }
  )

  vim.fn.cursor({ M.current_index, 0 })
  vim.bo[buf].modifiable = false
end

M.close_window = function()
  vim.api.nvim_win_close(win, true)
  win = nil
end

M.refresh_window = function()
  M.close_window()
  M.open_window()
end


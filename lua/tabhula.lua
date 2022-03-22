local api = vim.api
local config = require("tabhula.config")

local M = {}

function _G.tabhula_handler(direction, evil)
  local cur = api.nvim_win_get_cursor(0)
  local col = cur[2]
  local row = cur[1]
  local line = api.nvim_get_current_line()

  -- fuck lua lol
  local l
  local key
  local tab

  -- set variables according to direction
  if direction == 0 then  -- forward
    l = line:sub(col + 1)
    key = api.nvim_replace_termcodes("<C-i>", true, false, true)
    tab = M.options.forward_characters
  else  -- backward
    l = line:sub(1, col):reverse()
    col = #l
    key = api.nvim_replace_termcodes("<C-d>", true, false, true)
    tab = M.options.backward_characters
  end

  -- check if cursor is at the start of line
  if col == 0 or line:sub(1, col):match("^(%s*)$") ~= nil then
    api.nvim_feedkeys(key, 'ni', false)
    return
  end

  -- find next opening character
  for c in l:gmatch(".") do
    if direction == 0 then
      col = col + 1
    else
      col = col - 1
    end
    if tab[c] ~= nil and tab[c](line) then
      if evil then
        local evil_keys = api.nvim_replace_termcodes("<Esc>ci" .. c, true, false, true)
        api.nvim_feedkeys(evil_keys, 'ni', false)
      else
        api.nvim_win_set_cursor(0, {row, col})
      end
      break
    end
  end
end

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, config.defaults, options or {})
  api.nvim_set_keymap('i', M.options.tabkey, "<cmd>lua tabhula_handler(0)<cr>", {})
  api.nvim_set_keymap('i', M.options.backward_tabkey, "<cmd>lua tabhula_handler(1)<cr>", {})
  api.nvim_set_keymap('i', M.options.evil_tabkey, "<cmd>lua tabhula_handler(0, 1)<cr>", {})
  api.nvim_set_keymap('i', M.options.evil_backward_tabkey, "<cmd>lua tabhula_handler(1, 1)<cr>", {})
end

return M

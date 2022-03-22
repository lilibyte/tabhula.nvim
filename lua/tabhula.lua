local api = vim.api
local config = require("tabhula.config")

local M = {}

function _G.tabhula_handler(direction, evil)
  local cur = api.nvim_win_get_cursor(0)
  local col = cur[2]
  local row = cur[1]
  local line = api.nvim_get_current_line()

  -- check if cursor is at a completion trigger
  if M.options.completion and M.options.completion ~= "" then
    if M.options.completion(direction) == 1 then
      return
    end
  end

  -- fuck lua lol
  local l
  local key
  local tab
  local range = M.options.range

  -- set variables according to direction
  if direction == 0 then  -- forward
    if range == nil then
      range = #line
    end
    l = line:sub(col + 1, math.min(#line, col + 1 + range))
    key = api.nvim_replace_termcodes("<C-i>", true, false, true)
    tab = M.options.forward_characters
  else  -- backward
    if range == nil then
      range = 1
    else
      range = math.max(col - range, 1)
    end
    l = line:sub(range, col):reverse()
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
        if direction == 1 then col = col + range - 1 end
        api.nvim_win_set_cursor(0, {row, col})
      end
      break
    end
  end
end

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, config.defaults, options or {})
  if M.options.tabkey ~= "" then
    api.nvim_set_keymap('i', M.options.tabkey, "<cmd>lua tabhula_handler(0)<cr>", {})
    if M.options.completion and M.options.completion ~= "" then
      api.nvim_set_keymap('s', M.options.tabkey, "<cmd>lua tabhula_handler(0)<cr>", {})
    end
  end
  if M.options.backward_tabkey ~= "" then
    api.nvim_set_keymap('i', M.options.backward_tabkey, "<cmd>lua tabhula_handler(1)<cr>", {})
    if M.options.completion and M.options.completion ~= "" then
      api.nvim_set_keymap('s', M.options.backward_tabkey, "<cmd>lua tabhula_handler(1)<cr>", {})
    end
  end
  if M.options.evil_tabkey ~= "" then
    api.nvim_set_keymap('i', M.options.evil_tabkey, "<cmd>lua tabhula_handler(0, 1)<cr>", {})
  end
  if M.options.evil_backward_tabkey ~= "" then
    api.nvim_set_keymap('i', M.options.evil_backward_tabkey, "<cmd>lua tabhula_handler(1, 1)<cr>", {})
  end
end

return M

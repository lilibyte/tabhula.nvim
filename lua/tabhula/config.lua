local M = {}

M.name = 'tabhula.nvim'

M.defaults = {
    tabkey = "<Tab>",
    backward_tabkey = "<S-Tab>",
    evil_tabkey = "<M-Tab>",
    evil_backward_tabkey = "<M-S-Tab>",
    completion = nil,
    range = nil,
    forward_characters = {
      [")"] = function() return 1 end,
      ["]"] = function() return 1 end,
      ["}"] = function() return 1 end,
      ['"'] = function() return 1 end,
      ["'"] = function() return 1 end,
      ["`"] = function() return 1 end,
    },
    backward_characters = {
      ["("] = function() return 1 end,
      ["["] = function() return 1 end,
      ["{"] = function() return 1 end,
      ['"'] = function() return 1 end,
      ["'"] = function() return 1 end,
      ["`"] = function() return 1 end,
    },
}

return M

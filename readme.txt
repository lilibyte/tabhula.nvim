*tabhula.txt*     context based tabout plugin for neovim

Author:           lilibyte
License:          The Unlicense, https://unlicense.org/
Homepage:         https://github.com/lilibyte/tabhula.nvim
Version:          1.0.0

==============================================================================
Contents                                          *tabhula* *tabhula-contents*

		1. Intro ........... |tabhula-intro|
		2. Installation .... |tabhula-installation|
		3. Usage ........... |tabhula-usage|
			Evil hulas ..... |tabhula-evil|
		4. Configuration ... |tabhula-configuration|
			Default options  |tabhula-defaults|
			Keymaps ........ |tabhula-keymaps|
			Characters ....  |tabhula-characters|
			Range .......... |tabhula-range|
			Completion ..... |tabhula-completion|
		5. Credits ......... |tabhula-credits|

==============================================================================
1. Intro                                                       *tabhula-intro*

Tabhula is a Neovim plugin for tinkerers wanting context-based <Tab>
functionality. The whole concept is derived from simply wanting to use
the tab character to exit quotes, brackets, parentheses, or any other
character, under certain circumstances only.

For example, if you want to use `>` as a tab out character, but only be able
to tab out of the line `#include <stdio.h>` and not affect a line such as
`10 > 11`, you can create a custom function using Lua pattern matching:

>
	[">"] = function(line) return line:match("^(%s*)#(%s*)include(%s*)<(%g*)>(%s*)$") ~= nil end
<

This way, when the cursor (|) is in front of a forward character (see
|tabhula-usage|) you can reach the end of the line by pressing <Tab>:

>
	// before
	#in(|)clude <stdio.h>

	// after
	#include <stdio.h>(|)
<

Tab out enables quickly navigating lines without the need to exit insert
mode (`:help insert-mode`).

Because of the manual nature of this plugin, it will not be suitable for
someone looking for advanced functionality but who doesn't understand
scripting logic well enough to write basic Lua. Ultimately, I've created this
plugin for my own personal use and being easy to use is not the goal. If you
want more thoroughly customizable logic, consider forking the project and
modifying it as you need. Tabhula is completely free/libre.

==============================================================================
2. Installation                                         *tabhula-installation*

Tabhula can be installed like any other Neovim plugin. See `:help plugin` for
more info on how to do this. A recent version of Neovim (>= 0.5) is required.

Alternatively, you can use a plugin manager like junegunn's vim-plug
<https://github.com/junegunn/vim-plug> or wbthomason's packer.nvim
<https://github.com/wbthomason/packer.nvim>:

>
	" vimscript: vim-plug
	Plug 'lilibyte/tabhula.nvim'

	-- lua: tabout.nvim
	use {
		'lilibyte/tabhula.nvim',
		config = function()
			require ('tabhula').setup({
				-- see |tabhula-configuration|
			})
		end,
	}
<

==============================================================================
3. Usage                                                       *tabhula-usage*

A "hula" can be defined as moving the cursor as a result of hitting a keymap
defined by Tabhula.

A "forward hula" is initiated by hitting the `tabkey` keymap |tabhula-keymaps|
and moves the cursor to the right of the closest forward character
|tabhula-characters|.

>
	// before
	(|)void foo() {
		bar();
	}

	// after
		(|)void foo() {
		bar();
	}

	// before
	vo(|)id foo() {
		bar();
	}

	// after, before
	void foo()(|) {
		bar();
	}

	// after, with the following `forward_characters` key:
	// ["{"] = function(line) return line:match("^(.*){(%s*)$") ~= nil end
	void foo() {(|)
		bar();
	}

	// before
	"Medio motu Saturni in secundum diem...(|)"

	// after (useful for simple text editing!)
	"Medio motu Saturni in secundum diem..."(|)
<

A "backward hula" is initiated by hitting the `backward_tabkey` keymap
|tabhula-keymaps| and moves the cursor to the left of the closest backward
character |tabhula-characters|.

>
	// backward_characters table keys:
	// [";"] = function(line) return line:match("(%g*)for(%s*)%((.*);(.*);(.*)%)(.*)") ~= nil end
	// [")"] = function() return 1 end

	// cursor positions, where (0) is the start and each increment
	// is the result of hitting `backward_tabkey` (n) times.
	for (5)(int i = 0(4); i < 10(3); ++i(2))(1);(0)
<

Tabhula does not require characters be defined as pairs. This allows you to
use tab out functionality on a character without a pair contextually.

>
	// `forward_characters` table key:
	// [";"] = function(line) return line:match("(.*);(%s*)$") ~= nil end

	// before
	u(|)nsigned long foo = 0xdeadbeef;

	// after
	unsigned long foo = 0xdeadbeef;(|)
<

------------------------------------------------------------------------------
EVIL HULAS                                                      *tabhula-evil*

An "evil hula" is a hula that deletes the content contained inside the
character it finds. This works by initiating a "change inside" normal mode
command with the next directional hula character. To learn more about this
idea, see `:help text-objects`.

For example, if your cursor (|) is before a valid character and you press
the `evil_tabkey` keymap, its content will be deleted and your cursor will
be put in place in insert mode:

>
	// before
	void foo()(|) {
		bar();
	}

	// after
	void foo() {
		(|)
	}
<

There's nothing special happening here, it's just the string `"<Esc>ci" .. c`
being sent to `nvim_feedkeys()`.

Evil hulas can be completely disabled by setting `evil_tabkey` and
`evil_backward_tabkey` to empty strings (""). See |tabhula-configuration|
for more details. There is currently no way to disable evil hulas on a
per-character basis, and in general their use should be done with caution.

==============================================================================
4. Configuration                                       *tabhula-configuration*

Tabhula exposes only a few configuration options, but they make up,
more-or-less, the entire functionality of the plugin.

------------------------------------------------------------------------------
DEFAULT OPTIONS                                             *tabhula-defaults*

>
	require("tabhula").setup({
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
	})
<

------------------------------------------------------------------------------
KEYMAPS                                                      *tabhula-keymaps*

The `setup()` table contains four different keys that control keymaps:

>
	tabkey = "<Tab>",
	backward_tabkey = "<S-Tab>",
	evil_tabkey = "<M-Tab>",
	evil_backward_tabkey = "<M-S-Tab>",
<

`tabkey` is the mapping that is used to trigged a forward hula
|tabhula-usage|.

`backward_tabkey` is the mapping that is used to trigger a backward hula
|tabhula-usage|.

`evil_tabkey` is the mapping that is used to trigged an evil forward hula
|tabhula-evil|.

`evil_backward_tabkey` is the mapping that is used to trigger an evil backward
hula |tabhula-evil|.

Any of the four keymaps and their accompanying functionality can be disabled
by setting their value to an empty string ("").

If `completion` is configured, then `tabkey` and `backward_tabkey` are given
additional selection mode keymaps, so they can be used to traverse snippets
with placeholder values without needing to change them (or more specifically,
without needing to re-enter insert mode to trigger another jump).

------------------------------------------------------------------------------
CHARACTERS                                                *tabhula-characters*

Characters to tab in and out of are defined as table keys whose values are
functions that specify the valid context for the characters that will be
called to determine whether the character in your file matches such a context.

`forward_characters` are those that are checked when a forward hula is
initiated |tabhula-usage|. Likewise, `backward_characters` are those that are
checked when a backward hula is initiated.

As long as the main Tabhula handler function can call a key's value, you can
specify anything you need.

For example, here is my own personal definitions (many of these have been
demonstrated throughout this file as well):

>
	forward_characters = {
		-- always hula past
		[")"] = function() return 1 end,
		["]"] = function() return 1 end,
		["}"] = function() return 1 end,
		['"'] = function() return 1 end,
		["'"] = function() return 1 end,
		["`"] = function() return 1 end,
		-- hula past { only if line ends with { character (ignoring whitespace)
		["{"] = function(line) return line:match("^(.*){(%s*)$") ~= nil end,
		-- hula past > only if line is a C-style header inclusion
		[">"] = function(line) return line:match("^(%s*)#(%s*)include(%s*)<(%g*)>(%s*)$") ~= nil end,
		[";"] = function(line) return line:match("(.*);(%s*)$") ~= nil end,
	},
	backward_characters = {
		-- always hula in front of
		["("] = function() return 1 end,
		["["] = function() return 1 end,
		["{"] = function() return 1 end,
		['"'] = function() return 1 end,
		["'"] = function() return 1 end,
		["`"] = function() return 1 end,
		-- hula in front of < only if line is a C-style header inclusion
		["<"] = function(line) return line:match("^(%s*)#(%s*)include(%s*)<(%g*)>(%s*)$") ~= nil end,
		-- hula in front of if part of a for loop
		[";"] = function(line) return line:match("(%g*)for(%s*)%((.*);(.*);(.*)%)(.*)") ~= nil end,
		-- always hula in front of (for function calls and similar)
		[")"] = function() return 1 end,
	},
<
Character functions are passed a `line` string that can be used for pattern
matching. This argument is the value returned by `nvim_get_current_line()`.

The characters " ' ` ) ] } have default `forward_characters` functions, and
the characters " ' ` ( [ { have default `backward_characters` functions.
These functions are all defined as `function() return 1 end` which will use
them as tab out characters in all contexts.

To learn more about Lua's pattern matching library functions, see section 20.2
of the "Programming in Lua" book <https://www.lua.org/pil/20.2.html>.

------------------------------------------------------------------------------
RANGE                                                          *tabhula-range*

The `range` table key should be given a number that is used to specify how
close the cursor needs to be in order to trigger a hula.

For example, consider if the `range` key was set to a value of 4:

>
	vo(|)id foo() {
		bar();
	}
<

When `tabkey` is pressed with the cursor (|) a greater distance from the next
forward character than specified in `range`, nothing happens as a result.

`range` has a default value of `nil` which is the required value for disabling
this functionality. The value of 0 can be used to enforce that the cursor must
be directly up against a matching character in order for it to be seen.

------------------------------------------------------------------------------
COMPLETION                                                *tabhula-completion*

Tabhula doesn't natively support completion integration by design. This is
left up to the user to define the logic for.

When a hula |tabhula-usage| is initiated, the first logic that gets parsed is
checking whether the user has defined a `completion` function. By default this
value is `nil`.

If `completion` is not `nil`, `false`, or an empty string, it will be assumed
to be a function and called. It's passed a `direction` argument by default,
which if desired, can be used to handle a forward hula and a backward hula
uniquely. A direction of 0 is forward, and a direction of 1 is backward.

Your `completion` function should return 1 if the cursor is in position to
trigger a valid snippet, and 0 otherwise. The main handler function will
return immediately if 1 is returned by `completion` and will proceed to look
for hula characters otherwise.

To demonstrate, here's the `completion` function I personally use for
triggering vim-vsnip <https://github.com/hrsh7th/vim-vsnip/> snippets:

>
	completion = function(direction)
		local cmd
		if direction == 0 then
			cmd = "<Plug>(vsnip-expand-or-jump)"
		else
			cmd = "<Plug>(vsnip-jump-prev)"
		end
		if vim.fn["vsnip#available"](1) == 1 then
			vim.fn.feedkeys(vim.api.nvim_replace_termcodes(cmd,1,1,1),'')
			return 1
		else
			return 0
		end
	end,
<

==============================================================================
5. Credits                                                   *tabhula-credits*

While tabhula was written by me, my inspiration came from abecodes's
tabout.nvim plugin <https://github.com/abecodes/tabout.nvim>. I highly suggest
taking a look at it before using tabhula.nvim to see if it better suites your
needs. I used it as a basis for figuring out how to structure a Neovim plugin
which is not something I've ever done before.

jacobsimpson's nvim-example-lua-plugin
<https://github.com/jacobsimpson/nvim-example-lua-plugin> was also useful for
me in getting my config proof-of-concept working as a proper plugin.

==============================================================================
vim: tw=78 ft=help ts=4 sw=4

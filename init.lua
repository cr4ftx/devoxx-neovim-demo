-- some basic options
vim.opt.number = true
vim.opt.relativenumber = true
-- set default tab to 2 space
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
-- always show the sign column for LSP diagnostic
vim.opt.signcolumn = "yes"
-- reduce the number of elements of the completion list
vim.opt.pumheight = 20
-- set the leader to space
vim.g.mapleader = " "

-- add lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.runtimepath:prepend(lazypath)

-- lazy plugin config
require("lazy").setup({
	-- 1. colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
	-- 2. nvim-treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
	-- 3. lsp config for autocompletion (mason and lspconfig)
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.tsserver.setup({})
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
				end,
			})
		end,
	},
})

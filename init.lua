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
	-- 4. better completion tool
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = "rafamadriz/friendly-snippets",
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "c", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "c", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- For luasnip users.
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	-- 5. fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local telescope = require("telescope")
			telescope.setup()
			vim.keymap.set("n", "<c-p>", "<cmd>Telescope find_files<cr>")
			vim.keymap.set("n", "<c-g>", "<cmd>Telescope live_grep<cr>")
			vim.keymap.set("n", "<c-n>", "<cmd>Telescope grep_string<cr>")
		end,
	},
	-- 6. Debugger
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"antoinemadec/FixCursorHold.nvim",
			"williamboman/mason.nvim",
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {
					all_references = true,
				},
			},
		},
    -- stylua: ignore
		config = function()
			local dap = require("dap")

			dap.adapters = {
				["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "node",
						args = {
							vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
							"${port}",
						},
					},
				},
			}

			for _, language in ipairs({ "typescript", "javascript" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch node",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach node",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
				}
			end

			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
      vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end)
      vim.keymap.set("n", "<leader>dc", function() dap.continue() end)
      vim.keymap.set("n", "<leader>dC", function() dap.run_to_cursor() end)
      vim.keymap.set("n", "<leader>dg", function() dap.goto_() end)
      vim.keymap.set("n", "<leader>di", function() dap.step_into() end)
      vim.keymap.set("n", "<leader>dj", function() dap.down() end)
      vim.keymap.set("n", "<leader>dk", function() dap.up() end)
      vim.keymap.set("n", "<leader>dl", function() dap.run_last() end)
      vim.keymap.set("n", "<leader>do", function() dap.step_out() end)
      vim.keymap.set("n", "<leader>dO", function() dap.step_over() end)
      vim.keymap.set("n", "<leader>dp", function() dap.pause() end)
      vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end)
      vim.keymap.set("n", "<leader>ds", function() dap.session() end)
      vim.keymap.set("n", "<leader>dt", function() dap.terminate() end)
      vim.keymap.set("n", "<leader>dh", function() require("dap.ui.widgets").hover() end)
		end,
	},
})

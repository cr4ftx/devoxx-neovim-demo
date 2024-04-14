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
require("lazy").setup({})

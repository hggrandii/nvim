vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })
keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })

keymap.set("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal split size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "New tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
keymap.set("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open buffer in tab" })

keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw" })

keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

keymap.set("n", "<leader>ef", function()
  local ok, Snacks = pcall(require, "snacks")
  if not ok then
    return
  end

  Snacks.explorer({
    cwd = vim.fn.expand("%:p:h"),
    follow_file = true,
  })
end, { desc = "Explorer current file" })

local ok, Snacks = pcall(require, "snacks")

if ok then
  keymap.set("n", "<leader>ff", function()
    Snacks.picker.files()
  end, { desc = "Find files" })

  keymap.set("n", "<leader>fs", function()
    Snacks.picker.grep()
  end, { desc = "Grep" })

  keymap.set("n", "<leader>fb", function()
    Snacks.picker.buffers()
  end, { desc = "Buffers" })

  keymap.set("n", "<leader>fh", function()
    Snacks.picker.help()
  end, { desc = "Help" })

  keymap.set("n", "<leader>ee", function()
    local ok, Snacks = pcall(require, "snacks")
    if ok then
      Snacks.explorer()
    end
  end, { desc = "Toggle Explorer" })
end

keymap.set("i", "<C-j>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  end
  return "<C-j>"
end, { expr = true, desc = "Completion next item" })

keymap.set("i", "<C-k>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-p>"
  end
  return "<C-k>"
end, { expr = true, desc = "Completion previous item" })

keymap.set("i", "<CR>", function()
  return "<CR>"
end, { expr = true, desc = "New line" })

keymap.set("i", "<C-y>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-y>"
  end
  return "<C-y>"
end, { expr = true, desc = "Accept completion" })

local function smart_left()
  local ok, Snacks = pcall(require, "snacks")
  local ft = vim.bo.filetype

  if ok and ft ~= "snacks_picker_list" and ft ~= "snacks_picker_input" and ft ~= "snacks_explorer" then
    Snacks.explorer()
  else
    vim.cmd("wincmd h")
  end
end

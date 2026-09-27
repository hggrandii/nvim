local logo = {
  "             ____                                ",
  "              ---|                               ",
  "  \\/            /|     \\/                       ",
  "               / |\\                              ",
  "              /  | \\        \\/                  ",
  "             /   || \\                            ",
  "            /    | | \\                           ",
  "           /     | |  \\                          ",
  "          /      | |   \\                         ",
  "         /       ||     \\                        ",
  "        /        /       \\                       ",
  "       /________/         \\                      ",
  "       ________/__________--/                    ",
  " ~~~   \\___________________/                     ",
  "         ~~~~~~~~~~       ~~~~~~~~               ",
  "~~~~~~~~~~~~~     ~~~~~~~~~                     ",
  "                               ~~~~~~~~~         ",
}

local function centered(lines)
  local width = vim.o.columns
  local height = vim.o.lines - vim.o.cmdheight

  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end

  local left_pad = math.max(math.floor((width - max_width) / 2), 0)
  local top_pad = math.max(math.floor((height - #lines) / 2) - 2, 0)

  local out = {}

  for _ = 1, top_pad do
    table.insert(out, "")
  end

  for _, line in ipairs(lines) do
    table.insert(out, string.rep(" ", left_pad) .. line)
  end

  return out
end

local function open_dashboard()
  if vim.fn.argc() ~= 0 then
    return
  end

  vim.cmd("enew")

  local buf = vim.api.nvim_get_current_buf()

  vim.bo[buf].filetype = "dashboard"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = true

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, centered(logo))

  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  vim.wo.signcolumn = "no"
  vim.wo.cursorline = false
  vim.wo.foldcolumn = "0"
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = open_dashboard,
})

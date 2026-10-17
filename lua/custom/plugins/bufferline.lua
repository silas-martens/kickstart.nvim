return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('bufferline').setup {
      options = {
        diagnostics = 'nvim_lsp',
        separator_style = 'thick',
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            text_align = 'left',
            separator = false,
          },
        },
      },
    }

    -- Switch buffers with <leader>1 ... <leader>9
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function() require('bufferline').go_to(i, true) end, { desc = 'Go to buffer ' .. i })
    end

    -- Previous / next buffer
    vim.keymap.set('n', '<leader>[', '<cmd>BufferLineCyclePrev<CR>', {
      desc = 'Previous buffer',
    })

    vim.keymap.set('n', '<leader>]', '<cmd>BufferLineCycleNext<CR>', {
      desc = 'Next buffer',
    })

    -- Close current buffer
    vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>', {
      desc = 'Close buffer',
    })
  end,
}

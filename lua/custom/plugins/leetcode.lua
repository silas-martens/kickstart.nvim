return {
  'kawre/leetcode.nvim',
  build = ':TSUpdate', -- if you have `nvim-treesitter` installed
  dependencies = {
    -- include a picker of your choice, see picker section for more details
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    -- configuration goes here
    ---@type lc.lang
    lang = 'cpp',
    picker = {
      provider = 'telescope',
    },
  },
  injector = {
    ['cpp'] = {
      after = function()
        return {
          '#include <bits/stdc++.h>',
          'using namespace std;',
          '',
          'int main() {}',
        }
      end,
    },
  },

  config = function(_, opts)
    require('leetcode').setup(opts)

    -- 👇 AUTOCMD goes HERE
    vim.api.nvim_create_autocmd('BufReadPost', {
      pattern = '*.cpp',
      callback = function()
        if vim.fn.expand('%:p'):find 'leetcode' then
          local lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)

          if not lines[1] or not lines[1]:match '#include' then
            vim.api.nvim_buf_set_lines(0, 0, 0, false, {
              '#include <bits/stdc++.h>',
              'using namespace std;',
              '',
            })
          end
        end
      end,
    })
  end,
}

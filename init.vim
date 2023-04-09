call plug#begin()

Plug 'davidgranstrom/scnvim'
Plug 'preservim/nerdtree'
Plug 'jnurmine/Zenburn'
Plug 'itchyny/lightline.vim'
Plug 'L3MON4D3/LuaSnip'

" Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'onsails/lspkind.nvim'
Plug 'quangnguyen30192/cmp-nvim-tags'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'kshenoy/vim-signature'

call plug#end()

set completeopt=menu,menuone,noselect

lua <<EOF
	local ls = require("luasnip")
	require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})
	ls.config.set_config({
		history = true,
		updateevents = "TextChanged,TextChangedI",
		enable_autosnippets = false
	})
EOF


lua <<EOF
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end
local lspkind = require'lspkind'
local luasnip = require'luasnip'
local cmp = require'cmp'

local next_item = function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end

local prev_item = function(fallback)
  if cmp.visible() then
    cmp.select_prev_item()
  else
    fallback()
  end
end

cmp.setup {
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  completion = {
    keyword_length = 3,
  },
  window = {
    documentation = false,
  },
  experimental = {
    native_menu = false,
    ghost_text = false,
  },
  formatting = {
    format = lspkind.cmp_format({preset = 'default', mode = 'symbol_text', maxwidth = 50})
  },
  mapping = {
    ['<C-j>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(next_item, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(prev_item , { 'i', 's' }),
    ['<C-n>'] = cmp.mapping(next_item, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(prev_item , { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'tags' },
    { name = 'path' },
    -- { name = 'buffer' },
    { name = 'luasnip' },
  },
}
EOF


lua << EOF
require('scnvim').setup()
EOF

lua << EOF
local scnvim = require 'scnvim'
local map = scnvim.map
local map_expr = scnvim.map_expr
scnvim.setup {
  keymaps = {
    ['<M-space>'] = map('editor.send_line', {'i', 'n'}),
    ['<C-space>'] = {
      map('editor.send_block', {'i', 'n'}),
      map('editor.send_selection', 'x'),
    },
    ['<CR>'] = map('postwin.toggle'),
    ['<M-CR>'] = map('postwin.toggle', 'i'),
    ['<M-L>'] = map('postwin.clear', {'n', 'i'}),
    ['<C-k>'] = map('signature.show', {'n', 'i'}),
    ['<F12>'] = map('sclang.hard_stop', {'n', 'x', 'i'}),
    ['<F1>'] = map('sclang.start'),
    ['<F2>'] = map('sclang.recompile'),
    ['<F5>'] = map_expr('s.makeGui'),
    ['<F6>'] = map_expr('App.rec'),
    ['<F7>'] = map_expr('s.mute'),
    ['<F8>'] = map_expr('s.unmute'),
		['<F9>'] = map_expr('thisProcess.platform.recordingsDir = "' .. vim.fn.getcwd() .. '".debug("rec dir")')
    -- ['<leader>st'] = map('sclang.start'),
    -- ['<leader>sk'] = map('sclang.recompile'),
    -- ['<F1>'] = map_expr('s.boot'),
    -- ['<F2>'] = map_expr('s.meter'),
  },
  editor = {
    highlight = {
      color = 'IncSearch',
    },
  },
  postwin = {
    float = {
      enabled = false,
    },
  },
  snippet = {
    engine = {
      name = 'luasnip',
      options = {
        descriptions = true,
      },
    },
  },
}
EOF

lua << EOF
require('scnvim.postwin').on_open:append(function()
  vim.opt_local.wrap = true
end)
EOF

" nerdtree setup
let NERDTreeIgnore = ['\.wav$', '\.WAV$', '\.reapeaks$', '\.aif$', '\.preset$']
let g:nerd_preview_enabled = 0
let g:preview_last_buffer  = 0

function! NerdTreePreview()
  " Only on nerdtree window
  if (&ft ==# 'nerdtree')
    " Get filename
    let l:filename = substitute(getline("."), "^\\s\\+\\|\\s\\+$","","g")

    " Preview if it is not a folder
    let l:lastchar = strpart(l:filename, strlen(l:filename) - 1, 1)
    if (l:lastchar != "/" && strpart(l:filename, 0 ,2) != "..")

      let l:store_buffer_to_close = 1
      if (bufnr(l:filename) > 0)
        " Don't close if the buffer is already open
        let l:store_buffer_to_close = 0
      endif

      " Do preview
      execute "normal go"

      " Close previews buffer
      if (g:preview_last_buffer > 0)
        execute "bwipeout " . g:preview_last_buffer
        let g:preview_last_buffer = 0
      endif

      " Set last buffer to close it later
      if (l:store_buffer_to_close)
        let g:preview_last_buffer = bufnr(l:filename)
      endif
    endif
  elseif (g:preview_last_buffer > 0)
    " Close last previewed buffer
    let g:preview_last_buffer = 0
  endif
endfunction

function! NerdPreviewToggle()
  if (g:nerd_preview_enabled)
    let g:nerd_preview_enabled = 0
    augroup nerdpreview
      autocmd!
      augroup END
  else
    let g:nerd_preview_enabled = 1
    augroup nerdpreview
      autocmd!
      autocmd CursorMoved * nested call NerdTreePreview()
    augroup END
  endif
endfunction

call NerdPreviewToggle()

let mapleader="/"
setlocal commentstring=//%s

nnoremap <silent> <Space> :NERDTreeToggle<CR>
" inoremap ii <ESC>
nmap g] <C-w><C-]><C-w>T
nnoremap <leader>rv :source $MYVIMRC<CR>
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'

" telescope
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
" map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
" map ,t :tabe <C-R>=expand("%:p:h") . "/" <CR>
" map ,s :split <C-R>=expand("%:p:h") . "/" <CR>



" indentation
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set smarttab
set mouse=a
set showcmd
set cursorline
set foldenable
set foldmethod=marker
set foldcolumn=2
set clipboard=unnamed

colorscheme zenburn

set shellcmdflag=-ic

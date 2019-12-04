" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0

" setup {{{
  let g:python_host_prog='~/.local/share/pyenv/versions/neovim2/bin/python'
  let g:python3_host_prog='~/.local/share/pyenv/versions/neovim3/bin/python'
  let s:cache_dir = '~/.local/share/nvim/.cache'
"}}}

" functions {{{
  function! s:get_cache_dir(suffix) "{{{
    return resolve(expand(s:cache_dir . '/' . a:suffix))
  endfunction "}}}
  function! Source(begin, end) "{{{
    let lines = getline(a:begin, a:end)
    for line in lines
      execute line
    endfor
  endfunction "}}}
  function! Preserve(command) "{{{
    " preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    execute a:command
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
  endfunction "}}}
  function! StripTrailingWhitespace() "{{{
    call Preserve("%s/\\s\\+$//e")
  endfunction "}}}
  function! EnsureExists(path) "{{{
    if !isdirectory(expand(a:path))
      call mkdir(expand(a:path))
    endif
  endfunction "}}}
  function! s:check_back_space() abort "{{{
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction "}}}
  function! s:show_documentation() "{{{
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction
  "}}}
"}}}

" base configuration {{{
  let mapleader = "\<space>"                          "change leader key to Space
  set list                                            "highlight whitespace
  set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮,nbsp:+
  set linebreak
  let &showbreak='↪ '
  set wildignorecase
  set wildignore+=*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store
  set gdefault
  set hidden

  set scrolloff=3                                     "always show content after scroll
  set scrolljump=1                                    "minimum number of lines to scroll
  set splitbelow
  set splitright

  set expandtab                                       "spaces instead of tabs
  let &tabstop=4                                      "number of spaces per tab for display
  let &softtabstop=4                                  "number of spaces per tab in insert mode
  let &shiftwidth=4                                   "number of spaces when indenting
  let is_bash=1                                       "always use bash syntax
  set ignorecase                                      "ignore case for searching
  set smartcase                                       "do case-sensitive if there's a capital letter
  set dictionary+=/usr/share/dict/words
  set updatetime=300

  " vim file/folder management {{{
    " persistent undo
    if exists('+undofile')
      set undofile
      let &undodir = s:get_cache_dir('undo')
    endif

    " backups
    set backup
    let &backupdir = s:get_cache_dir('backup')

    " swap files
    let &directory = s:get_cache_dir('swap')
    set noswapfile

    call EnsureExists(s:cache_dir)
    call EnsureExists(&undodir)
    call EnsureExists(&backupdir)
    call EnsureExists(&directory)
  "}}}
"}}}

" ui configuration {{{
  set termguicolors
  set diffopt=filler,vertical,iwhite
  set completeopt=menu
  set signcolumn=yes                                  "always show signcolumns
  set laststatus=2                                    "must set for airline
  set cmdheight=2                                     "Better display for messages
  set noshowmode                                      "we already have airline
  set noshowcmd                                       "don't show cmd
  set foldenable                                      "enable folds by default
  set foldlevelstart=99                               "open all folds by default
  let g:xml_syntax_folding=1                          "enable xml folding
  set shortmess+=c                                    "no message for the autocomplete
  set showtabline=0
  " let &colorcolumn=120
  set conceallevel=1
  if has('nvim')
    set icm=split
  else
    set nocompatible
    set autoindent
    set autoread
    set backspace=indent,eol,start
    set belloff=all
    set complete=.,w,b,u,t
    set display=lastline
    set formatoptions=tcqj
    set history=10000
    set hlsearch
    set incsearch
    set langnoremap
    set langremap
    set nrformats=bin,hex
    set ruler
    set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize
    set smarttab
    set tabpagemax=50
    set tags=./tags;,tags
    set ttyfast
    set wildmenu
    set noshowmode
  endif
"}}}

" plugin configuration {{{
  call plug#begin('~/.config/nvim/plugged')
  "{{{ core
    Plug 'vim-ctrlspace/vim-ctrlspace' "{{{
      let g:CtrlSpaceDefaultMappingKey = "<C-space> "
      let g:CtrlSpaceSaveWorkspaceOnSwitch = 1
      let g:CtrlSpaceSaveWorkspaceOnExit = 1
      let g:CtrlSpaceCacheDir = s:get_cache_dir('sessions')
      if executable("fd")
        let g:CtrlSpaceGlobCommand = 'fd -t f -c never'
      endif
      nnoremap <left> :CtrlSpaceGoUp<CR>
      nnoremap <right> :CtrlSpaceGoDown<CR>
      nnoremap <silent><expr> Q
        \ 1 == winnr('$') ? ":CtrlSpace cq\<CR>" :
        \ ":close\<CR>"
    "}}}
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-eunuch'
    Plug 'vifm/vifm.vim' "{{{
     nnoremap - :Vifm<CR>
    "}}}
    " Plug 'justinmk/vim-dirvish'
    Plug 'vim-airline/vim-airline' "{{{
      let g:airline#extensions#tabline#enabled = 1
      let g:airline#extensions#tagbar#enabled = 0
      let g:airline_powerline_fonts = 1
    "}}}
    Plug 'vim-airline/vim-airline-themes'
    Plug 'kassio/neoterm' "{{{
      let g:neoterm_autoinsert = 1
      let g:neoterm_default_mod = ":bo"

      " Use gx{text-object} in normal mode
      nmap gx <Plug>(neoterm-repl-send)

      " Send selected contents in visual mode.
      xmap gx <Plug>(neoterm-repl-send)

      " Send current line, 2gxx to send two lines
      nmap gxx <Plug>(neoterm-repl-send-line)
    "}}}
  "}}}
  "{{{ Ansible
    Plug 'pearofducks/ansible-vim', { 'do': 'cd ./UltiSnips; ./generate.py' }
  "}}}
  "{{{ web
    Plug 'othree/html5.vim', { 'for': ['html', 'htmldjango'] }
    Plug 'mattn/emmet-vim', { 'for': ['html', 'htmldjango', 'css'] }
    Plug 'gregsexton/MatchTag', { 'for': ['html','xml', 'htmldjango'] }
  "}}}
  "{{{ javascript
    Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
    Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
    Plug 'othree/javascript-libraries-syntax.vim', { 'for': ['javascript','coffee','ls','typescript'] } "{{{
      let g:used_javascript_libs = 'jquery,angularjs,angularui,jasmine'
    "}}}
  "}}}
  "{{{ json
    Plug 'elzr/vim-json', { 'for': 'json' } "{{{
      let g:vim_json_syntax_conceal = 0
    "}}}
  "}}}
  "{{{ java
    Plug 'vim-jp/vim-java', { 'for': 'java' }  " java syntax fix
  "}}}
  "{{{ markdown
    Plug 'jtratner/vim-flavored-markdown', { 'for': 'markdown' }
  "}}}
  "{{{ scm
    Plug 'chrisbra/vim-diff-enhanced', { 'on': 'EnhancedDiff' }
    Plug 'mhinz/vim-signify' "{{{
      let g:signify_update_on_bufenter=0
    "}}}
    Plug 'tpope/vim-fugitive' "{{{
      nnoremap <silent> <leader>gs :G<CR>
      nnoremap <silent> <leader>gd :Gdiff<CR>
      nnoremap <silent> <leader>gc :Gcommit<CR>
      nnoremap <silent> <leader>gb :Gblame<CR>
      nnoremap <silent> <leader>gl :0Glog<CR>
      nnoremap <silent> <leader>gp :Git push<CR>
      nnoremap <silent> <leader>gw :Gwrite<CR>
      nnoremap <silent> <leader>gr :Gremove<CR>
    "}}}
    Plug 'junegunn/gv.vim' "{{{
      nnoremap <silent> <leader>gv :GV<CR>
      nnoremap <silent> <leader>gV :GV!<CR>
      vnoremap <silent> <leader>gv :GV<CR>
      vnoremap <silent> <leader>gV :GV?<CR>
    "}}}
  "}}}
  "{{{ autocomplete
    Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}} "{{{
      " Use tab for trigger completion with characters ahead and navigate.
      " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
      inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      " Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
      " Coc only does snippet and additional edit on confirm.
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

      " Use K for show documentation in preview window
      nnoremap <silent> K :call <SID>show_documentation()<CR>

      " Remap for rename current word
      nmap <leader>rn <Plug>(coc-rename)

      " Remap for kill ring
      nnoremap <silent> gk :<C-u>CocList --normal yank<cr>
      " Remap for format selected region
      vmap <leader>f  <Plug>(coc-format-selected)
      nmap <leader>f  <Plug>(coc-format-selected)

      " Use `[g` and `]g` to navigate diagnostics
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " Remap keys for gotos
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " Using CocList
      " Show all diagnostics
      nnoremap <silent> <leader>ca  :<C-u>CocList diagnostics<cr>
      " Manage extensions
      nnoremap <silent> <leader>ce  :<C-u>CocList extensions<cr>
      " Show commands
      nnoremap <silent> <leader>cc  :<C-u>CocList commands<cr>
      " Find symbol of current document
      nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
      " Search workspace symbols
      nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent> <leader>cj  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent> <leader>ck  :<C-u>CocPrev<CR>
      " Resume latest coc list
      nnoremap <silent> <leader>cp  :<C-u>CocListResume<CR>

      " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
      vmap <leader>a  <Plug>(coc-codeaction-selected)
      nmap <leader>a  <Plug>(coc-codeaction-selected)

      " Remap for do codeAction of current line
      nmap <leader>ac  <Plug>(coc-codeaction)
      " Fix autofix problem of current line
      nmap <leader>qf  <Plug>(coc-fix-current)

      " Use `:Format` for format current buffer
      command! -nargs=0 Format :call CocAction('format')

      " Use `:Fold` for fold current buffer
      command! -nargs=? Fold :call     CocAction('fold', <f-args>)
    "}}}
  "}}}
  "{{{ editing
    Plug 'tpope/vim-rsi'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-commentary'
    Plug 'tmhedberg/matchit'
    Plug 'tommcdo/vim-exchange'
    Plug 'kshenoy/vim-signature'
    Plug 'jiangmiao/auto-pairs'
    Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] } "{{{
      nnoremap <leader>gg :Grepper<cr>
      nmap gs  <plug>(GrepperOperator)
      xmap gs  <plug>(GrepperOperator)
    "}}}
  "}}}
  "{{{ navigation
    Plug 'junegunn/fzf.vim' | Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --all' } "{{{
      map <leader><leader> :FZF<CR>
      nnoremap <leader>b :Buffers<cr>
      nnoremap <leader>l :BLines<cr>
      nnoremap <leader>L :Lines<cr>
      nnoremap <leader>t :BTags<cr>
      nnoremap <leader>T :Tags<cr>
      nmap <leader>ag :Ag<space>
      nmap <leader>aw :Ag <C-r><C-w>
      vmap <leader>aw y:Ag <C-r>0<CR>
    "}}}
    Plug 'justinmk/vim-sneak' "{{{
      let g:sneak#streak = 1
      let g:sneak#target_labels = ";sftunq/SFGHLTUNRMQZ?"
      let g:sneak#use_ic_scs = 1
      augroup SneakPluginColors
           autocmd!
           autocmd ColorScheme * hi SneakPluginScope  guifg=black guibg=yellow ctermfg=0 ctermbg=15
       augroup END
    "}}}
    Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } "{{{
      let g:undotree_WindowLayout='botright'
      let g:undotree_SetFocusWhenToggle=1
      nnoremap <silent> <F5> :UndotreeToggle<CR>
    "}}}
    Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' } "{{{
      nnoremap <silent> <F9> :TagbarToggle<CR>
    "}}}
  "}}}
  "{{{ textobj
     Plug 'wellle/targets.vim'
  "}}}
  "{{{ applications
    Plug 'gu-fan/riv.vim' "{{{
      let g:instant_rst_slow = 1
      let g:instant_rst_bind_scroll = 0
    "}}}
    Plug 'Rykka/InstantRst'
    Plug 'baverman/vial'
    Plug 'baverman/vial-http' "{{{
      let g:vial_python = 'python3'
    "}}}
  "}}}
  "{{{ misc
    Plug 'zenbro/mirror.vim'
    Plug 'tpope/vim-scriptease', { 'for': 'vim' }
    Plug 'Shougo/echodoc.vim' "{{{
      let g:echodoc_enable_at_startup = 1
    "}}}
    Plug 'mhinz/vim-startify' "{{{
      let g:startify_session_dir = s:get_cache_dir('sessions')
      let g:startify_change_to_vcs_root = 1
      let g:startify_show_sessions = 1
      nnoremap <F1> :Startify<cr>
    "}}}
    if exists('$TMUX') "{{{
      Plug 'christoomey/vim-tmux-navigator'
    endif "}}}
  "}}}
  " color schemes {{{
    Plug 'joshdick/onedark.vim'
    Plug 'cocopon/iceberg.vim'
    Plug 'arcticicestudio/nord-vim' "{{{
      let g:nord_italic = 1
      let g:nord_underline = 1
      let g:nord_italic_comments = 1
      let g:nord_cursor_line_number_background = 1
    "}}}
  "}}}
  call plug#end()
"}}}

" mappings {{{
  " formatting shortcuts
  nmap <leader>f$ :call StripTrailingWhitespace()<CR>

  nnoremap <leader>w :w<cr>

  " toggle paste
  map <F6> :set invpaste<CR>

  " remap arrow keys
  nnoremap <up> :tabprev<CR>
  nnoremap <down> :tabnext<CR>

  " handy mapping
  map <BS> :noh<CR>
  map \ %
  map H ^
  map L $

  " make method motion linewise in o mode
  onoremap ]M V]M
  onoremap [m V[m

  " much usefull Ctrl-K, delete to line end in insert mode
  inoremap <C-k> <C-o>D

  " system clipboard
  nnoremap <leader>y "+y
  vnoremap <leader>y "+y
  nnoremap <leader>p "+p
  vnoremap <leader>p "+p


  " command-line window {{{
    nnoremap q: q:i
    nnoremap q/ q/i
    nnoremap q? q?i
  " }}}

  " screen line scroll
  nnoremap <silent> j gj
  nnoremap <silent> k gk
  onoremap j gj
  onoremap k gk

  inoremap jk <Esc>

  " reselect visual block after indent
  vnoremap < <gv
  vnoremap > >gv

  " reselect last paste
  nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

  " find current word in quickfix
  nnoremap <leader>fw :execute "vimgrep ".expand("<cword>")." %"<cr>:copen<cr>
  " find last search in quickfix
  nnoremap <leader>ff :execute 'vimgrep /'.@/.'/g %'<cr>:copen<cr>

  " shortcuts for windows {{{
    nnoremap <leader>v <C-w>v<C-w>l
    nnoremap <leader>s <C-w>s
    nnoremap <c-h> <C-w>h
    nnoremap <c-j> <C-w>j
    nnoremap <c-k> <C-w>k
    nnoremap <c-l> <C-w>l
    tnoremap <c-h> <C-\><C-n><C-w>h
    tnoremap <c-l> <C-\><C-n><C-w>l
    tnoremap <c-j> <C-\><C-n><C-w>j
    tnoremap <c-k> <C-\><C-n><C-w>k
  "}}}

  " quick switch to last buffer
  map <leader><TAB> <C-^>

  " hide annoying quit message
  " nnoremap <C-c> <C-c>:echo<cr>

  " quick refactor
  vmap zz   V<Esc>gvygvgc`>p
  nmap zz   yygccp
"}}}

" autocmd {{{
  " go back to previous position of cursor if any
  augroup configgroup
    au!
    autocmd! BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \  exe 'normal! g`"zvzz' |
      \ endif

    " Setup formatexpr specified filetype(s).
    autocmd! FileType typescript,json setl formatexpr=CocAction('formatSelected')

    " Update signature help on jump placeholder
    autocmd! User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

    autocmd! FileType python,js,scss,css autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    autocmd! FileType css,scss setlocal foldmethod=marker foldmarker={,}
    autocmd! FileType python setlocal foldmethod=indent
    autocmd! FileType json setlocal foldmethod=syntax
    autocmd! FileType ghmarkdown setlocal nolist textwidth=80 formatoptions+=t
    autocmd! BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
    autocmd! FileType vim setlocal fdm=indent keywordprg=:help
  augroup END
"}}}

" finish loading {{{
  filetype plugin indent on
  try
      colorscheme nord
  catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme default
  endtry
"}}}

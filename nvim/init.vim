" Section: General Config {{{1
" ----------------------------
let mapleader = " "

set shell=zsh " Set bash as the prompt for Vim
set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
set noshowmode
set timeoutlen=1000
set ttimeoutlen=0
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set scrolloff=3
set list listchars=tab:»·,trail:·  " Display extra whitespace characters
set hidden
set inccommand=nosplit
set omnifunc=syntaxcomplete#Complete

" Line numbers
set number
set numberwidth=5

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Highlight search matches
set hlsearch
" And search as characters are entered
set incsearch

" Enable persistent undo so that undo history persists across vim sessions
set undofile
set undodir=~/.config/nvim/undo

" Make it obvious where 120 characters is {{{2
" Lifted from StackOverflow user Jeremy W. Sherman
" http://stackoverflow.com/a/3765575/2250435
if exists('+colorcolumn')
  set textwidth=120
  set colorcolumn=+1
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)
endif " }}}2
" Open new split panes to right and bottom, which feels more natural {{{2
set splitbelow
set splitright
" Point python checker to homebrew installs` {{{2
let g:python3_host_prog = '/usr/local/bin/python3'
let g:python_host_prog = '/usr/local/bin/python2'
" }}}2

" Point node checker to homebrew installs` {{{2
let g:node_host_prog = '/usr/local/bin/neovim-node-host'
" }}}2

" Configure grep to use The Silver Searcher {{{2
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  let g:ackprg='ag --vimgrep'

  command! -bang -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
endif
" }}}2
" Configure fzf in vim {{{2
let g:rg_command = 'rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g "!{.git,node_modules}" -g "*.{js,json,md,config,py,cpp,c,go,conf}" '

command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
" }}}2
" }}}1
" Section: Autocommands {{{1
" --------------------------
if has("autocmd")
  filetype plugin indent on

  autocmd BufReadPost * " {{{2
    " When editing a file, always jump to the last known cursor position.
    " Don't do it for commit messages, when the position is invalid, or when
    " inside an event handler (happens when dropping a file on gvim).
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif "}}}2

  " Automatically clean trailing whitespace
  autocmd BufWritePre * :%s/\s\+$//e

  autocmd BufRead,BufNewFile COMMIT_EDITMSG call pencil#init({'wrap': 'soft'})
                                        \ | set textwidth=0

  autocmd BufRead,BufNewFile *.md set filetype=markdown

  autocmd BufRead,BufNewFile .eslintrc,.jscsrc,.jshintrc,.babelrc set ft=json

  autocmd BufRead,BufNewFile gitconfig set ft=.gitconfig

endif
" }}}1
" Section: External Functions {{{

" Open current file in Marked {{{
function! MarkedPreview()
  :w
  exec ':silent !open -a "Marked 2.app" ' . shellescape('%:p')
  redraw!
endfunction
nnoremap <leader>md :call MarkedPreview()<CR>
" }}}
" Open current file in Sublime {{{
function! SublimeText()
    :w
    exec ':silent !open -a "Sublime Text.app" ' . shellescape('%:p')
    redraw!
endfunction
nnoremap <leader>sb :call SublimeText()<CR>
" }}}
" }}}
" Section: Load vim-plug plugins {{{

" Specify plugins {{{2
call plug#begin()

" UI {{{3
Plug 'mhartington/oceanic-next'
Plug 'sjl/badwolf'
Plug 'abra/vim-obsidian'
Plug 'vim-airline/vim-airline'            " Handy info
Plug 'retorillo/airline-tablemode.vim'
Plug 'edkolev/tmuxline.vim'               " Make the Tmux bar match Vim
Plug 'ryanoasis/vim-webdevicons'
Plug 'junegunn/goyo.vim'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'jez/vim-superman'                   " Man pages in Vim

" Project Navigation {{{3
Plug 'junegunn/fzf',                      { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-grepper'
Plug 'scrooloose/nerdtree',                { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-scripts/ctags.vim'              " ctags related stuff
Plug 'majutsushi/tagbar'
Plug 'mileszs/ack.vim'

" File Navigation {{{3
Plug 'vim-scripts/matchit.zip'            " More powerful % matching
Plug 'easymotion/vim-easymotion'            " Move like the wind!
Plug 'jeffkreeftmeijer/vim-numbertoggle'  " Smarter line numbers
Plug 'wellle/targets.vim'
Plug 'kshenoy/vim-signature'
Plug 'haya14busa/incsearch.vim'           " Better search highlighting

" Editing {{{3
Plug 'tpope/vim-surround'                 " Change word surroundings
Plug 'tpope/vim-commentary'               " Comments stuff
Plug 'tpope/vim-repeat'
Plug 'dhruvasagar/vim-table-mode',        { 'on': 'TableModeEnable' }
Plug 'kana/vim-textobj-user'
Plug 'sgur/vim-textobj-parameter'
Plug 'jasonlong/vim-textobj-css'
Plug 'Konfekt/FastFold'
Plug 'editorconfig/editorconfig-vim'
Plug 'simnalamburt/vim-mundo'
Plug 'scrooloose/nerdcommenter'

" Git
Plug 'tpope/vim-fugitive'                 " Git stuff in Vim
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim',                   { 'on': 'GV' }
Plug 'jez/vim-github-hub'

" Task Running
Plug 'tpope/vim-dispatch'                 " Run tasks asychronously in Tmux
Plug 'w0rp/ale'                           " Linter
Plug 'wincent/terminus'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Olical/vim-enmasse'                 " Edit all files in a Quickfix list
Plug 'janko-m/vim-test'

" Autocomplete {{{3
Plug 'Shougo/deoplete.nvim',              { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi'
Plug 'carlitux/deoplete-ternjs'
Plug 'steelsojka/deoplete-flow'

" Productivity
Plug 'git://github.com/wakatime/vim-wakatime.git'
Plug 'SirVer/ultisnips'

" Language Support {{{3
" JavaScript {{{4
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'rhysd/npm-debug-log.vim'

" Handlebars {{{4
Plug 'mustache/vim-mustache-handlebars'

" HTML {{{4
Plug 'othree/html5.vim',                  { 'for': 'html' }
Plug 'mattn/emmet-vim'

" CSS {{{4
Plug 'hail2u/vim-css3-syntax',            { 'for': 'css' }

" Sass {{{4
Plug 'cakebaker/scss-syntax.vim'

" Python {{{4
Plug 'klen/python-mode',                  { 'for': 'python' }
Plug 'davidhalter/jedi-vim',              { 'for': 'python' }
Plug 'alfredodeza/pytest.vim',            { 'for': 'python' }

" Go {{{4
Plug 'fatih/vim-go',                      { 'do': ':GoUpdateBinaries' }
Plug 'mdempsky/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }
Plug 'zchee/deoplete-go',                 { 'do': 'make'}

" Markdown {{{4
Plug 'reedes/vim-pencil'                  " Markdown, Writing
Plug 'godlygeek/tabular',                 { 'for': 'markdown' } " Needed for vim-markdown
Plug 'plasticboy/vim-markdown',           { 'for': 'markdown' }

" Java {{{4
Plug 'artur-shaik/vim-javacomplete2'

call plug#end()

" Load plugin configurations {{{2
" For some reason, a few plugins seem to have config options that cannot be
" placed in the `plugins` directory. Those settings can be found here instead.

" vim-airline {{{3
let g:airline_powerline_fonts = 1 " Enable the patched Powerline fonts

" emmet-vim {{{3
let g:user_emmet_leader_key='<C-E>'

let g:user_emmet_settings = {
  \    'html' : {
  \        'quote_char': "'"
  \    }
  \}


" vim-javacomplete2 {{{3
autocmd FileType java setlocal omnifunc=javacomplete#Complete
nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
imap <F4> <Plug>(JavaComplete-Imports-AddSmart)
nmap <F5> <Plug>(JavaComplete-Imports-Add)
imap <F5> <Plug>(JavaComplete-Imports-Add)
nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
" }}}3

" Section: Remaps {{{1

" Normal Mode Remaps {{{2

" Quickly find file in NERDTree
nnoremap <leader>f :NERDTreeFind<CR>

nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Smarter pasting
nnoremap <Leader>p :set invpaste paste?<CR>

" Smarter searching
nnoremap ] :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
nnoremap \ :Ag

" Remap :MundoToggle
nnoremap <leader>u :MundoToggle<CR>
" -- Smart indent when entering insert mode with i on empty lines --------------
function! IndentWithI()
  if len(getline('.')) == 0
    return "\"_ddO"
  else
    return "i"
  endif
endfunction
nnoremap <expr> i IndentWithI()

" save session
nnoremap <leader>s :mksession<CR><Paste>

" Remap the increment and decrement features of Vim
nnoremap <A-a> <C-a>
nnoremap å <C-a>

nnoremap <A-x> <C-x>
nnoremap ≈ <C-x>

" Tab Shortcuts
nnoremap tk :tabfirst<CR>
nnoremap tl :tabnext<CR>
nnoremap th :tabprev<CR>
nnoremap tj :tablast<CR>
nnoremap tn :tabnew<CR>
nnoremap tc :CtrlSpaceTabLabel<CR>
nnoremap td :tabclose<CR>

nnoremap <silent> <c-j> :TmuxNavigateDown<cr>

" EasyMotion config {{{3
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
" }}}3
" }}}2
" Insert Mode Remaps {{{2

set completeopt-=preview

" }}}2
" }}}1
" Section: Theme {{{

syntax enable
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
set background=dark
colorscheme OceanicNext

" Switch themes easily
nnoremap <leader>1 :colorscheme OceanicNext<cr>
nnoremap <leader>2 :colorscheme badwolf<cr>
nnoremap <leader>3 :colorscheme obsidian<cr>

" Badwolf stuff
let g:badwolf_darkgutter = 1
let g:badwolf_tabline = 2

hi Folded ctermbg=NONE guibg=NONE ctermfg=014 guifg=#0087d7
" Airline theme
let g:airline_theme='oceanicnext'

" Setup Terminal Colors For Neovim {{{
if has('nvim')
  " dark0 + gray
  let g:terminal_color_0 = "#282828"
  let g:terminal_color_8 = "#928374"

  " neurtral_red + bright_red
  let g:terminal_color_1 = "#cc241d"
  let g:terminal_color_9 = "#fb4934"

  " neutral_green + bright_green
  let g:terminal_color_2 = "#98971a"
  let g:terminal_color_10 = "#b8bb26"

  " neutral_yellow + bright_yellow
  let g:terminal_color_3 = "#d79921"
  let g:terminal_color_11 = "#fabd2f"

  " neutral_blue + bright_blue
  let g:terminal_color_4 = "#458588"
  let g:terminal_color_12 = "#83a598"

  " neutral_purple + bright_purple
  let g:terminal_color_5 = "#b16286"
  let g:terminal_color_13 = "#d3869b"

  " neutral_aqua + faded_aqua
  let g:terminal_color_6 = "#689d6a"
  let g:terminal_color_14 = "#8ec07c"

  " light4 + light1
  let g:terminal_color_7 = "#a89984"
  let g:terminal_color_15 = "#ebdbb2"
endif " }}}
" }}}
" Section: Local-Machine Config {{{

if filereadable($DOTFILES . "/nvim/init.local.vim")
  source $DOTFILES/nvim/init.local.vim
endif
" }}}

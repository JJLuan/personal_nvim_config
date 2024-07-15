set expandtab
set tabstop=4
set shiftwidth=4
set mouse=

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>
tnoremap <esc> <C-\><C-n>

" filenames like *.xml, *.html, *.xhtml, ...
" These are the file extensions where this plugin is enabled.
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xslt,*.xsl,*.xml'

" filenames like *.xml, *.xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'

" filetypes like xml, html, xhtml, ...
" These are the file types where this plugin is enabled.
"
let g:closetag_filetypes = 'html,xhtml,phtml,xslt,xsl,xml'

" filetypes like xml, xhtml, ...
" This will make the list of non-closing tags self-closing in the specified files.
"
let g:closetag_xhtml_filetypes = 'xhtml,jsx'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
"
let g:closetag_emptyTags_caseSensitive = 1

" dict
" Disables auto-close if not in a "valid" region (based on filetype)
"
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ 'typescriptreact': 'jsxRegion,tsxRegion',
    \ 'javascriptreact': 'jsxRegion',
    \ }

" Shortcut for closing tags, default is '>'
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
"
let g:closetag_close_shortcut = '<leader>>'


"let g:indentLine_setColors = 0

let hlstate=0
nnoremap <F4> :if (hlstate == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=1-hlstate<cr>

function! EvalXpath(xpath)
    normal! gg"0yG
    let result = system("xmllint --xpath \"". a:xpath ."\" -", getreg('0', 1, 1))
    let winnr = bufwinnr("__XpathResult__")
    let curwin = winnr()

    if winnr == -1
        vsplit __XpathResult__
    else
        execute winnr . "wincmd w"
    endif

    normal! ggdG
    setlocal filetype=xml
    setlocal buftype=nofile

    call append(0, ["<result>", substitute(result, '\n','','g'), "</result>"])
    execute "Px"
    execute curwin . "wincmd w"
endfunction

function! PrettifyXHTML(xh)
    let curpos = getpos(".")
    if a:xh == 0
        execute "%!xmllint --format --recover -"
    else
        execute "%!tidy --indent-spaces 4 -q -i"
    endif

    call setpos('.',curpos)
endfunction

function! OpenInFFox(path)
    "    let cleaned=substitute(substitute(a:path, "\/ ", "` ", "g"), '\/mnt\/\(.\)', "\1:", "")
    
    let path_=a:path
    if path_ == ""
        let path_=expand('%:p')
    endif
    if stridx(a:path, "/mnt/") == 0
        let cleaned=substitute(substitute(path_, "\/ ", "` ", "g"), '\/mnt\/\(.\)', '\1:', "")
        echo cleaned
        execute "!powershell.exe 'C:/Program` Files/Mozilla` Firefox/firefox.exe 'file://".cleaned
    else
        let cleaned="L:/".path_
        echo cleaned
        execute "!powershell.exe 'C:/Program` Files/Mozilla` Firefox/firefox.exe 'file://".cleaned
    endif
endfunction

function! OpenInFFoxURL(url)
    execute "!powershell.exe 'C:/Program` Files/Mozilla` Firefox/firefox.exe '".a:url
endfunction

function! SetXSLTXMLInput(path)
    let s:xml_input=a:path
    if a:path==""
        let s:xml_input=expand('%:p')
    endif
endfunction

function! SetXSLTStylesheet(path)
    let s:xslt=a:path
    if a:path==""
        let s:xslt=expand('%:p')
    endif
endfunction

function! SetXSLTOut(path)
    let s:xslt_out=a:path
    if a:path==""
        let s:xslt_out=getcwd()
    endif
endfunction

function! TransformXSLT(open, path)
    if s:xml_input=="" || s:xslt==""
       echoerr "s:xml_input ". s:xml_input . ", s:xslt ".s:xslt
    else
        execute "!xsltproc -o ".a:path." ".s:xslt." ".s:xml_input
    endif

    if a:open==1
        silent call OpenInFFox("./output/output.xml")
    endif
endfunction

function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! Px execute "silent call PrettifyXHTML(0) | set syntax=xml"
command! Ph execute "silent call PrettifyXHTML(1) | set syntx=html"
command! -range Fx execute "<line1>,<line2>!recode xml..ascii"
command! -range Fxx execute "<line1>,<line2>!recode ascii..xml"
command! -nargs=1 Xp execute "silent call EvalXpath(\"<args>\")"
command! Of execute "expand('%:p') | silent call OpenInFFox("")"
command! Si execute "silent call SetXSLTXMLInput('')"
command! Ss execute "silent call SetXSLTStylesheet('')"
command! So execute "silent call SetXSLTOut('')"
command! -nargs=1 Ts execute "call TransformXSLT(0, \"<args>\")"
command! -nargs=1 To execute "call TransformXSLT(1, \"<args>\")"
command! Pj execute "set syntax=json | %! python3 -mjson.tool"
command! -register CopyMatches call CopyMatches(<q-reg>)
command! LtC %s/\n\(.\)/, \1/ | %s/\(^\s\+\)\|\(\s\+$\)//ge

" set to 1, nvim will open the preview window after entering the Markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when changing
" from Markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, Vim will refresh Markdown when saving the buffer or
" when leaving insert mode. Default 0 is auto-refresh Markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be used for all files,
" by default it can be use in Markdown files only
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, the preview server is available to others in your network.
" By default, the server listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" use custom IP to open preview page.
" Useful when you work in remote Vim and preview on local browser.
" For more details see: https://github.com/iamcco/markdown-preview.nvim/pull/9
" default empty
let g:mkdp_open_ip = ''

" specify browser to open preview page
" for path with space
" valid: `/path/with\ space/xxx`
" invalid: `/path/with\\ space/xxx`
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page URL in command line when opening preview page
" default is 0
let g:mkdp_echo_preview_url = 0

" a custom Vim function name to open preview page
" this function will receive URL as param
" default is empty
let g:mkdp_browserfunc = ''

" options for Markdown rendering
" mkit: markdown-it options for rendering
" katex: KaTeX options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: whether to disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: means the cursor position is always at the middle of the preview page
"   top: means the Vim top viewport always shows up at the top of the preview page
"   relative: means the cursor position is always at relative positon of the preview page
" hide_yaml_meta: whether to hide YAML metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
" content_editable: if enable content editable for preview page, default: v:false
" disable_filename: if disable filename header for preview page, default: 0
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }

" use a custom Markdown style. Must be an absolute path
" like '/Users/username/markdown.css' or expand('~/markdown.css')
let g:mkdp_markdown_css = ''

" use a custom highlight style. Must be an absolute path
" like '/Users/username/highlight.css' or expand('~/highlight.css')
let g:mkdp_highlight_css = ''

" use a custom port to start server or empty for random
let g:mkdp_port = ''

" preview page title
" ${name} will be replace with the file name
let g:mkdp_page_title = '「${name}」'

" use a custom location for images
"let g:mkdp_images_path = /home/user/.markdown_images

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown']

" set default theme (dark or light)
" By default the theme is defined according to the preferences of the system
let g:mkdp_theme = 'dark'

" combine preview window
" default: 0
" if enable it will reuse previous opened preview window when you preview markdown file.
" ensure to set let g:mkdp_auto_close = 0 if you have enable this option
let g:mkdp_combine_preview = 0

" auto refetch combine preview contents when change markdown buffer
" only when g:mkdp_combine_preview is 1
let g:mkdp_combine_preview_auto_refresh = 1

call plug#begin()
    Plug 'scrooloose/nerdtree'
    Plug 'tpope/vim-surround'
    Plug 'airblade/vim-gitgutter'
    Plug 'kien/rainbow_parentheses.vim'
    Plug 'chrisbra/vim-xml-runtime'
    Plug 'alvan/vim-closetag'
    Plug 'lambdalisue/suda.vim'
    Plug 'Yggdroot/indentLine'
    Plug 'jeetsukumaran/vim-indentwise'
    Plug 'chrisbra/csv.vim'
    Plug 'pprovost/vim-ps1'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' } 
    Plug 'folke/tokyonight.nvim'
    Plug 'akinsho/toggleterm.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'nvim-treesitter/nvim-treesitter-context'
    Plug 'mkitt/tabline.vim'
call plug#end()

lua << EOF 
require("toggleterm").setup{
   open_mapping = [[<c-\>]],
   terminal_mappings = true,
   persist_mode = true,
   start_in_insert = true,
   insert_mappings = true,
   direction = 'horizontal'
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<C-\\>', [[<C-\><C-n><C-\>]], opts)
  vim.keymap.set('t', '<C-w>', [[C-\><C-n><C-w>]], opts)
end

require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
  },
  ensure_installed = {
      "vimdoc",
      "luadoc",
      "vim",
      "lua",
      "markdown"
  }
}


EOF

autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()

colorscheme tokyonight

highlight ColorColumn ctermbg=magenta guibg=DarkCyan
call matchadd('ColorColumn', '\%81v', 100)

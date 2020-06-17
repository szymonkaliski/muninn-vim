# muninn-vim

`muninn-vim` is set of vim functions designed to simplify [`muninn`](https://github.com/szymonkaliski/muninn) use in vim.

This plugin depends on [`muninn`](https://github.com/szymonkaliski/muninn) being (globally) installed and configured.

Tested only on MacOS Mojave, released as-is, I'm supporting this only for myself and most probably won't fix bugs that don't happen for me.

## Installation

With vim-plug: `Plug 'szymonkaliski/muninn-vim'`, other plugin managers should also work.

## Usage

`muninn-vim` provides no mapping or commands on its own, here's a snippet from my config:

```vim
let g:muninn_path = expand('~/Documents/Dropbox/Wiki/') " configure muninn wiki path, required!

function! s:open_today()
  " opens today daily log plus quickfix window with tasks

  call muninn#journal_today()
  call muninn#tasks_today()
endfunction

" commands
command! Tasks         call muninn#tasks_today()
command! Today         call <sid>open_today()

command! WikiJournal   call muninn#journal_today()
command! WikiInbox     call muninn#open('inbox')
command! WikiBacklinks call muninn#backlinks()
command! WikiUI        call muninn#open_ui()

command! -nargs=? -complete=custom,muninn#complete_open Wiki call muninn#open(<f-args>)

" maps
nnoremap <leader>wt :Tasks<cr>
nnoremap <leader>wj :WikiJournal<cr>
nnoremap <leader>wi :WikiInbox<cr>
nnoremap <leader>wb :WikiBacklinks<cr>
nnoremap <leader>wu :WikiUI<cr>

" bindings for working with tasks:
" - td - toggle to[d]o
" - tt - task for [t]oday
" - tm - task for to[m]orrow
" - tw - task is [w]aiting

augroup muninn_markdown
  autocmd!

  autocmd FileType markdown nnoremap <buffer> <leader>td :<c-u>call muninn#toggle_todo()<cr>
  autocmd FileType markdown nnoremap <buffer> <leader>tm :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d', localtime() + 86400)<cr>')<cr>
  autocmd FileType markdown nnoremap <buffer> <leader>tt :<c-u>call muninn#toggle_tag('due', '<c-r>=strftime('%Y-%m-%d')<cr>')<cr>
  autocmd FileType markdown nnoremap <buffer> <leader>tw :<c-u>call muninn#toggle_tag('waiting', '')<cr>
augroup END
```

I also recommend adding additional markdown highlighting rules for tags and tasks, mine extend [`plasticboy/vim-markdown`](https://github.com/plasticboy/vim-markdown) syntax:

```vim
" - list item @any(tag with comments)
" - list item @tag-without-comments
syntax match markdownTag /\ @\S*/     containedin=mkdListItemLine
syntax match markdownTag /\ @\S*(.*)/ containedin=mkdListItemLine

" - list item @due(today-date)
execute "syntax match markdownTodoToday '\ @due(" . strftime('%Y-%m-%d') . ")' containedin=mkdListItemLine"

" - [ ] empty checkbox
" - [x] checked checkbox
syntax match markdownListItemCheckbox /^\s*-\ \[x\]\ .*$/
syntax match markdownUnchecked "\[ \]" containedin=mkdListItemLine,markdownListItemCheckbox
syntax match markdownChecked   "\[x\]" containedin=mkdListItemLine,markdownListItemCheckbox

" ~~strikethrough~~
syntax region markdownStrikethrough start="\S\@<=\~\~\|\~\~\S\@=" end="\S\@<=\~\~\|\~\~\S\@=" keepend containedin=ALL
syntax match markdownStrikethroughLines "\~\~" conceal containedin=markdownStrikethrough

highlight def link markdownStrikethroughLines Comment
highlight def link markdownStrikethrough      Comment
```

## Backlog

- [ ] completion for linking notes

" some parts borrowed and adapted from taskpaper.vim

if exists('g:loaded_muninn') || &cp
  finish
endif

let g:loaded_muninn = 1

function! muninn#wiki_path()
  if !exists('g:muninn_path')
    echo 'muninn path not configured!'
    finish
  endif

  return g:muninn_path
endfunction

function! muninn#toggle_todo()
  if len(matchlist(getline('.'),'- \[ \]')) > 0
    " not done, mark done
    exe ':s/- \[ \]/- [x]/'
  elseif len(matchlist(getline('.'),'- \[x\]')) > 0
    " done, mark un-done
    exe ':s/- \[x\]/- [ ]/'
  endif
endfunction

function! s:add_delete_tag(tag, value, add)
  let cur_line = getline(".")

  let tag = " @" . a:tag
  if a:value != ''
    let tag .= "(" . a:value . ")"
  endif

  " add tag
  if a:add
    let new_line = cur_line . tag
    call setline(".", new_line)
    return 1
  endif

  " delete tag
  if cur_line =~# '\V' . tag
    if a:value != ''
      let new_line = substitute(cur_line, '\V' . tag, "", "g")
    else
      let new_line = substitute(cur_line, '\V' . tag . '\v(\([^)]*\))?', "", "g")
    endif

    call setline(".", new_line)
    return 1
  endif

  return 0
endfunction

function! muninn#add_tag(tag, ...)
  let value = a:0 > 0 ? a:1 : input('Value: ')
  return s:add_delete_tag(a:tag, value, 1)
endfunction

function! muninn#delete_tag(tag, ...)
  let value = a:0 > 0 ? a:1 : ''
  return s:add_delete_tag(a:tag, value, 0)
endfunction

function! muninn#toggle_tag(tag, ...)
  if !muninn#delete_tag(a:tag, '')
    let args = a:0 > 0 ? [a:tag, a:1] : [a:tag]
    call call("muninn#add_tag", args)
  endif
endfunction

function! muninn#open(...)
  if len(a:000)
    exe ':e! ' . muninn#wiki_path() . fnameescape(join(a:000, ' ')) . '.md'
  else
    exe ':e! ' . muninn#wiki_path()
  endif
endfunction

function! muninn#complete_open(A, L, P)
  return system('cd ' . muninn#wiki_path() . ' && ls **/*.md | sed "s/.md//"')
endfunction

function! muninn#journal_today()
  let l:path = muninn#wiki_path() . 'Journal/' . strftime('%Y-%m-%d') . '.md'

  exe ':e! ' . l:path

  if !filereadable(expand(l:path))
    call append(0, '# ' . strftime('%Y-%m-%d'))
  endif
endfunction

function! muninn#command_to_qflist(cmd, title)
  let l:lines = system(a:cmd)
  let l:items = []

  for l:line in split(l:lines, '\n')
    let l:parts    = split(l:line, ':')

    let l:filename = get(l:parts, 0)
    let l:line     = get(l:parts, 1)
    let l:column   = get(l:parts, 2)
    let l:matches  = join(l:parts[3:], ':')

    call add(l:items, {
          \ 'filename': muninn#wiki_path() . l:filename,
          \ 'lnum':     l:line,
          \ 'col':      l:column,
          \ 'text':     l:matches,
          \ })
  endfor

  let l:list = getqflist()
  call setqflist(l:list, 'r', { 'title': a:title, 'items': l:items })

  copen
endfunction

function! muninn#backlinks()
  let l:cmd   = 'muninn backlinks --file "' . expand('%:p') . '" --vim'
  let l:title = 'Backlinks for: ' . expand('%:r')

  exe muninn#command_to_qflist(l:cmd, l:title)
endfunction

function! muninn#tasks_today()
  let l:cmd   = 'muninn tasks --days 1 --vim'
  let l:title = 'Tasks'

  exe muninn#command_to_qflist(l:cmd, l:title)
endfunction

function! muninn#get_asset(url)
  echo "Adding asset: " . a:url

  let l:cmd = 'muninn get-asset --file "' . expand('%:p') . '" --url "' . a:url . '"'
  let l:output = system(l:cmd)

  call append(line('.'), split(l:output, '\n'))

  echo "Done!"
endfunction

function! muninn#open_ui()
  exe ':cd ' . muninn#wiki_path()

  let l:status = system('lsof -i :8080')
  let l:path = expand('%p')

  if len(l:status) == 0
    split
    resize 2
    exe ':terminal muninn ui'
    wincmd k
    sleep 1
  endif

  silent! exe '!open "http://localhost:8080/\#/' . l:path . '"'
  redraw!
endfunction

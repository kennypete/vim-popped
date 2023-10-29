function! vim82popped#Popped()
" Global variables {{{
let g:borderchars = exists("g:borderchars") ?
      \ g:borderchars :
      \ [' ', ' ', '—', ' ', ' ', ' ', '—', '—']
" }}}
" Fpdc (command: CpDialogCommand; abbrev: Cpdc) {{{
"
"	Creates a popup dialog with the output of a command.  For example:
"	     :CpDialogCommand pwd
"	will return something like:
"	
"	      :pwd                               X
"	       D:\Program Files (Portable)\vim90
"	     —————————————————————————————————————
"	
"	:h popped-CpDialogCommand
"
command! -nargs=+ -complete=command CpDialogCommand redir => g:redir
      \ | silent execute <q-args>
      \ | redir END
      \ | let g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
      \ | let g:popup_txt = split(g:redir_sub, "|")
      \ | call popup_dialog(g:popup_txt,
      \        #{borderchars: g:borderchars,
      \        title: ":" .. <q-args> .. "  ",
      \        close: "button",
      \        filter: "popup_filter_yesno"})
cnoreabbrev Cpdc CpDialogCommand
" }}}
" Fpdct (command: CpDialogCommandTimer; abbrev: Cpdct) {{{
"
"	Creates a popup dialog with the time, in seconds, that it takes
"	to run a command.  For example, take following command:
"	     :CpDialogCommandTimer pwd
"	will return something like:
"	
"	      :pwd                X
"	         0.000541 seconds
"	     ——————————————————————
"	
"	:h popped-CpDialogCommandTimer
"
command! -nargs=+ -complete=command CpDialogCommandTimer
      \ let g:start = reltime()
      \ | silent execute <q-args>
      \ | let g:elapsed = reltimestr(reltime(g:start, reltime()))
      \ | call popup_dialog(g:elapsed .. " seconds",
      \ #{borderchars: g:borderchars,
      \ title: ":" .. <q-args> .. "  ",
      \ close: "none",
      \ filter: "popup_filter_yesno"})
cnoreabbrev Cpdct CpDialogCommandTimer
" }}}
" Fpdtc (command: CpDialogTitleCommand; abbrev: Cpdtc) {{{
"
"	Similar to CpDialogCommand but for the popup's title is passed as
"	the first list item.  For example:
"	     :CpDialogCommand echo " Working directory " | pwd
"	will return something like:
"	
"	      Working directory                   X
"	         D:\Program Files (Portable)\vim9
"	     —————————————————————————————————————
"	
"	:h popped-CpDialogTitleCommand
"
command! -nargs=+ -complete=command CpDialogTitleCommand redir => g:redir
      \ | silent execute <q-args>
      \ | redir END
      \ | let g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
      \ | let g:popup_txt = split(g:redir_sub, "|")
      \ | let g:popup_title = g:popup_txt[0]
      \ | call remove(g:popup_txt, 0)
      \ | call popup_dialog(g:popup_txt,
      \       #{borderchars: g:borderchars,
      \       title: g:popup_title,
      \       close: "button",
      \       filter: "popup_filter_yesno"})
" }}}
" Fpmb (command: CpMenuBuffers; abbrev: Cpmb) {{{
"
"	Creates a popup menu with the output of a command, and designed
"	specifically to take "buffers" or "buffers!" (or their synomyms, "ls"
"	and "files" - refer :h buffers) insofar as the callback function will
"	change the current window to the buffer the user selects.
"	
"	For example, the command:
"	     :CpMenuBuffers buffers!
"	
"	This creates a popup menu with all buffers (including "unlisted" ones,
"	so help buffers and others too).
"	
"	The user may select one of the buffers, which are presented in
"	exactly the same way as if the buffers/buffers! command was entered
"	on Vim's cmdline.  Alternatively, <Esc> or 'x' will close
"	the popup window.  If a buffer is selected from the popup menu,
"	the selected buffer will be made active in the window that you were
"	in (i.e., when the command was executed).
"
"	:h popped-CpMenuBuffers
"
function FCpMenuBuffersCallback(id, result)
  if a:result > 0
    let c = tabpagenr()
    for t in range(tabpagenr('$'))
      execute ':norm ' .. (t + 1) .. 'gt'
      for w in range(1, winnr('$'))
        if winbufnr(w) == str2nr(split(g:popup_txt[a:result - 1])[0])
          " The buffer does exist in a window, so go to it
          execute ':' .. w .. 'wincmd w'
          return
        endif
      endfor
    endfor
    " If the buffer is not already in a window, :sbuffer it
    execute ":sbuffer " .. str2nr(split(g:popup_txt[a:result - 1])[0])
    if &buftype == 'help'
      set nolist
    endif
  endif
endfunction
command! -nargs=1 -complete=command CpMenuBuffers redir => g:redir
      \ | silent execute <q-args>
      \ | redir END
      \ | let g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
      \ | let g:popup_txt = split(g:redir_sub, "|")
      \ | if len(g:popup_txt) == 1
      \ |   call popup_menu(g:popup_txt,
      \          #{borderchars: g:borderchars,
        \        title: ":" .. <q-args> .. "  ",
        \        drag: 1,
        \        close: "none"})
      \ | else
        \ | call popup_menu(g:popup_txt,
        \        #{borderchars: g:borderchars,
        \        title: ":" .. <q-args> .. "  ",
        \        drag: 1,
        \        callback: 'FCpMenuBuffersCallback',
        \        close: "none"})
      \ | endif
cnoreabbrev Cpmb CpMenuBuffers
" }}}
" Mappings {{{
"	<Leader>b {{{2
"
"	- Set only if the <Leader>b mapping does not already exist.
"	- Using nnoremap: mapping only in Normal mode, no others.
"
"	The :buffers command (and its synomyms, :ls and :files) create
"	a list of the "listed" buffers.  Refer :h unlisted-buffer
"
"	Combined with :CpMenuBuffers, the command output is adjusted to
"	present a menu of selectable buffers.  For more details, see
"	CpMenuBuffers, above.
"
if maparg('<Leader>b', '') == ''
  noremap <silent><Leader>b :CpMenuBuffers buffers<CR>
endif
" 2}}}
"	<Leader><S-b>	{{{2
"
"	This is the same as <Leader>b except it uses <S-b> to send
"	buffers! instead of buffers - that means the popup menu will
"	incude "unlisted" buffers, such as help buffers.
"
if maparg('<Leader><S-b>', '') == ''
  nnoremap <silent><Leader><S-b> :CpMenuBuffers buffers!<CR>
endif
" 2}}}
"	gA	{{{2
"
"	- Set only if the gA mapping does not already exist.
"	- Using nnoremap means the mapping works in Normal mode only.
"
"	The inbuilt ga command (:h ga), by default, provides information
"	about the chararacter under the cursor.  That information is the
"	character's ASCII values in decimal, hexadecimal, and octal.
"	
"	This mapping expands on that to provide lots of additional information
"	in a popup dialog.  The code is fairly easy to understand, but for
"	completeness:
"	
"	       gA is the title
"	       ga is explained above.  However, if you also use T Pope's
"	          vim-characterize plugin, it will also provide information
"	          about the Unicode name, digraphs (^K in Insert mode) entry
"	          details, emoji and HTML5 named character references (in the
"	          cmdline statusmsg area.
"	       g8 provides the hexadecimal values of the UTF-8 bytes
"	          of the character under the cursor - :h g8
"	       synIDattr(synID(line("."), col("."), 1), "name") provides the
"	          active highlight group information - :h synIDattr()
"	       <cword> provides the word under the cursor - :h word and
"	          :h <cword>
"	       <cWORD> provides the WORD under the cursor - :h WORD and
"	          :h <cWORD>
"	       expand('%:t') provides the file name (tail) - :h expand()
"	       getcwd() provides the current working directory
function g:FgA()
  " display either the builtin or mapped output of the ga command
  redir => g:redir
  silent echo "ga     "
  " vim crashes if the mapped version of ga (vim-characterize) is used here!
  silent execute "silent norm! ga"
  silent echo "|UTF-8  "
  silent execute "silent norm! g8"
  redir END
  execute "norm ga"
  return substitute(g:redir, "\n", "", "g")
endfunction
if maparg('gA', 'n') == ''
  nnoremap gA
    \ :let g:ga8 = g:FgA() | CpDialogTitleCommand echo '“gA” ' |
    \ echo g:ga8 |
    \ echo 'hi     ' .. synIDattr(synID(line("."), col("."), 1), "name") |
    \ echo 'word   ' .. expand('<cword>') |
    \ echo 'WORD   ' .. expand('<cWORD>') |
    \ echo 'file   ' .. expand('%:t') |
    \ echo 'cwd    ' .. getcwd() <CR>
endif
" 2}}}
" }}}
endfunction
" vim: cc=+1 et fdm=marker ft=vim sta sts=0 sw=2 ts=8 tw=79

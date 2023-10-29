" BSD 3-Clause License - Copyright © 2023 Peter Kenny
" vim9-mix - whether to use vim9script, vimscript, or finish {{{
" If equivalent of v:versionlong >= 8024058, import vim9script.  :h vim9-mix
if (v:version < 802 || (v:version == 802 && !has('patch4058')))
  if has('patch-8.2.3434')
    " Between v:versionlong >= 8023434 and <= 8024057, use vimscript functions
    call vim82popped#Popped()
  else
    " Ideally, in your .vimrc, only source/packadd vim-popped if >=8023434
    " i.e., this, which works for Vim <8.2.3434 and Neovim (as it's 801):
    "   if v:version > 802 || (v:version == 802 && has('patch3434'))
    "     packadd! vim-popped
    "   endif
    " However, this ensures things do not break if that's not done, and _may_
    " display a message, depending on other settings, plugins, etc.
    " (Could use "elseif has('nvim')", but because Neovim returns 8.1 for
    " v:version, "else" covers all <8.2.3434 scenarios.)
    if !exists('g:popped_nowarn')
      echom 'vim-popped doesn’t work with either Vim <=8023434 or Neovim.'
    endif
  endif
  finish
endif
" }}}
vim9script
import autoload 'vim9popped.vim'
# g:borderchars {{{
g:borderchars = exists("g:borderchars") ?
      \ g:borderchars : [' ', ' ', '—', ' ', ' ', ' ', '—', '—']
# }}}
# Commands {{{
command! -nargs=1 -complete=command CpDialogCommand
      \ vim9popped.Fpdc(<q-args>)
command! -nargs=1 -complete=command CpDialogCommandTimer
      \ vim9popped.Fpdct(<q-args>)
command! -nargs=1 -complete=command CpDialogTitleCommand
      \ vim9popped.Fpdtc(<q-args>)
command! -nargs=1 -complete=command CpMenuBuffers
      \ vim9popped.Fpmb(<q-args>)
#}}}
# Abbrevations {{{
cnoreabbrev Cpdc CpDialogCommand
cnoreabbrev Cpdct CpDialogCommandTimer
cnoreabbrev Cpdtc CpDialogTitleCommand
cnoreabbrev Cpmb CpMenuBuffers
# }}}
# Mappings {{{
#	<Leader>b {{{2
#	- Set only if the <Leader>b mapping does not already exist.
#	- Using nnoremap: mapping only in Normal mode, no others.
#	- The :buffers command (and its synonyms, :ls and :files) create
#	  a list of the "listed" buffers.  Refer :h unlisted-buffer
#	- Combined with :CpMenuBuffers, the command output is adjusted to
#	  present a menu of selectable buffers.  For more details, see
#	  CpMenuBuffers in autoload/vim9popped.vim or :h CpMenuBuffers.
if maparg('<Leader>b', '') == ''
  nnoremap <silent><Leader>b :CpMenuBuffers buffers<CR>
endif
# 2}}}
#	<Leader><S-b> {{{2
#	- This is the same as <Leader>b except it uses <S-b> to send
#	  buffers! instead of buffers - that means the popup menu will
#	  include "unlisted" buffers, such as help buffers.
if maparg('<Leader><S-b>', '') == ''
  nnoremap <silent><Leader><S-b> :CpMenuBuffers buffers!<CR>
endif
# 2}}}
#	gA {{{2
#	- Set only if the gA mapping does not already exist.
#	- Using nnoremap means the mapping works in Normal mode only.
#	- The inbuilt ga command (:h ga), by default, provides information
#	  about the character under the cursor.  That information is the
#	  character's ASCII values in decimal, hexadecimal, and octal.
#	- This mapping expands on that to provide lots of additional
#	  information in a popup dialog.  The code is fairly easy to
#	  understand, but for completeness:
#	       gA is the title
#	       ga is explained above
#	       g8 provides the hexadecimal values of the UTF-8 bytes
#	          of the character under the cursor - :h g8
#	       synIDattr(synID(line("."), col("."), 1), "name") provides the
#	          active highlight group information - :h synIDattr()
#	       <cword> provides the word under the cursor - :h word and
#	          :h <cword>
#	       <cWORD> provides the WORD under the cursor - :h WORD and
#	          :h <cWORD>
#	       expand('%:t') provides the file name (tail) - :h expand()
#	       getcwd() provides the current working directory
if maparg('gA', 'n') == ''
  def g:FgA(): void
    redir => g:redir
    silent echo "ga     "
    # vim crashes if the vim-characterize mapped version of ga is used here!
    silent execute "silent norm! ga"
    silent echo "|UTF-8  "
    silent execute "silent norm! g8"
    redir END
    g:redir_sub = substitute(g:redir, "\n", "", "g")
    # display either the builtin or vim-characterize output of the ga command
    execute "norm ga"
  enddef
  nnoremap gA
    \ :call g:FgA() | CpDialogTitleCommand echo '“gA” ' |
    \ echo g:redir_sub |
    \ echo 'hi     ' .. synIDattr(synID(line("."), col("."), 1), "name") |
    \ echo 'word   ' .. expand('<cword>') |
    \ echo 'WORD   ' .. expand('<cWORD>') |
    \ echo 'file   ' .. expand('%:t') |
    \ echo 'cwd    ' .. getcwd() <CR>
endif
# 2}}}
#}}}
# Compatibility: Vim versions {{{
#
# Vim9 or Vim8.2 with patch 4058 (2022-01-11) onwards work without errors.
# So, 8.2.4058 has been made the bright line cut-off for vim9script,
# not v:version>=900 per se (which would exclude all 8.2 versions) and not
# has('vim9script'), because that returns 1 all the way back to patch 3965.
# Incidentally, the following commit added vim9script:
#   https://github.com/vim/vim/commit/b79ee0c299d786627784f7304ba84b80e78ece26
#
# Versions 8.2.3434 and 8.2.4057 work for the popup functions, but they need
# to use vimscript, not vim9script.  Any version prior to 8.2.3434 is limited
# by the inbuilt popup_* functions being buggy.
#
# Neovim specifically is incompatible because it does not include popup_*
# functions, at least at the time of writing.  Compare:
#    https://vimhelp.org/builtin.txt.html#builtin.txt
#    https://neovim.io/doc/user/builtin.html#builtin-function-details
# }}}
# vim: cc=+1 et fdm=marker ft=vim sta sts=0 sw=2 ts=8 tw=79

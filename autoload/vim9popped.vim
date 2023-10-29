vim9script
# Fpdc (command: CpDialogCommand; abbrev: Cpdc) {{{
export def Fpdc(argcommand: string)
#
#	Creates a popup dialog with the output of a command.  For example:
#	     :CpDialogCommand pwd
#	will return something like:
#	
#	      :pwd                               X
#	       D:\Program Files (Portable)\vim90
#	     —————————————————————————————————————
#	
#	:h popped-CpDialogCommand
#
  redir => g:redir
  silent execute argcommand
  redir END
  g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
  g:popup_txt = split(g:redir_sub, "|")
  popup_dialog(g:popup_txt,
      \ {borderchars: g:borderchars,
      \ title: ":" .. argcommand .. "   ",
      \ close: "button",
      \ filter: "popup_filter_yesno"})
enddef
# }}}
# Fpdct (command: CpDialogCommandTimer; abbrev: Cpdct) {{{
export def Fpdct(argcommand: string)
#
#	Creates a popup dialog with the time, in seconds, that it takes
#	to run a command.  For example, take following command:
#	     :CpDialogCommandTimer pwd
#	will return something like:
#	
#	      :pwd                X
#	         0.000541 seconds
#	     ——————————————————————
#	
#	:h popped-CpDialogCommandTimer
#
  g:start = reltime()
  silent execute argcommand
  g:elapsed = reltimestr(reltime(g:start, reltime()))
  popup_dialog(g:elapsed .. " seconds",
      \ {borderchars: g:borderchars,
      \ title: ":" .. argcommand .. "   ",
      \ close: "button",
      \ filter: "popup_filter_yesno"})
enddef
# }}}
# Fpdtc (command: CpDialogTitleCommand; abbrev: Cpdtc) {{{
export def Fpdtc(argcommand: string)
#
#	Similar to CpDialogCommand but for the popup's title is passed as
#	the first list item.  For example:
#	     :CpDialogCommand echo " Working directory " | pwd
#	will return something like:
#	
#	      Working directory                   X
#	         D:\Program Files (Portable)\vim9
#	     —————————————————————————————————————
#	
#	:h popped-CpDialogTitleCommand
#
  redir => g:redir
  silent execute argcommand
  redir END
  g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
  g:popup_txt = split(g:redir_sub, "|")
  g:popup_title = g:popup_txt[0]
  remove(g:popup_txt, 0)
  popup_dialog(g:popup_txt,
      \ {borderchars: g:borderchars,
      \ title: g:popup_title,
      \ close: "button",
      \ filter: "popup_filter_yesno"})
enddef
# }}}
# Fpmb (command: CpMenuBuffers; abbrev: Cpmb) {{{
export def Fpmb(argcommand: string)
#
#	Creates a popup menu with the output of a command, and designed
#	specifically to take "buffers" or "buffers!" (or their synomyms, "ls"
#	and "files" - refer :h buffers) insofar as the callback function will
#	change the current window to the buffer the user selects.
#	
#	For example, the command:
#	     :CpMenuBuffers buffers!
#	
#	This creates a popup menu with all buffers (including "unlisted" ones,
#	so help buffers and others too).
#	
#	The user may select one of the buffers, which are presented in
#	exactly the same way as if the buffers/buffers! command was entered
#	on the vim cmdline.  Alternatively, <Esc> or 'x' will close
#	the popup window.  If a buffer is selected from the popup menu,
#	the selected buffer will be made active in the window that you were
#	in (i.e., when the command was executed).
#	
#	:h popped-CpMenuBuffers
#
  def FCpMenuBuffersCallback(id: number, result: number)
    if result > 0
      var c = tabpagenr()
      for t in range(tabpagenr('$'))
        execute ':norm ' .. (t + 1) .. 'gt'
        for w in range(1, winnr('$'))
          if winbufnr(w) == str2nr(split(g:popup_txt[result - 1])[0])
            # The buffer does exist in a window, so go to it
            execute ':' .. w .. 'wincmd w'
            return
          endif
        endfor
      endfor
      # If the buffer is not already in a window, :sbuffer it
      execute ":sbuffer " .. str2nr(split(g:popup_txt[result - 1])[0])
      if &buftype == 'help'
        set nolist
      endif
    endif
  enddef
  redir => g:redir
  silent execute argcommand
  redir END
  g:redir_sub = substitute(strtrans(g:redir), '\^@', '|', 'g')
  g:popup_txt = split(g:redir_sub, "|")
  if len(g:popup_txt) == 1
  popup_menu(g:popup_txt,
        \ {borderchars: g:borderchars,
        \ title: ":" .. argcommand .. "   ",
        \ close: "none"})
  else
  popup_menu(g:popup_txt,
        \ {borderchars: g:borderchars,
        \ title: ":" .. argcommand .. "   ",
        \ callback: FCpMenuBuffersCallback,
        \ close: "none"})
  endif
enddef
# }}}
# vim: cc=+1 et fdm=marker ft=vim sta sts=0 sw=2 ts=8 tw=79

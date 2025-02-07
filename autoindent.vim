if empty($OUTPUT_FILE)
  echom "Error: Environment variable OUTPUT_FILE is not set."
  cquit! 1
endif

set nocompatible
set runtimepath^=$PWD
filetype plugin indent on

syntax on
augroup swiftIndent
  autocmd!
  autocmd BufRead,BufNewFile *.swift setlocal shiftwidth=4 expandtab
augroup END

" Apply autoindent, save and quit.
function! s:RemoveWhitespaceAndReindent()
  silent %s/^\s\+//
  normal gg=G
  execute 'write ' . fnameescape($OUTPUT_FILE)
  quit!
endfunction
autocmd BufReadPost * call s:RemoveWhitespaceAndReindent()

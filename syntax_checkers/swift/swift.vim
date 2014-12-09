" File: syntax_checkers/swift/swift.vim
" Author: Keith Smiley
" Description: Syntastic checker for Swift
" Last Change: December 09, 2014
" Updated version of https://github.com/kballard/vim-swift

if exists("g:loaded_syntastic_swift_swift_checker")
  finish
endif
let g:loaded_syntastic_swift_swift_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_swift_swift_IsAvailable() dict
  return executable("swiftc") && executable("xcrun")
endfunction

function! SyntaxCheckers_swift_swift_GetLocList() dict
  let sdk = syntastic#util#shescape(system('xcrun --sdk iphonesimulator --show-sdk-path | xargs echo -n'))
  let makeprg = self.makeprgBuild({
        \ 'exe': self.getExec(),
        \ 'args_before': '-sdk ' . sdk})

  let errorformat =
        \ '%E%f:%l:%c: error: %m,' .
        \ '%W%f:%l:%c: warning: %m,' .
        \ '%Z%\s%#^~%#,' .
        \ '%-G%.%#'

  return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
      \ 'filetype': 'swift',
      \ 'name': 'swift',
      \ 'exec': 'swiftc'})

let &cpo = s:save_cpo
unlet s:save_cpo

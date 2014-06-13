" File: swift.vim
" Author: Keith Smiley
" Description: Runtime files for Swift
" Last Modified: June 13, 2014

if exists("b:current_syntax")
  finish
endif

" Shebang
syntax match swiftShebang /#!.*$/

" Comment contained keywords
syntax keyword swiftTodos contained TODO XXX FIXME NOTE
syntax keyword swiftMarker contained MARK

" Comments
syntax match swiftComment /\/\/.*$/
      \ contains=swiftTodos,swiftMarker
syntax region swiftComment start=/\/\*/ end=/\*\//
      \ contains=swiftTodos,swiftMarker

" Literals
syntax region swiftString start=/"/ skip=/\\"/ end=/"/


" Set highlights
highlight default link swiftTodos TODO
highlight default link swiftString String
highlight default link swiftShebang Comment
highlight default link swiftComment Comment
highlight default link swiftMarker Comment

let b:current_syntax = "swift"

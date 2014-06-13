" File: swift.vim
" Author: Keith Smiley
" Description: Runtime files for Swift
" Last Modified: June 13, 2014

if exists("b:current_syntax")
  finish
endif

" Comments
" Shebang
syntax match swiftShebang /#!.*$/

" Comment contained keywords
syntax keyword swiftTodos contained TODO XXX FIXME NOTE
syntax keyword swiftMarker contained MARK

" Comment patterns
syntax match swiftComment /\/\/.*$/
      \ contains=swiftTodos,swiftMarker
syntax region swiftComment start=/\/\*/ end=/\*\//
      \ contains=swiftTodos,swiftMarker


" Literals
" Strings
syntax region swiftString start=/"/ skip=/\\"/ end=/"/

" Numbers
syntax match swiftNumber /\<\d\+\>/
syntax match swiftNumber /\<\d\+\.\d\+\>/
syntax match swiftNumber /\<0x\x\+\>/
syntax match swiftNumber /\<0b[01]\+\>/
syntax match swiftNumber /\<0o\o\+\>/


" Operators
syntax match swiftOperator "\v\~"
syntax match swiftOperator "\v!"
syntax match swiftOperator "\v\%"
syntax match swiftOperator "\v\^"
syntax match swiftOperator "\v\&"
syntax match swiftOperator "\v[^/]\*[^/]"
syntax match swiftOperator "\v-"
syntax match swiftOperator "\v\+"
syntax match swiftOperator "\v\="
syntax match swiftOperator "\v\|"
syntax match swiftOperator "\v[^/]\/[^/]"
syntax match swiftOperator "\v\."
syntax match swiftOperator "\v\<"
syntax match swiftOperator "\v\>"



" Set highlights
highlight default link swiftTodos TODO
highlight default link swiftShebang Comment
highlight default link swiftComment Comment
highlight default link swiftMarker Comment

highlight default link swiftString String
highlight default link swiftNumber Number

highlight default link swiftOperator Operator


let b:current_syntax = "swift"

" File: swift.vim
" Author: Keith Smiley
" Description: Runtime files for Swift
" Last Modified: June 13, 2014

if exists("b:current_syntax")
  finish
endif

" Shebang
syntax match swiftShebang /#!.*$/

" Comments
syntax match swiftComment /\/\/.*$/
syntax region swiftComment start=/\/\*/ end=/\*\//

" Literals
syntax region swiftString start=/"/ skip=/\\"/ end=/"/


" Set highlights
highlight default link swiftString String
highlight default link swiftShebang Comment
highlight default link swiftComment Comment

let b:current_syntax = "swift"

" File: swift.vim
" Author: Keith Smiley
" Description: Runtime files for Swift
" Last Modified: June 15, 2014

if exists("b:current_syntax")
  finish
endif

" Comments
" Shebang
syntax match swiftShebang "\v#!.*$"

" Comment contained keywords
syntax keyword swiftTodos contained TODO XXX FIXME NOTE
syntax keyword swiftMarker contained MARK

" Comment patterns
syntax match swiftComment "\v\/\/.*$"
      \ contains=swiftTodos,swiftMarker,@Spell oneline
syntax region swiftComment start="\v^\s*\/\*" end="\v\*\/"
      \ contains=swiftTodos,swiftMarker,swiftComment,@Spell fold


" Literals
" Strings
syntax region swiftString start=/"/ skip=/\\"/ end=/"/ oneline contains=swiftInterpolatedWrapper
syntax region swiftInterpolatedWrapper start="\v\\\(\s*" end="\v\s*\)" contained containedin=swiftString contains=swiftInterpolatedString
syntax match swiftInterpolatedString "\v\w+(\(\))?" contained containedin=swiftInterpolatedWrapper

" Numbers
syntax match swiftNumber "\v<\d+>"
syntax match swiftNumber "\v<\d+\.\d+>"
syntax match swiftNumber "\v<\d*\.?\d+([Ee]-?)?\d+>"
syntax match swiftNumber "\v<0x\x+([Pp]-?)?\x+>"
syntax match swiftNumber "\v<0b[01]+>"
syntax match swiftNumber "\v<0o\o+>"

" BOOLs
syntax keyword swiftBoolean
      \ true
      \ false


" Operators
syntax match swiftOperator "\v\~"
syntax match swiftOperator "\v\s+!"
syntax match swiftOperator "\v\%"
syntax match swiftOperator "\v\^"
syntax match swiftOperator "\v\&"
syntax match swiftOperator "\v[^/"]\*[^/"]"
syntax match swiftOperator "\v-"
syntax match swiftOperator "\v\+"
syntax match swiftOperator "\v\="
syntax match swiftOperator "\v\|"
syntax match swiftOperator "\v[^/"]\/[^/"]"
syntax match swiftOperator "\v\."
syntax match swiftOperator "\v\<"
syntax match swiftOperator "\v\>"
syntax match swiftOperator "\v\?\?"


" Keywords {{{
syntax keyword swiftKeywords
      \ as
      \ break
      \ case
      \ class
      \ continue
      \ convenience
      \ default
      \ deinit
      \ didSet
      \ do
      \ dynamic
      \ else
      \ extension
      \ fallthrough
      \ final
      \ for
      \ func
      \ get
      \ if
      \ import
      \ in
      \ infix
      \ init
      \ inout
      \ internal
      \ is
      \ lazy
      \ let
      \ mutating
      \ nil
      \ operator
      \ optional
      \ override
      \ postfix
      \ prefix
      \ private
      \ protocol
      \ public
      \ required
      \ return
      \ self
      \ set
      \ static
      \ subscript
      \ super
      \ switch
      \ typealias
      \ unowned
      \ unowned(safe)
      \ unowned(unsafe)
      \ var
      \ weak
      \ where
      \ while
      \ willSet
" }}}

syntax keyword swiftAttributes
      \ @assignment
      \ @autoclosure
      \ @exported
      \ @IBAction
      \ @IBDesignable
      \ @IBInspectable
      \ @IBOutlet
      \ @noreturn
      \ @NSCopying
      \ @NSManaged
      \ @objc

syntax keyword swiftStructure
      \ struct
      \ enum

syntax region swiftTypeWrapper start="\v:\s*" end="\v[^\w]" contains=swiftString,swiftBoolean,swiftNumber,swiftType,swiftGenericsWrapper transparent oneline
syntax region swiftGenericsWrapper start="\v\<" end="\v\>" contains=swiftType transparent oneline
syntax region swiftLiteralWrapper start="\v\=\s*" skip="\v[^\[\]]\(\)" end="\v(\[\]|\(\))" contains=swiftType transparent oneline
syntax region swiftReturnWrapper start="\v-\>\s*" end="\v(\{|$)" contains=swiftType transparent oneline
syntax match swiftType "\v\u\w*" contained containedin=swiftGenericsWrapper,swiftTypeWrapper,swiftLiteralWrapper,swiftGenericsWrapper

syntax keyword swiftImports import


" 'preprocesor' stuff
syntax keyword swiftPreprocessor
      \ #if
      \ #elseif
      \ #else
      \ #endif


" Set highlights
highlight default link swiftTodos Todo
highlight default link swiftShebang Comment
highlight default link swiftComment Comment
highlight default link swiftMarker Comment

highlight default link swiftString String
highlight default link swiftInterpolatedWrapper Delimiter
highlight default link swiftNumber Number
highlight default link swiftBoolean Boolean

highlight default link swiftOperator Operator
highlight default link swiftKeywords Keyword
highlight default link swiftAttributes PreProc
highlight default link swiftStructure Structure
highlight default link swiftType Type
highlight default link swiftImports Include
highlight default link swiftPreprocessor PreProc


let b:current_syntax = "swift"

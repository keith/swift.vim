" File: swift.vim
" Author: Keith Smiley
" Description: The indent file for Swift
" Last Modified: June 13, 2014

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal indentexpr=SwiftIndent()
setlocal indentkeys+=0[,0]

function! s:NumberOfMatches(char, string)
  let regex = "[^" . a:char . "]"
  return strlen(substitute(a:string, regex, "", "g"))
endfunction

function! SwiftIndent()
  let line = getline(v:lnum)
  let previousNum = prevnonblank(v:lnum - 1)
  let previous = getline(previousNum)

  if previous =~ "{" && previous !~ "}" && line !~ "}" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if previous =~ "[" && previous !~ "]" && line !~ "]" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ "^\\s*],\\?$"
    return indent(previousNum) - &tabstop
  endif

  " Indent multi line declarations see #19
  " Allow statements to also be in parens
  let numOpenParens = s:NumberOfMatches("(", previous)
  let numCloseParens = s:NumberOfMatches(")", previous)
  if numOpenParens != 0 && (numOpenParens > numCloseParens)
    let previousParen = match(previous, "(")
    " Indent second line 1 space past above paren
    return previousParen + 1
    " Indent it one tabstop in
    " return indent(previousNum) + &tabstop
  endif

  if previous =~ ":$" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ ":$"
    if indent(v:lnum) > indent(previousNum)
      return indent(v:lnum) - &tabstop
    else
      return indent(v:lnum)
    endif
  endif

  " Correctly indent bracketed things when using =
  if line =~ "}"
    let newIndent = &tabstop
    if previous =~ "{"
      let newIndent = 0
    endif
    return indent(previousNum) - newIndent
  endif

  return indent(previousNum)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

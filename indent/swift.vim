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

function! SwiftIndent()
  let line = getline(v:lnum)
  let previousNum = prevnonblank(v:lnum - 1)
  let previous = getline(previousNum)

  if previous =~ "{" && line !~ "}" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if previous =~ ":$" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ ":$"
    return indent(v:lnum) - &tabstop
  endif

  return indent(previousNum)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

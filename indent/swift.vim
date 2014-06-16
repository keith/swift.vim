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

  if previous =~ "{" && previous !~ "}" && line !~ "}" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if previous =~ "[" && previous !~ "]" && line !~ "]" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if previous =~ ":$" && line !~ ":$"
    return indent(previousNum) + &tabstop
  endif

  if line =~ ":$"
    return indent(v:lnum) - &tabstop
  endif

  let thisColon = match(line, ":")
  if thisColon > 0
    let prevColon = match(previous, ":")
    if prevColon > 0
      let minInd = &tabstop + indent(v:lnum)
      let alignedInd = indent(previousNum) + prevColon - thisColon
      if alignedInd < 0
        return indent(previousNum) + &tabstop
      else
        return alignedInd
      endif
    endif
  endif

  return indent(previousNum)
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

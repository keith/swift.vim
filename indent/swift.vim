" File: swift.vim
" Author: Keith Smiley
" Description: The indent file for Swift
" Last Modified: December 05, 2014

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:cpo_save = &cpo
set cpo&vim

setlocal indentkeys+=0[,0]
setlocal indentexpr=SwiftIndent(v:lnum)

function! s:NumberOfMatches(char, string)
  let regex = "[^" . a:char . "]"
  return strlen(substitute(a:string, regex, "", "g"))
endfunction

function! s:SyntaxGroup()
  return synIDattr(synID(line("."), col("."), 0), "name")
endfunction

function! s:IsComment()
  return s:SyntaxGroup() ==# 'swiftComment'
endfunction

function! SwiftIndent(lnum)
  let line = getline(a:lnum)
  let previousNum = prevnonblank(a:lnum - 1)
  let previous = getline(previousNum)
  let cindent = cindent(a:lnum)
  let previousIndent = indent(previousNum)

  let numOpenParens = s:NumberOfMatches("(", previous)
  let numCloseParens = s:NumberOfMatches(")", previous)
  let numOpenBrackets = s:NumberOfMatches("{", previous)
  let numCloseBrackets = s:NumberOfMatches("}", previous)

  let currentOpenBrackets = s:NumberOfMatches("{", line)
  let currentCloseBrackets = s:NumberOfMatches("}", line)

  let numOpenSquare = s:NumberOfMatches("[", previous)
  let numCloseSquare = s:NumberOfMatches("]", previous)

  let currentCloseSquare = s:NumberOfMatches("]", line)
  if numOpenSquare > numCloseSquare

    echom "squares"
    return previousIndent + shiftwidth()
  endif

  if currentCloseSquare > 0
    echom "close square"
    let openingSquare = searchpair('\[', '', '\]', 'bWn')
    echom "openiung sqaure " . openingSquare

    return indent(openingSquare)
  endif

  if s:IsComment()
    return previousIndent
  endif

  if line =~ ":$"
    echom "31"
    let switch = search('switch', 'bWn')
    return indent(switch)
  elseif previous =~ ":$"
    echom "previous case"
    return previousIndent + shiftwidth()
  endif

  if numOpenParens == numCloseParens
    if numOpenBrackets > numCloseBrackets
      if currentCloseBrackets > currentOpenBrackets
      echom "1"
        normal! mi
        let openingBracket = searchpair("{", "", "}", "bWn")
        echom "openiung " . openingBracket
        normal! `i
        return indent(openingBracket)
      endif

      echom "15"
      return previousIndent + shiftwidth()
    elseif currentCloseBrackets > currentOpenBrackets
      echom "2"
      let openingBracket = searchpair("{", "", "}", "bWn")
      echom "openiung " . openingBracket

      return indent(openingBracket)
    elseif previous =~ "}.*{"
      echom "machines"
      return previousIndent + shiftwidth()
    else
      echom "3"
      return previousIndent
    endif
  endif

  if numCloseParens > 0
    if currentOpenBrackets > 0 || currentCloseBrackets > 0
      if currentOpenBrackets > 0
        if numOpenBrackets > numCloseBrackets
          echom "100"
          return previousIndent + shiftwidth()
        endif

        if line =~ "}.*{"
          echom "101"
          let openingBracket = searchpair("{", "", "}", "bWn")
          echom "openiung " . openingBracket

          return indent(openingBracket)
        endif

        if numCloseParens > numOpenParens
          echom "103"

          normal! mi
          normal! k
          let openingParen = searchpair("(", "", ")", "bWn")
          echom "openiung " . openingParen
          normal! `i
          return indent(openingParen)
        endif

        echom "102"
        return previousIndent
      endif

      if currentCloseBrackets > 0
        echom "104"
        let openingBracket = searchpair("{", "", "}", "bWn")
        echom "openiung " . openingBracket
        return indent(openingBracket)
      endif

      echom "brackets"
      return cindent
    endif

    if numCloseParens < numOpenParens
      if numOpenBrackets > numCloseBrackets
        echom "21"
        return previousIndent + shiftwidth()
      endif

      echom "20"
      let previousParen = match(previous, "(")
      return previousParen + 1
    endif

    echom "22"
    normal! mi
    execute "normal! " . previousNum . "G"
    let openingParen = searchpair("(", "", ")", "bWn")
    echom "openiung " . openingParen
    normal! `i

    return indent(openingParen)
  endif

  if numOpenParens > 0
    echom "had one opening before"
    let previousParen = match(previous, "(")
    return previousParen + 1
  endif

  echom "4"
  return cindent
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

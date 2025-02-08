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

setlocal nosmartindent
setlocal indentkeys-=e
setlocal indentkeys+=0]
setlocal indentexpr=SwiftIndent()

function! s:NumberOfMatches(char, string, index)
  let instances = 0
  let i = 0
  while i < strlen(a:string)
    if a:string[i] == a:char && !s:IsExcludedFromIndentAtPosition(a:index, i + 1)
      let instances += 1
    endif

    let i += 1
  endwhile

  return instances
endfunction

function! s:SyntaxNameAtPosition(line, column)
  return synIDattr(synID(a:line, a:column, 0), "name")
endfunction

function! s:SyntaxName()
  return s:SyntaxNameAtPosition(line("."), col("."))
endfunction

function! s:IsExcludedFromIndentAtPosition(line, column)
  let name = s:SyntaxNameAtPosition(a:line, a:column)
  return s:IsSyntaxNameExcludedFromIndent(name)
endfunction

function! s:IsExcludedFromIndent()
  return s:IsSyntaxNameExcludedFromIndent(s:SyntaxName())
endfunction

function! s:IsSyntaxNameExcludedFromIndent(name)
  return a:name ==# "swiftComment" || a:name ==# "swiftString" || a:name ==# "swiftInterpolatedWrapper" || a:name ==# "swiftMultilineInterpolatedWrapper" || a:name ==# "swiftMultilineString"
endfunction

" Description: Search for the position of the opening parenthesis '(' starting from the specified position.
" Parameters:
"   startingPosition - A list [line_number, column_number] representing the position to start the search.
" Returns: A list [line_number, column_number] representing the position of the opening parenthesis.
function! s:SearchOpeningParenPos(startingPosition)
  let currentLine = line(".")
  let currentColumn = col(".")
  call cursor(a:startingPosition[0], a:startingPosition[1])
  let openingParen = searchpairpos("(", "", ")", "bWn", "s:IsExcludedFromIndent()")
  call cursor(currentLine, currentColumn)
  return openingParen
endfunction

" Description: Moves the cursor to the start of a code block (parentheses or brackets) based on the given line number.
" Arguments:
"   a:lnum - (number) The line number to analyze and start searching from.
" Returns:
"   (number) The line number of the block's start position, or the input line number if no block structure is detected. 0 if no opening parenthesis or bracket found.
" Notes:
"   - The cursor position is updated during execution. Ensure that the caller saves and restores the cursor position if necessary."
function! s:CursorToBlockStart(lnum)
  let line = getline(a:lnum)
  let numOpenBrackets = s:NumberOfMatches("{", line, a:lnum)
  let numCloseBrackets = s:NumberOfMatches("}", line, a:lnum)
  let numOpenParens = s:NumberOfMatches("(", line, a:lnum)
  let numCloseParens = s:NumberOfMatches(")", line, a:lnum)

  if numCloseParens > numOpenParens || numCloseBrackets > numOpenBrackets
    " Return outer opening parenthesis or bracket line number.
    let lastCloseBracketCol = strridx(line, '}')
    let lastCloseParenCol = strridx(line, ')')
    if lastCloseParenCol > lastCloseBracketCol
      call cursor(a:lnum, lastCloseParenCol)
      let blockStartLnum = searchpair("(", "", ")", "bW", "s:IsExcludedFromIndent()")
      return blockStartLnum
    else
      call cursor(a:lnum, lastCloseBracketCol)
      let blockStartLnum = searchpair("{", "", "}", "bW", "s:IsExcludedFromIndent()")
      return blockStartLnum
    endif
  elseif line =~ '}.*{'
    " Return opening bracket line number.
    let lastCloseBracketCol = strridx(line, '}')
    call cursor(line("."), lastCloseBracketCol)
    let blockStartPosition = searchpair("{", "", "}", "bW", "s:IsExcludedFromIndent()")
    return blockStartLnum
  else
    " No block found. Return input line number.
    call cursor(a:lnum, "0")
    return a:lnum
  endif
endfunction

" Descriptions: Searches backward from a given line number to find a line or block that matches a specified pattern.
" Parameters:
"   lnum    - (number) The starting line number for the search.
"   pattern - (string) The pattern to search for in each line.
" Returns:
"   (number) The line number where the pattern is found, or 0 if no match is found.
function! s:SearchBackwardLineOrBlock(lnum, pattern)
  let currentPos = getpos(".")

  let lnum = a:lnum
  while lnum > 0
    let lnum = s:CursorToBlockStart(lnum)
    if !lnum
      break
    endif
    let line = getline(lnum)
    if line =~ a:pattern
      " Return matched line number
      break
    else
      " Continue from previous line
      let lnum = prevnonblank(lnum - 1)
      if !lnum
        break
      endif
      while lnum > 0 && s:IsCommentLine(lnum) != 0
        let lnum = prevnonblank(lnum - 1)
      endwhile
      if !lnum
        break
      endif
    endif
  endwhile

  call cursor(".", currentPos)
  return lnum
endfunction

" Description: Determines the indentation level for a line that start with a dot.
" Parameters:
"   line              - (string) The content of the current line.
"   previous          - (string) The content of the previous line.
"   previousNum       - (number) The line number of the previous line.
"   previousIndent    - (number) The indentation level of the previous line.
"   numCloseBrackets  - (number) The count of closing brackets ('}') on the previous line.
"   numOpenBrackets   - (number) The count of opening brackets ('{') on the previous line.
"   numCloseParens    - (number) The count of closing parentheses (')') on the previous line.
"   numOpenParens     - (number) The count of opening parentheses ('(') on the previous line.
"   clnum             - (number) The current line number being analyzed.
" Returns:
"   (number) The calculated indentation level for the current line. 0 if no condition is satisfied.
function! DotIndent(line, previous, previousNum, previousIndent, numCloseBrackets, numOpenBrackets, numCloseParens, numOpenParens, clnum)
  if a:line =~ '^\s*\.[^.]\+'
    " Line starting with dot
    if s:IsMatchingLineOrBlock(a:previousNum, '^\s*\.')
      " Previous line is the dot line or the dot block
      return a:previousIndent
    elseif a:numCloseBrackets > a:numOpenBrackets || a:numCloseParens > a:numOpenParens
      " Previous line closes the block
      return a:previousIndent
    else
      return a:previousIndent + shiftwidth()
    endif
  elseif s:IsMatchingLineOrBlock(a:previousNum, '^\s*\.')
    " Previous line is the dot line or the dot block
    if a:previous =~ '^\s*\.' && s:IsCommentLine(a:clnum)
      " Comment line just after the dot line
      return a:previousIndent - shiftwidth()
    else
      let nearestNonDotLnum = s:SearchBackwardLineOrBlock(a:previousNum, '^\s*[^ \t.]')
      return indent(nearestNonDotLnum)
    endif
  else
    return -1
  endif
endfunction

" Descriptions: Checks whether the line or block incluing the given line number matches a specified pattern.
" Paramters:
"   lnum    - (number) The line number to analyze and check for a match.
"   pattern - (string) The pattern to evaluate against the line or block.
" Returns:
"   (number) 1 if the line matches the pattern, 0 otherwise.
function! s:IsMatchingLineOrBlock(lnum, pattern)
  let currentPos = getpos(".")
  call s:CursorToBlockStart(a:lnum)
  let line = getline(".")
  let matched = line =~ a:pattern
  call cursor(".", currentPos)
  return matched
endfunction

function! s:IsCommentLine(lnum)
    return synIDattr(synID(a:lnum,
          \     match(getline(a:lnum), "\\S") + 1, 0), "name")
          \ ==# "swiftComment"
endfunction

function! SwiftIndent(...)
  let clnum = a:0 ? a:1 : v:lnum

  let line = getline(clnum)
  let previousNum = prevnonblank(clnum - 1)
  while s:IsCommentLine(previousNum) != 0
    let previousNum = prevnonblank(previousNum - 1)
  endwhile

  let previous = getline(previousNum)
  let cindent = cindent(clnum)
  let previousIndent = indent(previousNum)

  let numOpenParens = s:NumberOfMatches("(", previous, previousNum)
  let numCloseParens = s:NumberOfMatches(")", previous, previousNum)
  let numOpenBrackets = s:NumberOfMatches("{", previous, previousNum)
  let numCloseBrackets = s:NumberOfMatches("}", previous, previousNum)

  let currentOpenBrackets = s:NumberOfMatches("{", line, clnum)
  let currentCloseBrackets = s:NumberOfMatches("}", line, clnum)

  let numOpenSquare = s:NumberOfMatches("[", previous, previousNum)
  let numCloseSquare = s:NumberOfMatches("]", previous, previousNum)

  let currentCloseSquare = s:NumberOfMatches("]", line, clnum)
  if numOpenSquare > numCloseSquare && currentCloseSquare < 1
    return previousIndent + shiftwidth()
  endif

  if currentCloseSquare > 0 && line !~ '\v\[.*\]'
    let column = col(".")
    call cursor(line("."), 1)
    let openingSquare = searchpair("\\[", "", "\\]", "bWn", "s:IsExcludedFromIndent()")
    call cursor(line("."), column)

    if openingSquare == 0
      return -1
    endif

    " - Line starts with closing square, indent as opening square
    if line =~ '\v^\s*]'
      return indent(openingSquare)
    endif

    " - Line contains closing square and more, indent a level above opening
    return indent(openingSquare) + shiftwidth()
  endif

  if line =~ ":$" && (line =~ '^\s*case\W' || line =~ '^\s*default\W')
    let switch = search("switch", "bWn")
    return indent(switch)
  elseif previous =~ ":$" && (previous =~ '^\s*case\W' || previous =~ '^\s*default\W')
    return previousIndent + shiftwidth()
  endif

  if numOpenParens == numCloseParens
    if numOpenBrackets > numCloseBrackets
      if currentCloseBrackets > currentOpenBrackets || line =~ "\\v^\\s*}"
        let column = col(".")
        call cursor(line("."), 1)
        let openingBracket = searchpair("{", "", "}", "bWn", "s:IsExcludedFromIndent()")
        call cursor(line("."), column)
        if openingBracket == 0
          return -1
        else
          return indent(openingBracket)
        endif
      endif

      return previousIndent + shiftwidth()
    elseif previous =~ "}.*{"
      if line =~ "\\v^\\s*}"
        return previousIndent
      endif

      return previousIndent + shiftwidth()
    elseif line =~ "}.*{"
      let openingBracket = searchpair("{", "", "}", "bWn", "s:IsExcludedFromIndent()")

      let bracketLine = getline(openingBracket)
      let numOpenParensBracketLine = s:NumberOfMatches("(", bracketLine, openingBracket)
      let numCloseParensBracketLine = s:NumberOfMatches(")", bracketLine, openingBracket)
      if numOpenParensBracketLine > numCloseParensBracketLine
        let line = line(".")
        let column = col(".")
        call cursor(openingParen, column)
        let openingParenCol = searchpairpos("(", "", ")", "bWn", "s:IsExcludedFromIndent()")[1]
        call cursor(line, column)
        return openingParenCol
      endif
      if numOpenParensBracketLine == 0 && numCloseParensBracketLine == 0
        return indent(openingBracket) + shiftwidth()
      endif

      return indent(openingBracket)
    elseif currentCloseBrackets > currentOpenBrackets
      let column = col(".")
      let line = line(".")
      call cursor(line, 1)
      let openingBracket = searchpair("{", "", "}", "bWn", "s:IsExcludedFromIndent()")
      call cursor(line, column)

      let bracketLine = getline(openingBracket)

      let numOpenParensBracketLine = s:NumberOfMatches("(", bracketLine, openingBracket)
      let numCloseParensBracketLine = s:NumberOfMatches(")", bracketLine, openingBracket)
      if numCloseParensBracketLine > numOpenParensBracketLine
        let openingParenPos = s:SearchOpeningParenPos([openingBracket, 1])
        return indent(openingParenPos[0])
      elseif numOpenParensBracketLine > numCloseParensBracketLine
        let openingParenPos = s:SearchOpeningParenPos([line("."), col(".")])
        return openingParenPos[1]
      endif

      return indent(openingBracket)
    elseif line =~ '^\s*)$'
      let line = line(".")
      let column = col(".")
      call cursor(line, 1)
      let openingParen = searchpair("(", "", ")", "bWn", "s:IsExcludedFromIndent()")
      call cursor(line, column)
      return indent(openingParen)
    else
      let dotIndent = DotIndent(line, previous, previousNum, previousIndent, numCloseBrackets, numOpenBrackets, numCloseParens, numOpenParens, clnum)
      if dotIndent != -1
        return dotIndent
      endif

      " - Current line is blank, and the user presses 'o'
      return previousIndent
    endif
  endif

  if numCloseParens > 0
    if currentOpenBrackets > 0 || currentCloseBrackets > 0
      if currentOpenBrackets > 0
        if numOpenBrackets > numCloseBrackets
          return previousIndent + shiftwidth()
        endif

        if line =~ "}.*{"
          let openingBracket = searchpair("{", "", "}", "bWn", "s:IsExcludedFromIndent()")
          return indent(openingBracket)
        endif

        if numCloseParens > numOpenParens
          let line = line(".")
          let column = col(".")
          call cursor(line - 1, column)
          let openingParen = searchpair("(", "", ")", "bWn", "s:IsExcludedFromIndent()")
          call cursor(line, column)
          return indent(openingParen)
        endif

        return previousIndent
      endif

      if currentCloseBrackets > 0
        let openingBracket = searchpair("{", "", "}", "bWn", "s:IsExcludedFromIndent()")
        return indent(openingBracket)
      endif

      return cindent
    endif

    if numCloseParens < numOpenParens
      if numOpenBrackets > numCloseBrackets
        return previousIndent + shiftwidth()
      endif

      let previousParen = match(previous, '\v\($')
      if previousParen != -1
        return previousIndent + shiftwidth()
      endif

      let line = line(".")
      let column = col(".")
      call cursor(previousNum, col([previousNum, "$"]))
      let previousParen = searchpairpos("(", "", ")", "cbWn", "s:IsExcludedFromIndent()")
      call cursor(line, column)

      " Match the last non escaped paren on the previous line
      return previousParen[1]
    endif

    if numOpenBrackets > numCloseBrackets
      let line = line(".")
      let column = col(".")
      call cursor(previousNum, column)
      let openingParen = searchpair("(", "", ")", "bWn", "s:IsExcludedFromIndent()")
      call cursor(line, column)
      return openingParen + 1
    endif

    " - Previous line has close then open braces, indent previous + 1 'sw'
    if previous =~ "}.*{"
      return previousIndent + shiftwidth()
    endif

    let dotIndent = DotIndent(line, previous, previousNum, previousIndent, numCloseBrackets, numOpenBrackets, numCloseParens, numOpenParens, clnum)
    if dotIndent != -1
      return dotIndent
    endif

    let line = line(".")
    let column = col(".")
    call cursor(previousNum, column)
    let openingParen = searchpair("(", "", ")", "bWn", "s:IsExcludedFromIndent()")
    call cursor(line, column)

    return indent(openingParen)
  endif

  " - Line above has (unmatched) open paren, next line needs indent
  if numOpenParens > 0
    let savePosition = getcurpos()
    let lastColumnOfPreviousLine = col([previousNum, "$"]) - 1
    " Must be at EOL because open paren has to be above (left of) the cursor
    call cursor(previousNum, lastColumnOfPreviousLine)
    let previousParen = searchpairpos("(", "", ")", "cbWn", "s:IsExcludedFromIndent()")[1]
    " If the paren on the last line is the last character, indent the contents
    " at shiftwidth + previous indent
    if previousParen == lastColumnOfPreviousLine
      return previousIndent + shiftwidth()
    endif

    " The previous line opens a closure and doesn't close it
    if numOpenBrackets > numCloseBrackets
      return previousParen + shiftwidth()
    endif

    call setpos(".", savePosition)
    return previousParen
  endif

  return cindent
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

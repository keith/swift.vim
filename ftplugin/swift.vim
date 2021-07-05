setlocal commentstring=//\ %s
" @-@ adds the literal @ to iskeyword for @IBAction and similar
setlocal iskeyword+=@-@,#
setlocal completefunc=syntaxcomplete#Complete
setlocal comments=s1:/*,mb:*,ex:*/,:///,://

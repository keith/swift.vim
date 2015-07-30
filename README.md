# Swift.vim

Syntax and indent files for [Swift](https://developer.apple.com/swift/)

## Installation

If you don't have a preferred installation method check out
[vim-plug](https://github.com/junegunn/vim-plug). If you just want to install and go, there's a manual method below.

#### Linux and Mac OS X: manual method

Create the folder `~/.vim` if it does not exist. That's `mkdir ~/.vim` in the Terminal. Then download the contents of the repository—there's a `Download ZIP` button over there on the right—and un-zip the contents of that file to `~/.vim`. You should end up with this folder structure in `~/.vim`:

````
.:
example  ftdetect  ftplugin  indent  LICENSE  .netrwhist  README.md  screenshots  syntax  syntax_checkers

./example:
example.swift  MainViewController.swift  URL.swift

///// .......

./syntax:
swift.vim

./syntax_checkers:
swift

./syntax_checkers/swift:
swift.vim
````
Then restart Vim!

## Examples

![](https://raw.githubusercontent.com/keith/swift.vim/master/screenshots/screen.png)
![](https://raw.githubusercontent.com/keith/swift.vim/master/screenshots/screen2.png)


### Development

I plan to continue improving this plugin as I find more issues with
it. If you find anything strange with highlighting or indention *please*
[submit an issue](https://github.com/keith/swift.vim/issues/new).

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

## [Syntastic](https://github.com/scrooloose/syntastic/) Integration

swift.vim can show errors inline from
[swift package manager](https://github.com/apple/swift-package-manager/)
or from [swiftlint](https://github.com/realm/SwiftLint) using
[syntastic](https://github.com/scrooloose/syntastic/).

![](https://raw.githubusercontent.com/keith/swift.vim/master/screenshots/screen3.png)

### Usage

- Install [syntastic](https://github.com/scrooloose/syntastic/)

- swiftpm integration will be automatically enabled if you're running vim
from a directory containing a `Package.swift` file.

- SwiftLint integration will be automatically enabled if you have
SwiftLint installed and if you're running vim from a directory
containing a `.swiftlint.yml` file.

- To enable both at once add this to your vimrc:

```vim
let g:syntastic_swift_checkers = ['swiftpm', 'swiftlint']
```

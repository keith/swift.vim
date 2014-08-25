#!/Applications/Xcode6-Beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -i

// This is a comment

let foo = 5 // another comment

/* this is also a comment */

    /* this is an indented comment */

    /* this is a multi level indented comment /* you know */ */

// comments check splelling

/* this is
a multi-line
/* you know */

/** foo
bar
*/

comment
*/

/// foo bar


"this is a string no splell checking"
"this is a string\" with an escaped quote"

// TODO: This is a todo comment
// XXX: This is another todo comment
// FIXME: this is another todo comment
// NOTE: this is another todo comment
/* TODO multiple */

// MARK: this is a marker

    // this is a indented comment

5 // int

5.5 // float
5e-2
5E2
5.5E-2
5.5e2
5.5f2
5.5abc5.5 // broken

0xa2ef // hex
0x123P432
0x13p-43
0x13r-43
0x213zdf // broken hex

0b10101 // binary
0b1234 // broken binary

0o567 // octal
0o5689 // broken octal

// Operators
~
!
%
^
&
2 * 2
-
+
=
|
2 / 5
.
>
<

a != b
a != b
a !== b
a !== b
%=
&%
&&
&&=
let a = 10 &* 20
&+
&-
8 &/ 20
&=
let a *= 20
++
+=
--
-=
..
...
let b = 50 /= 20
<<
<=
=<<
==
===
>=
>>
>>=
^=
|=
||
||=
~=

true
false

class Shape : NSObject {
    var foo: String
    var qux: String = "abcd"
    let bar = String?[]()
    let baz = String()?
    let foo = Int()

    init(thing: String) {
        foo = thing
        super.init(thing)
        let bar:String= "123"

        bar!
    }

    func foo(thing1 : String, 2thing : Int52) {

    }

    func bar(thing: String?){

    }
}

import Cocoa

struct Thing: NSString {
    var foo : Int
}

enum Card : Int {
    case Spade = 1
    case Heart
    case Diamond
    case Club
}

struct foo : bar {
    switch (foo) {
    case foo:
      foo
    case bar:
    default:
        stuff
    case baz:
        fuck
    case bar:
        bafsd
    }

    func foo() {

    }

    func bar(asdf: String) -> Bool {

    }

    func baz() -> (Foo, Bar)
    {

    }

    func asdf<T>() {

    }
}

struct ArgumentList {
    var arguments: String[]

    init(argv: UnsafePointer<CString>, count: CInt) {
    }
}

let a : UnsafePointer<CString>

func foo<T: Sequence>() {

}

init(argv: UnsafePointer<CString>, count: CInt) {
    for i in 1..count {
        let index = Int(i)
        let arg = String.fromCString(argv[index])
        arguments.append(arg)
    }
}

func simpleDescription() -> String {
    return "A shape with \(numberOfSides.toRaw()) sides."
}

let library = [
    Movie(name: "foo bar",
          dfasdfsdfdirector: "someone",
          foo: "bar",
          bazzzer: "qux")
]


foo as? String
let foo : Int = bar ?? 5

let arg: String = "123"
hello<String>(arg, arg2: 1.0, arg3: arg, arg4: "foo", arg5: false)


class MainViewController: UIViewController, UITableViewDataSource {}

@IBAction func changePostFilter(sender: UISegmentedControl) {}
override func prepareForSegue(segue: UIStoryboardSegue,
                              sender: AnyObject) {}
override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {}
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {}
lazy var foo : String

#if foo
    bar
#elseif baz
    qux
#else
    quix
#endif

client.host = "example.com"
client.pathPrefix = "/foo/"

func foo () {
  override func loadView() {
    super.loadView()
    if foo {
      foobar
    }
  }
}

let foo = CGRectMake(0, (5 - 2),
                     100,
                     200)


let dict = [
  "foo": "Bar",
  "nest": [
    "fadsf",
  ],
]

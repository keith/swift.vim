import SwiftUI
import PlaygroundSupport

struct ExampleView: View {
    @State var isShowingSheet = false

    var body: some View {
        VStack {
            Text("Hello, World!")
            // comment
                .font(.caption)
                .monospaced()
            // red font
                .foregroundStyle(.red)
            Button(action: { print("clicked") }) {
                Text("click me")
            }
            .buttonStyle(.bordered)

            Button(action: { isShowingSheet = true }) {
                Text("show sheet")
            }
            Text("sample")
                .overlay {
                    Circle()
                        .fill(.gray.opacity(0.25))
                }
                .lineLimit(2)
            Text("sample2")
            HStack {
                ForEach(0...5, id: \.self) { n in
                    if n % 2 == 0 {
                        Text(n.description)
                            .foregroundStyle(.green)
                    }
                    else {
                        Text(n.description)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 200, height: 400)
        .sheet(isPresented: $isShowingSheet) {
            Text("sheet")
        }
    }
}

struct ViewModifierPatternView: View {
    var body: some View {
        // indented modifiers
        VStack {
            //  second view is aligned with first view
            Text("foo")
                .font(.caption)
            Text("bar")

            Text("foo")
                .font(.caption)
            Button("bar") {
                print("bar")
            }

            Text("foo")
                .font(.caption)
            Button(action: { print("bar") }) {
                Text("bar")
            }

            Text("foo")
                .font(
                    .caption
                )
            Text("bar")

            Text("foo")
                .font(
                    .caption
                )
                .padding()
            Text("bar")
        }

        // non-indented modifiers
        VStack {
        }
        .padding()
        Text("bar")

        VStack {
        }
        .padding()
        Button("bar") {
            print("bar")
        }

        VStack {
        }
        .padding()
        Button(action: { print("bar") }) {
            Text("bar")
        }

        VStack {
        }
        .padding(
            .all
        )
        Text("bar")

        Text("foo")
            .font(
                .caption
            )
            .padding()
        Text("bar")
    }
}

PlaygroundPage.current.setLiveView(VStack {
                                       ViewModifierPatternView()
                                       ExampleView()
                                   })

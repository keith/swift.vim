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

PlaygroundPage.current.setLiveView(ExampleView())

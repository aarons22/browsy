import SwiftUI
import shared

struct ContentView: View {
    var body: some View {
        VStack {
            Text(Greeting().greet())
                .font(.title)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}

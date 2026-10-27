import SwiftUI

struct WatchContentView: View {
    @State private var currentQuote = WatchQuoteManager.randomQuote()
    @State private var showQuote = true

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("✨")
                    .font(.title2)

                Text(currentQuote.text)
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .opacity(showQuote ? 1 : 0)

                Text("— \(currentQuote.author)")
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.gray)
                    .opacity(showQuote ? 1 : 0)

                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        showQuote = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        currentQuote = WatchQuoteManager.randomQuote()
                        withAnimation(.easeIn(duration: 0.3)) {
                            showQuote = true
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("Next")
                            .font(.caption)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    WatchContentView()
}

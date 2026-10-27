import SwiftUI

struct ContentView: View {
    @State private var currentQuote = QuoteManager.randomQuote()
    @State private var animateQuote = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.05, blue: 0.3),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("✨ Daily Motivation")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 20) {
                    Text("\"")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.yellow.opacity(0.6))
                        .frame(height: 40)

                    Text(currentQuote.text)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(animateQuote ? 1 : 0)
                        .offset(y: animateQuote ? 0 : 20)

                    Text("— \(currentQuote.author)")
                        .font(.system(size: 16, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(animateQuote ? 1 : 0)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)

                Spacer()

                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        animateQuote = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        currentQuote = QuoteManager.randomQuote()
                        withAnimation(.easeIn(duration: 0.5)) {
                            animateQuote = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("New Quote")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                }

                Text("Made with ❤️ for my first Apple app")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 20)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                animateQuote = true
            }
        }
    }
}

#Preview {
    ContentView()
}

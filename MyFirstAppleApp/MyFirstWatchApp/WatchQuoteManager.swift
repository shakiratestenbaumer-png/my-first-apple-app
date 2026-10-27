import Foundation

struct WatchQuote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

struct WatchQuoteManager {
    static let quotes: [WatchQuote] = [
        WatchQuote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
        WatchQuote(text: "Believe you can and you're halfway there.", author: "T. Roosevelt"),
        WatchQuote(text: "The best time is now.", author: "Chinese Proverb"),
        WatchQuote(text: "What we think, we become.", author: "Buddha"),
        WatchQuote(text: "Be yourself; everyone else is taken.", author: "Oscar Wilde"),
        WatchQuote(text: "Do or do not. There is no try.", author: "Yoda"),
        WatchQuote(text: "In difficulty lies opportunity.", author: "Einstein"),
        WatchQuote(text: "Courage is not the absence of fear.", author: "Mandela"),
        WatchQuote(text: "The journey of 1000 miles begins with one step.", author: "Lao Tzu"),
        WatchQuote(text: "Innovation distinguishes leaders.", author: "Steve Jobs"),
    ]

    static func randomQuote() -> WatchQuote {
        quotes.randomElement() ?? quotes[0]
    }
}

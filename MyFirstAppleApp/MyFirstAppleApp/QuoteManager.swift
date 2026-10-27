import Foundation

struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

struct QuoteManager {
    static let quotes: [Quote] = [
        Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        Quote(text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs"),
        Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
        Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
        Quote(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb"),
        Quote(text: "Your time is limited, don't waste it living someone else's life.", author: "Steve Jobs"),
        Quote(text: "The only impossible journey is the one you never begin.", author: "Tony Robbins"),
        Quote(text: "Success is not final, failure is not fatal: it is the courage to continue that counts.", author: "Winston Churchill"),
        Quote(text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein"),
        Quote(text: "What we think, we become.", author: "Buddha"),
        Quote(text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde"),
        Quote(text: "Life is what happens when you're busy making other plans.", author: "John Lennon"),
        Quote(text: "The mind is everything. What you think you become.", author: "Buddha"),
    ]

    static func randomQuote() -> Quote {
        quotes.randomElement() ?? quotes[0]
    }
}

import UIKit

struct DemoMediaItem: Hashable {
    let id: String
    let title: String
    let meta: String
    let symbolName: String
    let tint: UIColor
}

enum DemoGridStyle {
    case portraitVideo
    case noteCard
    case photoSquare
}

enum DemoMediaPalette {
    static let tints: [UIColor] = [
        .systemPink, .systemOrange, .systemTeal, .systemIndigo,
        .systemPurple, .systemBlue, .systemMint, .systemRed,
        .systemCyan, .systemYellow,
    ]

    static func items(count: Int, title: String, symbol: String, meta: (Int) -> String) -> [DemoMediaItem] {
        (1...count).map { index in
            DemoMediaItem(
                id: "\(title)-\(index)",
                title: "\(title) \(index)",
                meta: meta(index),
                symbolName: symbol,
                tint: tints[(index - 1) % tints.count]
            )
        }
    }
}

struct DemoTweetItem: Hashable {
    let id: String
    let body: String
    let time: String
    let replies: String
    let reposts: String
    let likes: String
}

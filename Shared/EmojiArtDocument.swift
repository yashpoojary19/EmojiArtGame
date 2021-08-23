//
//  EmojiArtDocument.swift
//  EmojiArtGame
//
//  Created by Yash Poojary on 22/08/21.
//


import SwiftUI

class EmojiArtDocument: ObservableObject {

    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgrounImageDataIfNecessary()
            }
        }
    }

    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji(text: "🚎", at: (-200, -100), size: 100)
        emojiArt.addEmoji(text: "🚋", at: (50, 100), size: 50)
    }

    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }


    @Published var backgroundImage: UIImage?
    
    private func fetchBackgrounImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                backgroundImage = UIImage(data: imageData!)
            }
            
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
         
    }
    
    
    // MARK: - Intent(s)

    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("background set to \(background)")
    }

    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(text: emoji, at: location, size: Int(size))
    }

    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }

    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }

}

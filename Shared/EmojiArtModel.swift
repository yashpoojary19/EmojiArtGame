

import Foundation

struct EmojiArtModel {
    
    var background = Background.blank
    var emojis = [Emoji]()
    
    
    struct Emoji: Identifiable, Hashable {
        var text: String
        var x: Int
        var y: Int
        var size: Int
        var id: Int
        
        fileprivate init(text: String, x: Int, y: Int,  size: Int, id: Int  ) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
        
    }
    
    init() {
        
    }
    
    
    var uniqueEmojiId = 0
    
    mutating func addEmoji(text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
}

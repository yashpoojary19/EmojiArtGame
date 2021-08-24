//
//  EmojiArtGameApp.swift
//  Shared
//
//  Created by Yash Poojary on 22/08/21.
//

import SwiftUI

@main
struct EmojiArtGameApp: App {
    var body: some Scene {
        let document = EmojiArtDocument()
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}

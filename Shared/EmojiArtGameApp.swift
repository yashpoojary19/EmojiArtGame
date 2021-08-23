//
//  EmojiArtGameApp.swift
//  Shared
//
//  Created by Yash Poojary on 22/08/21.
//

import SwiftUI

@main
struct EmojiArtGameApp: App {
    let document = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}

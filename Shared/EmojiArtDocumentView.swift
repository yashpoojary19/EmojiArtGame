

import SwiftUI


struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    let defaultFontSize: CGFloat = 40
    

    var body: some View {
        VStack(spacing: 0) {
            documentBody
            pallete
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
        ZStack {
            Color.white.overlay (
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(convertFromEmojiCoordinates((0,0), in: geometry))
            
            )
            .gesture(doubleTapToZoom(in: geometry.size))
            if document.fetchBackgroundImageStatus == .fetching {
                ProgressView().scaleEffect(2)
            } else {
            ForEach(document.emojis) { emoji in Text(emoji.text)
                .font(.system(size: fontSize(for: emoji)))
                .scaleEffect(zoomScale)
                .position(position(for: emoji, in: geometry))
                }
            }
        }
        .clipped()
        .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
            return drop(providers: providers, at: location, in: geometry)
            }
        .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL))
            
        }
        
        if !found {
         found = providers.loadObjects(ofType: UIImage.self) { image in
            if let data = image.jpegData(compressionQuality: 1.0) {
                document.setBackground(.imageData(data))
                }
             
            }
        }
        
        if !found {
        
        found = providers.loadObjects(ofType: String.self) { string in
            if let emoji = string.first, emoji.isEmoji {
            document.addEmoji(
                            String(emoji),
                            at: convertToEmojiCoordinates(location, in: geometry),
                            size: defaultFontSize / zoomScale
                    )
                }
            }
        }
        
        return found
    }
    
        private func convertToEmojiCoordinates (_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
            let center = geometry.frame(in: .local).center
            let location = CGPoint(
                x: (location.x - panOffset.width - center.x) / zoomScale,
                y: (location.x - panOffset.height - center.y) / zoomScale
            )

            return (Int(location.x), Int(location.y))
        }
        
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded{
                withAnimation {
                    zoomToFits(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale,  gestureZoomScale    , transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    // gestureScaleAtEnd how far apart are the fingers
    
    
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat  {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.x + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize =  CGSize.zero
    
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue,  gesturePanOffset, transaction in
                gesturePanOffset  = latestDragGestureValue.translation / zoomScale
            }
            
            .onEnded {
                finalDragValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragValue.translation / zoomScale)
            }
    }
    
    
    private func zoomToFits(_ image: UIImage?, in size: CGSize ) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let VZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(VZoom, hZoom)
        }
    }

    
    var pallete: some View {
        ScrollingEmojiView(emojis: testEmojis)
            .font(.system(size: defaultFontSize))
    }
    
    let testEmojis = "😧🥱😬😑😧🤧"
    
}

struct ScrollingEmojiView: View {
    
    let emojis: String
    
   
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack{
                ForEach(emojis.map { String($0)}, id: \.self) { emoji in Text(emoji)
                    .onDrag { NSItemProvider(object: emoji as NSString) }
                   
                    
                }
                   
            }
        }
    }
}



struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
            EmojiArtDocumentView(document: EmojiArtDocument())
    }
}

import SwiftUI


struct ContentView: View {
    @State private var text: String = ""
    @State private var image: NSImage?
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
//                .border(Color.gray, width: 1)
            
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            
            ImagePicker(image: $image)
            
            Spacer()
        }
        .padding()
    }
}


struct ImagePicker: NSViewRepresentable {
    @Binding var image: NSImage?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: "Select Image", target: context.coordinator, action: #selector(Coordinator.openPanel))
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {}
    
    class Coordinator: NSObject {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        @objc func openPanel() {
            let panel = NSOpenPanel()
            panel.allowedFileTypes = ["png", "jpg", "jpeg"]
            panel.begin { response in
                if response == .OK, let url = panel.url, let image = NSImage(contentsOf: url) {
                    self.parent.image = image
                }
            }
        }
    }
}




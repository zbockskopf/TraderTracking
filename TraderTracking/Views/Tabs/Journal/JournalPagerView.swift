import SwiftUI
import RealmSwift
import MarkdownView

// Image Cache Class
class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}

// Generic JournalPagerView for handling any of the three journal types
struct JournalPagerView<T: Object & ObjectKeyIdentifiable>: View {
    @ObservedResults(T.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var journalEntries
    
    @State private var currentPage: Int = 1
    private let pageSize: Int = 10
    @State private var isLoadingMore: Bool = false
    @State private var loadedEntries: [T] = []

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(loadedEntries) { entry in
                        Divider()
                        LazyVStack(alignment: .leading, spacing: 0) {
                            MarkdownView(text: (entry as? HasContent)?.content ?? "")
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(10)

                            if let thumbnailImages = (entry as? HasImages)?.thumbnailImages,
                               let imageLocalUrl = (entry as? HasImages)?.imageLocalUrl,
                               !thumbnailImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 10) {
                                        ForEach(thumbnailImages, id: \.self) { thumbnailData in
                                            LazyLoadingThumbnailView(thumbnailData: thumbnailData, imageLocalUrl: imageLocalUrl)
                                        }
                                    }
                                    .padding(10)
                                }
                            }

                        }
                        .onAppear {
                            // Load more when the last item appears, and not already loading
                            if entry == loadedEntries.last && !isLoadingMore {
                                loadMoreEntries()
                            }
                        }
                    }

                    if isLoadingMore {
                        ProgressView()
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .toolbar(.hidden)
            .scrollIndicators(.hidden) // Hide scroll indicators for a cleaner look
            .onAppear {
                if loadedEntries.isEmpty {
                    loadMoreEntries()
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width)

    }

    // Load more journal entries by incrementing the current page
    private func loadMoreEntries() {
        guard !isLoadingMore else { return }
        
        let start = (currentPage - 1) * pageSize
        let end = min(start + pageSize, journalEntries.count)
        
        guard start < journalEntries.count else { return }  // Prevent loading more if no more entries exist

        isLoadingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newEntries = Array(journalEntries[start..<end])
            loadedEntries.append(contentsOf: newEntries)
            currentPage += 1
            isLoadingMore = false
        }
    }
}



struct LazyLoadingThumbnailView: View {
    let thumbnailData: Data
    let imageLocalUrl: String // URL for the full-resolution image
    @State private var thumbnailImage: UIImage?
    @State private var fullResolutionImage: UIImage?
    @State private var isFullResolutionLoaded: Bool = false

    var body: some View {
        ZStack {
            if let image = isFullResolutionLoaded ? fullResolutionImage : thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 400, maxHeight: 300)
                    .cornerRadius(10)
                    .clipped()
                    .pinchZoom(onZoomThresholdReached: loadFullResolutionImage) // Always load the full-resolution image
            } else {
                // Placeholder while loading
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: 400, maxHeight: 300)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }

    // Load thumbnail when the view appears
    private func loadThumbnail() {
        let cacheKey = "\(thumbnailData.hashValue)"
        
        if let cachedThumbnail = ImageCache.shared.getImage(forKey: cacheKey) {
            self.thumbnailImage = cachedThumbnail
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let uiImage = UIImage(data: self.thumbnailData) {
                    DispatchQueue.main.async {
                        self.thumbnailImage = uiImage
                        ImageCache.shared.setImage(uiImage, forKey: cacheKey)
                    }
                }
            }
        }
    }

    // Load full-resolution image when pinch-to-zoom starts
    private func loadFullResolutionImage() {
        guard !isFullResolutionLoaded else { return }
        
        if let cachedFullResolution = ImageCache.shared.getImage(forKey: imageLocalUrl) {
            self.fullResolutionImage = cachedFullResolution
            self.isFullResolutionLoaded = true
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let url = URL(string: imageLocalUrl),
                   let imageData = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.fullResolutionImage = uiImage
                        ImageCache.shared.setImage(uiImage, forKey: imageLocalUrl)
                        self.isFullResolutionLoaded = true
                    }
                }
            }
        }
    }
}




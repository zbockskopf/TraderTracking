//
//  Untitled.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 7/4/24.
//

import UIKit
import SwiftUI

class LandscapeViewController: UIViewController {
    var rootView: DetailView

    init(rootView: DetailView) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let landscapeSwiftUIView = UIHostingController(rootView: rootView)
        addChild(landscapeSwiftUIView)
        landscapeSwiftUIView.view.frame = view.frame
        view.addSubview(landscapeSwiftUIView.view)
        landscapeSwiftUIView.didMove(toParent: self)
    }
}


struct LandscapeViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var showDetailView: Bool
    @Binding var detailViewAnimation: Bool
    var post: DiscordMessage
    @Binding var selectedPicID: UUID?
    var updateScrollPosition: (UUID?) -> ()
    
    func makeUIViewController(context: Context) -> LandscapeViewController {
        let detailView = DetailView(
            showDetailView: $showDetailView,
            detailViewAnimation: $detailViewAnimation,
            post: post,
            selectedPicID: $selectedPicID,
            updateScrollPosition: updateScrollPosition
        )
        return LandscapeViewController(rootView: detailView)
    }
    
    func updateUIViewController(_ uiViewController: LandscapeViewController, context: Context) {
        // No need to update anything here
    }
}


struct YourLandscapeSwiftUIView: View {
    var body: some View {
        Text("This view is forced into landscape mode")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            .edgesIgnoringSafeArea(.all)
    }
}



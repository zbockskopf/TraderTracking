//
//  ImageUIView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//
 
import SwiftUI
import ImageUI
import RealmSwift

struct ImageUIView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    
    typealias UIViewControllerType = IFBrowserViewController
    var images: [IFImage]
    
    
    func makeUIViewController(context: Context) -> ImageUI.IFBrowserViewController {
        let vc = IFBrowserViewController(images: images)
        AppUtility.lockOrientation(.landscape)
        vc.configuration.actions = [.delete, .share]
        vc.configuration.prefersAspectFillZoom = true
//        browserViewController.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(temp))

        return vc
    }
    

    func updateUIViewController(_ uiViewController: ImageUI.IFBrowserViewController, context: Context) {

        if isPresented && uiViewController.presentedViewController == nil {
            
                    
            let vc = IFBrowserViewController(images: images)
        
            vc.configuration.actions = [.delete, .share]
            vc.delegate = context.coordinator as? any IFBrowserViewControllerDelegate
            AppUtility.lockOrientation(.landscape)
//            uiViewController.present(vc, animated: true)
            vc.presentationController?.delegate = context.coordinator
            }
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
    }
    
    
    class Coordinator: NSObject, IFBrowserViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
        let owner: ImageUIView
        init(_ owner: ImageUIView) {
            self.owner = owner
        }

        func imageUI(_ vc: IFBrowserViewController) {

            // picked image handling code here
            AppUtility.lockOrientation(.all)
            vc.presentingViewController?.dismiss(animated: true)
            owner.isPresented = false    // << reset on action !!
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            AppUtility.lockOrientation(.all)
            owner.isPresented = false    // << reset on swipe !!
        }
    }

}

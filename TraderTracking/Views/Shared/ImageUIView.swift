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
    
    typealias UIViewControllerType = UINavigationController
    var images: [IFImage]

    var browserHostingViewController: UIHostingController<IFBrowserView> {
            let images = images
            let configuration = IFBrowserViewController.Configuration(actions: [.share, .delete])
            let contentView = IFBrowserView(
                images: images,
                selectedIndex: .constant(.random(in: images.indices)),
                configuration: configuration,
                action: { identifier in
                    print(identifier)
                })
            
            return UIHostingController(rootView: contentView)
        }
    
    func makeUIViewController(context: Context) -> UINavigationController { //ImageUI.IFBrowserViewController {
        
        let vc = IFBrowserViewController(images: images)
//        AppUtility.lockOrientation(.landscape)
        vc.configuration.actions = [.delete, .share]
        vc.configuration.prefersAspectFillZoom = true
        let nc = UINavigationController(rootViewController: vc)

//        nc.pushViewController(vc, animated: true)
        nc.navigationBar.scrollEdgeAppearance = nc.navigationBar.standardAppearance
        nc.navigationItem.leftBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(context.coordinator.exitView))

        return nc
    }
    
    

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {

        if isPresented && uiViewController.presentedViewController == nil {
            
                    
//            let vc = IFBrowserViewController(images: images)
//
//            vc.configuration.actions = [.delete, .share]
//            vc.delegate = context.coordinator as any UINavigationControllerDelegate
//            let nc = UINavigationController(rootViewController: vc)
            uiViewController.delegate = context.coordinator as any UINavigationControllerDelegate
            uiViewController.presentationController?.delegate = context.coordinator
            }
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
    }
    
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {
        let owner: ImageUIView
        init(_ owner: ImageUIView) {
            self.owner = owner
        }
        
        @objc func exitView(){
            owner.isPresented = false
        }

        func imageUI(_ vc: UINavigationController) {

            // picked image handling code here
//            AppUtility.lockOrientation(.all)
            vc.presentingViewController?.dismiss(animated: true)
            owner.isPresented = false    // << reset on action !!
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//            AppUtility.lockOrientation(.all)
            owner.isPresented = false    // << reset on swipe !!
        }
    }

}

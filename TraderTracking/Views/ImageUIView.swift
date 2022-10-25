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
    
    
    func makeUIViewController(context: Context) -> UINavigationController { //ImageUI.IFBrowserViewController {
        
        let vc = IFBrowserViewController(images: images)
//        AppUtility.lockOrientation(.landscape)
        vc.configuration.actions = [.delete, .share]
        vc.configuration.prefersAspectFillZoom = true
        let nc = UINavigationController(rootViewController: vc)
//        nc.navigationBar.backgroundColor = .label

//        nc.pushViewController(vc, animated: true)
//        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
//        nc.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(temp))

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

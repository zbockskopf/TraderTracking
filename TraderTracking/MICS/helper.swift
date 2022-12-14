//
//  helper.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/19/22.
//

import Foundation
import SwiftUI
import RealmSwift


struct MyFormatter {
    
    let calendar = Calendar.current
    
    func numFormat(num: Decimal128) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        
        return numberFormatter.string(from: NSNumber(value: Double(num.stringValue)!))!
    }
    
    @ViewBuilder
    func titleDate(date: Date) -> some View {
        if Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: Date()) {
            Text("Today")
                .font(.title)
        }else{
            HStack{
                Text(date, style: .date)
                    .font(.title)
            }
        }
    }
    
    @ViewBuilder
    func headerDate(date: Date) -> some View {
        
        if calendar.startOfDay(for: date) == calendar.startOfDay(for: Date()) {
            Text("Today")
        }else{
            HStack{
                Text(formateHeaderDate(date: date))
                Spacer()
            }
            
        }
    }
    
    func formateHeaderDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    func asUiImage() -> UIImage {
            var uiImage = UIImage(systemName: "exclamationmark.triangle.fill")!
            let controller = UIHostingController(rootView: self)
           
            if let view = controller.view {
                let contentSize = view.intrinsicContentSize
                view.bounds = CGRect(origin: .zero, size: contentSize)
                view.backgroundColor = .clear

                let renderer = UIGraphicsImageRenderer(size: contentSize)
                uiImage = renderer.image { _ in
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                }
            }
            return uiImage
        }
    
    func saveAsImage(width: CGFloat, height: CGFloat, _ completion: @escaping (UIImage) -> Void) {
            let size = CGSize(width: width, height: height)
            
            let controller = UIHostingController(rootView: self.frame(width: width, height: height))
            controller.view.bounds = CGRect(origin: .zero, size: size)
            let image = controller.view.asUIImage()
            
            completion(image)
        }
    func getRect()->CGRect{
        return UIScreen.main.bounds
    }
    
    func safeArea()->UIEdgeInsets{
        let null = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return null
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else{
            return null
        }
        
        return safeArea
    }
    
    func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.currentUIWindow()?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

public extension UIApplication {
    func currentUIWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}


struct AppUtility {


}


extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}
extension Date {
    
    var cureentWeekMonday: Date {
           return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
       }
       var currentWeekdays: [Date] {
           
           return (0...dayNumberOfWeek()!).compactMap{ Calendar.iso8601.date(byAdding: DateComponents(day: $0), to: cureentWeekMonday) } // for Swift versions earlier than 4.1 use flatMap instead
       }
    
    func dayNumberOfWeek() -> Int? {
        let weekDay = Calendar.iso8601.dateComponents([.weekday], from: self).weekday
        if weekDay == 1 || weekDay == 7 {
            return 4
        }else{
            return Calendar.iso8601.dateComponents([.weekday], from: self).weekday! - 2
        }
    }
}



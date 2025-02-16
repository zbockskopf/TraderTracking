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
    
    func formatAccountInts(num: Decimal128) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1

        let formattedString = formatter.string(from: NSNumber(value: Double(num.stringValue)!)) ?? ""
        return formattedString
    }
    
    
    func numFormat(num: Decimal128) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        
        return numberFormatter.string(from: NSNumber(value: Double(num.stringValue)!))!
    }
    
    func percentFormat(num: Double) -> String {
        let percentFormatter            = NumberFormatter()
        percentFormatter.numberStyle    = NumberFormatter.Style.percent
        percentFormatter.minimumFractionDigits = 1
        percentFormatter.maximumFractionDigits = 2
        return percentFormatter.string(for: num)!
    }
    
    func forexCalendarFormat(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMdd.yyyy"
        return formatter.string(from: date).lowercased()
    }
    
    func newsDate(date: String) -> Date {
        //print(date)
        let formatter = DateFormatter()
        formatter.dateFormat = "eee MMM d yyyy h:mma"
        return formatter.date(from: date) ?? Date()
    }
    
    func convertImportDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
    
    func convertNinjaTraderImportDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "M/d/yyyy h:mm:ss a"
        return formatter.date(from: date) ?? Date()
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
    func dayOfWeek(date: Date) -> some View {
        
        if calendar.startOfDay(for: date) == calendar.startOfDay(for: Date()) {
            HStack{
                Text("Today")
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.title)
                    .bold()
//                    .padding(.vertical, 15)
                Text(journalDate(date: date))
                Spacer()
            }
        }else{
            HStack{
                Text(formateDayOfWeek(date:date))
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.title)
                    .bold()
//                    .padding(.vertical, 15)
                Text(journalDate(date: date))
                Spacer()
            }
        }
    }
    
    func formateDayOfWeek(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    
    @ViewBuilder
    func headerDate(date: Date) -> some View {
        
        if calendar.startOfDay(for: date) == calendar.startOfDay(for: Date()) {
            Text("Today")
                .bold()
        }else{
            HStack{
                Text(formateHeaderDate(date: date))
                Spacer()
            }
        }
    }
    
    func formateHeaderDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    func journalDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    func statsDailyDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
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


struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}


extension View {
    
    @ViewBuilder
    func rect(completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .scrollView(axis: .horizontal))
                    
                    Color.clear
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: completion)
                }
            }
    }
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
    func discordMessageStringToDate(dateString: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        // Parse the date string to a Date object
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            print("Invalid date format")
            return nil
        }
        
        // Create a DateFormatter to convert the Date object to local time
        let localFormatter = DateFormatter()
        localFormatter.timeZone = TimeZone.current
        localFormatter.dateStyle = .medium
        localFormatter.timeStyle = .medium
        
        // Convert Date object to local time and then back to Date
        let localDateString = localFormatter.string(from: date)
        guard let localDate = localFormatter.date(from: localDateString) else {
            print("Failed to convert to local date")
            return nil
        }
        
        return localDate
    }

    
    func getWeekNumber() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: self)
    }
    
    var tradeListWeekDates: [Date] {
        let currentWeekdays = self.currentWeekdays
        return currentWeekdays
    }
    
    var newsWeekDates: [Date] {
        let currentWeekdays = self.currentWeek
        return currentWeekdays
    }
    
    var newsNextWeekDates: [Date] {
        let currentWeekdays = self.nextWeek
        return currentWeekdays
    }
//    func weekDates() -> [Date]{
//        
//    }
    
    func startOfYear() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date()))!
    }
    
    var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    var cureentWeekMonday: Date {
           return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
       }
    
    var cureentWeekIDK: Date {
           return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
       }
    var currentWeekdays: [Date] {
       
        return (0...dayNumberOfWeek()!).compactMap{ Calendar.iso8601.date(byAdding: DateComponents(day: $0), to: cureentWeekMonday) } // for Swift versions earlier than 4.1 use flatMap instead
    }
    
    var startOfTheWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Calendar.current.startOfDay(for: self)))!
    }
    func endOfWeek() -> Date {
        let calendar = Calendar.current
        let weekDayComponent = calendar.component(.weekday, from: self)
        
        // Calculate the number of days to add to get to the end of the week
        // Assuming the calendar's first day of the week is Sunday
        let daysTillEndOfWeek = 7 - weekDayComponent

        // Add those days to the given date
        return calendar.date(byAdding: .day, value: daysTillEndOfWeek, to: self)!
    }
    
    var isWeekend: Bool{
        return (Calendar.current.dateComponents([.weekday], from: self).weekday != 1 && Calendar.current.dateComponents([.weekday], from: self).weekday != 7) ? false : true
    }
    
    var currentWeek: [Date] {
       
        return (0...6).compactMap{ Calendar.current.date(byAdding: DateComponents(day: $0), to: Calendar.current.date(byAdding: .day, value: 0, to: cureentWeekIDK)!) } // for Swift versions earlier than 4.1 use flatMap instead
    }
    
    var currentWeekMonFri: [Date] {
       
        return (1...5).compactMap{ Calendar.current.date(byAdding: DateComponents(day: $0), to: Calendar.current.date(byAdding: .day, value: 0, to: cureentWeekIDK)!) } // for Swift versions earlier than 4.1 use flatMap instead
    }
    
    var nextWeek: [Date] {
       
        return (7...13).compactMap{ Calendar.current.date(byAdding: DateComponents(day: $0), to: Calendar.current.date(byAdding: .day, value: 0, to: cureentWeekIDK)!) } // for Swift versions earlier than 4.1 use flatMap instead
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
        
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func dayNumberOfWeek() -> Int? {
        let weekDay = Calendar.iso8601.dateComponents([.weekday], from: self).weekday
        if weekDay == 1 || weekDay == 7 {
            return 4
        }else{
            return Calendar.iso8601.dateComponents([.weekday], from: self).weekday! - 2
        }
    }
    
    func endOfDay() -> Date {
        let calendar = Calendar.current
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: self) else {
            return Date()
        }
        return startOfNextDay.addingTimeInterval(-1)
    }
    
    func previousDay() -> Date {
        let calendar = Calendar.current
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: self) else {
            return Date()
        }
        return previousDay
    }
    
    
}


extension Results {
    var list: RealmSwift.List<Element> {
    reduce(.init()) { list, element in
      list.append(element)
      return list
    }
  }
}


extension DragGesture.Value {
    
    /// The current drag velocity.
    ///
    /// While the velocity value is contained in the value, it is not publicly available and we
    /// have to apply tricks to retrieve it. The following code accesses the underlying value via
    /// the `Mirror` type.
    internal var velocity: CGSize {
        let valueMirror = Mirror(reflecting: self)
        for valueChild in valueMirror.children {
            if valueChild.label == "_velocity" {
                let velocityMirror = Mirror(reflecting: valueChild.value)
                for velocityChild in velocityMirror.children {
                    if velocityChild.label == "valuePerSecond" {
                        if let velocity = velocityChild.value as? CGSize {
                            return velocity
                        }
                    }
                }
            }
        }
        
        fatalError("Unable to retrieve velocity from \(Self.self)")
    }
    
}


extension CGFloat {
    func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
        /// If Value less than it's Initial Input Range
        let x = self
        let length = inputRange.count - 1
        if x <= inputRange[0] { return outputRange[0] }
        
        for index in 1...length {
            let x1 = inputRange[index - 1]
            let x2 = inputRange[index]
            
            let y1 = outputRange[index - 1]
            let y2 = outputRange[index]
            
            /// Linear Interpolation Formula: y1 + ((y2-y1) / (x2-x1)) * (x-x1)
            if x <= inputRange[index] {
                let y = y1 + ((y2-y1) / (x2-x1)) * (x-x1)
                return y
            }
        }
        
        /// If Value Exceeds it's Maximum Input Range
        return outputRange[length]
    }
}


struct MyHelper {
    func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current

        let startDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)

        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }
    
}



struct LazyView<Content: View>: View {
    private let build: () -> Content
    
    init(_ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}






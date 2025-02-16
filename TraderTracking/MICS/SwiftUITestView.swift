//import SwiftUI
//
//struct testingview: View {
//    let items = ["Item 1", "Item 2", "Item 3"]
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(0.<4) { item in
//                    ZStack {
//                        // Your custom row content without a chevron
//                        HStack {
//                            Text(items[item])
//                            Spacer()
//                            // Other content if needed (e.g., an image or custom accessory)
//                        }
//                        // Invisible NavigationLink that makes the row tappable
//                        NavigationLink(destination: DetailView(item: item)) {
//                            EmptyView()
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .opacity(0)
//                    }
//                    // Ensures the entire row is tappable
//                    .contentShape(Rectangle())
//                }
//            }
//            .navigationTitle("Items")
//        }
//    }
//}
//
//struct DetailView: View {
//    let item: String
//
//    var body: some View {
//        Text("Detail for \(item)")
//            .font(.largeTitle)
//    }
//}
//
//#Preview {
//    testingview()
//}

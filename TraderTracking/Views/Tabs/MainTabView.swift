import SwiftUI
import RealmSwift

struct MainTabView: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var notifications: MyNotifications
    @EnvironmentObject var newsController: ForexCrawler
    
    @StateObject var menuController = MenuController.shared
    @StateObject var gestureController = GestureController()
    @StateObject var tradeListData = TradeListViewModel()
    
    @State private var selection = 0
    @State var showMenu: Bool = false
    @State var offSet: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    var body: some View {
        let sideBarWidth = getSideBarWidth()
        ZStack {
            HStack(spacing: 0) {
                sideMenuView(sideBarWidth: sideBarWidth)
                mainTabView(sideBarWidth: sideBarWidth)
            }
            .frame(width: getRect().width + sideBarWidth)
            .offset(x: calculateOffset(sideBarWidth: sideBarWidth))
            .gesture(dragGesture())
        }
        .onAppear(perform: setupTabBarAppearance)
        .onChange(of: showMenu, perform: handleMenuChange)
        .onChange(of: gestureOffset, perform: { _ in onChange() })
    }
    
    private func sideMenuView(sideBarWidth: CGFloat) -> some View {
        SideMenu(showMenu: $showMenu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(width: sideBarWidth)
            .environmentObject(realmController)
            .environmentObject(notifications)
            .environmentObject(menuController)
    }
    
    private func mainTabView(sideBarWidth: CGFloat) -> some View {
        ZStack {
            TabView(selection: $menuController.selection) {
                Dashboard(showMenu: $showMenu, offSet: $offSet)
                    .tabItem {
                        menuController.selection == 0 ? Image("Tracker-Active") : Image("Tracker-Inactive")
                        Text("")
                    }
                    .environmentObject(realmController)
                    .environmentObject(notifications)
                    .environmentObject(menuController)
                    .environmentObject(newsController)
                    .tag(0)
                
                NewsPager()
                    .tabItem {
                        menuController.selection == 2 ? Image("News-Active") : Image("News-Inactive")
                        Text("")
                    }
                    .environmentObject(newsController)
                    .environmentObject(menuController)
                    .tag(2)
                
                TradesListView(account: realmController.account)
                    .tabItem {
                        menuController.selection == 1 ? Image("List-Active") : Image("List-Inactive")
                        Text("")
                    }
                    .environmentObject(realmController)
                    .environmentObject(tradeListData)
                    .environmentObject(menuController)
                    .environmentObject(newsController)
                    .tag(1)
                
                if UserDefaults.standard.bool(forKey: "personalDevice"){
                    JournalView()
                        .tabItem {
                            menuController.selection == 3 ? Image("Journal-Active") : Image("Journal-Inactive")
                        }
                        .tag(3)
                }
            }
            .frame(width: getRect().width)
            .onChange(of: menuController.selection) { handleTabSelectionChange($0) }
        }
    }
    
    private func getSideBarWidth() -> CGFloat {
        getRect().width - 90
    }
    
    private func calculateOffset(sideBarWidth: CGFloat) -> CGFloat {
        -sideBarWidth / 2 + (offSet > 0 ? offSet : 0)
    }
    
    private func dragGesture() -> some Gesture {
        !menuController.showListView ?
            DragGesture()
                .updating($gestureOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded(onEnd) : nil
    }
    
    private func handleTabSelectionChange(_ value: Int) {
        menuController.showListView = (value == 1 || value == 2 || value == 3)
    }
    
    private func handleMenuChange(_ newValue: Bool) {
        let sideBarWidth = getSideBarWidth()
        withAnimation {
            if showMenu {
                offSet = sideBarWidth
                lastStoredOffset = offSet
            } else {
                offSet = 0
                lastStoredOffset = 0
            }
        }
    }
    
    private func onChange() {
        let sideBarWidth = getSideBarWidth()
        withAnimation(.linear) {
            offSet = min(max(gestureOffset + lastStoredOffset, 0), sideBarWidth)
        }
    }
    
    private func onEnd(value: DragGesture.Value) {
        if abs(value.velocity.width) > 500 {
            swipeWithSpeed(value: value)
        } else {
            swipeAction(value: value)
        }
    }
    
    private func swipeWithSpeed(value: DragGesture.Value) {
        let sideBarWidth = getSideBarWidth()
        let translation = value.translation.width
        
        withAnimation {
            if translation > 0 {
                offSet = sideBarWidth
                showMenu = true
            } else {
                offSet = 0
                showMenu = false
            }
        }
        
        lastStoredOffset = offSet
    }
    
    private func swipeAction(value: DragGesture.Value) {
        let sideBarWidth = getSideBarWidth()
        let translation = value.translation.width
        
        withAnimation {
            if translation > 0 {
                if translation > sideBarWidth / 5 {
                    offSet = sideBarWidth
                    showMenu = true
                } else {
                    offSet = 0
                    showMenu = false
                }
            } else {
                if -translation > sideBarWidth / 5 {
                    offSet = 0
                    showMenu = false
                } else {
                    offSet = sideBarWidth
                    showMenu = true
                }
            }
        }
        
        lastStoredOffset = offSet
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor(Color.clear.opacity(0.2))
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

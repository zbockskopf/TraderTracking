
import SwiftUI
import UIKit

// MARK: Custom Observable Object to Handle Updates
class DynamicProgress: NSObject,ObservableObject{
    // MARK: Progress Bar Properties
    @Published var isAdded: Bool = false
    @Published var hideStatusBar: Bool = false
    @Published var deletedTrades: [Trade] = []
    @Published var undo: Bool = false
    
    // MARK: Add/Update/Remove Methods
    
    func updateProgressView(to: CGFloat){
        // MARK: Using Notification Center For Updating Progress
        // NOTE: You can Also Directly Use Progress Here, Because It's an Observable Class
        NotificationCenter.default.post(name: NSNotification.Name("UPDATE_PROGRESS"), object: nil,userInfo: [
            "progress": to
        ])
    }
    
    func removeProgressView(){
//        if let view = rootController().view.viewWithTag(1009){
//            view.removeFromSuperview()
//            isAdded = false
//            print("REMOVED FROM ROOT")
//        }
        if !undo{
            var temp: [String] = []
            for i in deletedTrades{
                if i.photoDirectory != nil{
                    temp.append(i.photoDirectory!)
                }
                
            }
            RealmController.shared.myImage.deleteAllImages(directories: temp)
//            RealmController.shared.deleteTrades(trades: deletedTrades)
            
        }else{
            for i in deletedTrades{
                RealmController.shared.upateAccountAfterTradeUndo(trade: i)
            }
        }
        RealmController.shared.getWinRate()
        deletedTrades.removeAll()
        isAdded.toggle()
    }
    
    func removeProgressWithAnimations(){
        NotificationCenter.default.post(name: NSNotification.Name("CLOSE_PROGRESS_VIEW"), object: nil)
    }
    
}

// MARK: Custom Dynamic Island based Progress View

struct DynamicProgressView: View{
    // MARK: Passing Properties
    var config: ProgressConfig
    @EnvironmentObject var progressBar: DynamicProgress
    @EnvironmentObject var realmController: RealmController
    
    // MARK: Animation Properties
    @State var showProgressView: Bool = false
    @State var progress: CGFloat = 0
    @State var showAlertView: Bool = false
    var body: some View{
        // For More Check Out My Previous Dynamic Island Videos
        ZStack{
            ZStack{
                ProgressComponents()
                    .tag(1)
                ProgressComponents(isCircle: true)
            }
            
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    showProgressView = true
                }
            }
            // MARK: Button Tap Removal
            .onReceive(NotificationCenter.default.publisher(for: .init("CLOSE_PROGRESS_VIEW")), perform: { _ in
                showProgressView = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                    progressBar.removeProgressView()
                }
            })
            // MARK: Receiving Notification's
            .onReceive(NotificationCenter.default.publisher(for: .init("UPDATE_PROGRESS"))) { output in
                if let info = output.userInfo,let progress = info["progress"] as? CGFloat{
                    if progress < 1.0{
                        self.progress = progress
                        
                        if (progress * 100).rounded() == 100.0{
                            // Pushing back Inside and Presenting Simple Dynamic Island Based Alert
                            showProgressView = false

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                
                                // Animation Timing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6){
                                    progressBar.removeProgressView()
                                }
                            }
                        }
                    }
                }
            }
            ProgressView()
        }
        .offset(y: 29)
        .frame(alignment: .top)
        .position(x: UIScreen.main.bounds.width / 2)
        .ignoresSafeArea()
        
    }
    
        
    // MARK: Progress View
    @ViewBuilder
    func ProgressView()->some View{
        ZStack{
            // MARK: Image
            // MARK: Adding Rotation If Applicable
            let rotation = (progress > 1 ? 1 : (progress < 0 ? 0 : progress))
            Image(systemName: config.progressImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontWeight(.semibold)
                .frame(width: 12, height: 12)
                .foregroundColor(config.tint)
                .rotationEffect(.init(degrees: config.rotationEnabled ? Double(rotation * 360) : 0))
            
            // MARK: Progress Rings
            ZStack{
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(config.tint, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
            }
            .frame(width: 23, height: 23)
        }.onTapGesture(perform: {
            progressBar.undo.toggle()
            realmController.reAddTrades(trades: progressBar.deletedTrades)
            progressBar.removeProgressWithAnimations()
                        
        })
        .frame(width: 37, height: 37)
        .frame(width: 126,alignment: .center)
        .offset(y: showProgressView ? 45 : 0)
        .opacity(showProgressView ? 1 : 0)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: showProgressView)
    }
    
    // MARK: Progress Bar Components
    @ViewBuilder
    func ProgressComponents(isCircle: Bool = false)->some View{
        if isCircle{
            Circle()
                .fill(.black)
                .frame(width: 37, height: 37)
                .frame(width: 126,alignment: .center)
                .offset(y: showProgressView ? 45 : 0)
                // For More Depth Effect
                .scaleEffect(showProgressView ? 1 : 0.55, anchor: .center)
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: showProgressView)
                
        }else{
            // MARK: Dynamic Island Size = (126,37)
            Capsule()
                .fill(.black)
                .frame(width: 126,height: 36)
                .offset(y: 1)
        }
    }
}

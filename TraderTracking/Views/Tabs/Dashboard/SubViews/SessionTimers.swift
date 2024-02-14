//
//  SessionTimers.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/7/24.
//

import SwiftUI
import Combine

class CountdownViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var countdownString: String = ""
    private var timeRemaining: TimeInterval
    private var timer: AnyCancellable?
    private let timeZone = TimeZone(identifier: "America/New_York")!

    init() {
        timeRemaining = 60 * 60 * 9 // Initialize with 9 hours in seconds (adjust as needed).
        startCountdownTimer()
    }
    
    private func startCountdownTimer() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Find the next market open date based on the current date and the market open time (9:30 AM New York time).
        var components = calendar.dateComponents(in: timeZone, from: currentDate)
        components.hour = 9
        components.minute = 30
        components.second = 0 // Reset the seconds to 0 to start from the beginning of the minute
        
        if components.weekday == 7 { // Saturday
            // If today is Saturday, set the next market open date to Monday.
            components.day = components.day! + 2
        } else if components.weekday == 1 { // Sunday
            // If today is Sunday, set the next market open date to Monday.
            components.day = components.day! + 1
        } else if components.hour! >= 9 && components.minute! >= 30 {
            // If the current time is past market open time, we move to the next day.
            components.day = components.day! + 1
        }
        
        guard let nextMarketOpenDate = calendar.date(from: components) else {
            // If the next market open date couldn't be determined, mark the countdown as finished.
            countdownString = "Finished!"
            return
        }
        
        // Calculate the time difference between the current time and the market open time.
        timeRemaining = max(nextMarketOpenDate.timeIntervalSince(currentDate), 0)
        updateCountdownString()
        
        // Use Combine's Timer.publish to handle the countdown logic in a more reactive way.
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdownString()
            }
        
        // Store the subscription in the cancellables set manually.
        timer?.store(in: &cancellables)
    }
    
    private func updateCountdownString() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            countdownString = remainingTimeFormatter(timeRemaining)
        } else {
            countdownString = "Finished!"
            timer?.cancel()
        }
    }
    
    // ... (remainingTimeFormatter function remains unchanged)
    func remainingTimeFormatter(_ timeRemaining: TimeInterval) -> String {
        let days = Int(timeRemaining) / (3600 * 24)
        let hours = (Int(timeRemaining) % (3600 * 24)) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60

        if days > 0 {
            if days == 1 {
                return String(format: "%dD %02d:%02d:%02d", days, hours, minutes, seconds)
            } else {
                return String(format: "%dD %02d:%02d:%02d", days, hours, minutes, seconds)
            }
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}



struct CountdownTimer: View {
    @ObservedObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        ZStack {
            VStack{
                Text("NY Open")
                    .font(.subheadline)
                Text(viewModel.countdownString)
                    .font(.callout)
            }
            .foregroundColor(Color(UIColor.label))
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct LondonCountdownTimer: View {
    @ObservedObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        ZStack {
            VStack{
                Text("London Open")
                    .font(.title2)
                Text(viewModel.countdownString)
                    .font(.title3)
            }
            .foregroundColor(Color(UIColor.label))
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct AsiaCountdownTimer: View {
    @ObservedObject private var viewModel = CountdownViewModel()
    
    var body: some View {
        ZStack {
            VStack{
                Text("Asia Open")
                    .font(.title2)
                Text(viewModel.countdownString)
                    .font(.title3)
            }
            .foregroundColor(Color(UIColor.label))
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

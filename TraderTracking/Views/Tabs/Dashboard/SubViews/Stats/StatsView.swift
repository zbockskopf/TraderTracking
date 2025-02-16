import SwiftUI
import Charts
import RealmSwift

// Duration categories in ascending order
private let categoriesInOrder = [
    " <15s",
    "15-45s",
    "45s - 1m",
    "1m - 2m",
    "2m - 5m",
    "5m - 10m",
    "10m - 30m",
    "30m - 1h",
    "1h - 2h",
    "2h - 4h",
    "4h <"
]

// Helper struct for win/loss bar chart data.
struct WinLossData: Identifiable {
    let id = UUID()
    let weekday: Int       // Calendar weekday number (1 = Sunday, 2 = Monday, etc.)
    let day: String        // Short name for the day (e.g., "Mon")
    let result: String     // "Wins" or "Losses"
    let percentage: Double // Percentage of trades that are wins or losses
}

// Helper struct for the overall win/loss pie chart.
struct WinLossTotal: Identifiable {
    let id = UUID()
    let result: String  // "Wins" or "Losses"
    let count: Int
}

// Enum to represent the filter type.
enum TradeFilterType: String {
    case allTime = "All Time"
    case monthly = "Monthly"
    case weekly = "Weekly"
}

struct StatsView: View {
    @ObservedResults(Trade.self) var trades

    // State for filtering
    @State private var currentFilter: TradeFilterType = .allTime
    @State private var filterStartDate: Date? = nil
    @State private var filterEndDate: Date? = nil

    var onDismiss: () -> Void = {}

    // Compute filtered trades using the date range.
    private var filteredTrades: [Trade] {
        return trades.filter { trade in
            let entered = trade.dateEntered
            let isAfterStart = filterStartDate.map { entered >= $0 } ?? true
            let isBeforeEnd = filterEndDate.map { entered <= $0 } ?? true
            return isAfterStart && isBeforeEnd
        }
    }

    // Update the navigation title based on filter.
    private var navTitle: String {
        switch currentFilter {
        case .allTime:
            return "All Time Stats"
        case .monthly:
            return "Monthly Stats"
        case .weekly:
            return "Weekly Stats"
        }
    }

    var body: some View {
        List {
            // Chart 1: Trade Count by Duration Category
            Section(header: Text("Trade Count by Duration")) {
                VStack(alignment: .leading, spacing: 2) {
                    Chart {
                        ForEach(filteredTradeCounts, id: \.category) { data in
                            BarMark(
                                x: .value("Duration Range", data.category),
                                y: .value("Number of Trades", data.count)
                            )
                            .foregroundStyle(.green)
                            .cornerRadius(4)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: filteredTradeCounts.map(\.category)) { value in
                            if let categoryName = value.as(String.self) {
                                AxisValueLabel {
                                    Text(categoryName)
                                        .frame(width: 20)
                                        .padding(2)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    .chartXAxisLabel("Trade Duration")
                    .chartYAxisLabel("Number of Trades")
                    .frame(height: 400)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }

            // Chart 2: Trade Win/Loss Percentage by Day of Week
            Section(header: Text("Win/Loss Percentage by Day of Week")) {
                VStack(alignment: .leading, spacing: 2) {
                    Chart {
                        ForEach(winLossData, id: \.id) { data in
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Percentage", data.percentage)
                            )
                            .position(by: .value("Result", data.result))
                            .foregroundStyle(by: .value("Result", data.result))
                            .cornerRadius(4)
                        }
                    }
                    .chartForegroundStyleScale([
                        "Wins": Color.green,
                        "Losses": Color.red
                    ])
                    .chartXAxis {
                        AxisMarks(values: winLossData.map { $0.day }.uniqueSorted()) { value in
                            if let day = value.as(String.self) {
                                AxisValueLabel(day)
                            }
                        }
                    }
                    .chartXAxisLabel("Day of Week")
                    .chartYAxisLabel("Win/Loss Percentage (%)")
                    .frame(height: 400)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }

            // Chart 3: Overall Win vs Loss Donut Chart with Center Label
            Section(header: Text("Win vs Loss")) {
                ZStack {
                    Chart {
                        ForEach(winLossTotals, id: \.id) { data in
                            SectorMark(
                                angle: .value("Count", data.count),
                                innerRadius: .ratio(0.6)
                            )
                            .foregroundStyle(data.result == "Wins" ? Color.green : Color.red)
                        }
                    }
                    .chartLegend(position: .bottom)
                    .frame(height: 300)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    
                    // Center label for donut chart showing win percentage.
                    VStack {
                        let wins = winLossTotals.first { $0.result == "Wins" }?.count ?? 0
                        let losses = winLossTotals.first { $0.result == "Losses" }?.count ?? 0
                        let total = wins + losses
                        let winPercentage = total > 0 ? (Double(wins) / Double(total)) * 100.0 : 0.0
                        Text("\(String(format: "%.1f", winPercentage))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(navTitle)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // All Time Option
                    Button {
                        currentFilter = .allTime
                        filterStartDate = nil
                        filterEndDate = nil
                    } label: {
                        Label("All Time", systemImage: currentFilter == .allTime ? "checkmark" : "")
                    }
                    // Monthly Option
                    Button {
                        let calendar = Calendar.current
                        let now = Date()
                        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
                            currentFilter = .monthly
                            filterStartDate = startOfMonth
                            filterEndDate = now
                        }
                    } label: {
                        Label("Monthly", systemImage: currentFilter == .monthly ? "checkmark" : "")
                    }
                    // Weekly Option
                    Button {
                        let calendar = Calendar.current
                        let now = Date()
                        if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) {
                            currentFilter = .weekly
                            filterStartDate = startOfWeek
                            filterEndDate = now
                        }
                    } label: {
                        Label("Weekly", systemImage: currentFilter == .weekly ? "checkmark" : "")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.green)
                }
            }
        }
    }

    // MARK: - Data for Duration Chart

    private var filteredTradeCounts: [(category: String, count: Int)] {
        let grouped = Dictionary(grouping: filteredTrades) { trade -> String in
            let durationInSeconds = trade.dateExited.timeIntervalSince(trade.dateEntered)
            return durationCategory(for: durationInSeconds)
        }
        var results: [(String, Int)] = []
        for cat in categoriesInOrder {
            let count = grouped[cat]?.count ?? 0
            if count > 0 {
                results.append((cat, count))
            }
        }
        return results
    }

    private func durationCategory(for seconds: Double) -> String {
        switch seconds {
        case 0..<15:
            return " <15s"
        case 15..<45:
            return "15-45s"
        case 45..<60:
            return "45s - 1m"
        case 60..<120:
            return "1m - 2m"
        case 120..<300:
            return "2m - 5m"
        case 300..<600:
            return "5m - 10m"
        case 600..<1800:
            return "10m - 30m"
        case 1800..<3600:
            return "30m - 1h"
        case 3600..<7200:
            return "1h - 2h"
        case 7200..<14400:
            return "2h - 4h"
        default:
            return "4h <"
        }
    }

    // MARK: - Data for Win/Loss Chart

    private var winLossData: [WinLossData] {
        let grouped = Dictionary(grouping: filteredTrades) { trade in
            Calendar.current.component(.weekday, from: trade.dateEntered)
        }
        var results: [WinLossData] = []
        for (weekday, tradesForDay) in grouped {
            let total = tradesForDay.count
            let wins = tradesForDay.filter { $0.win! }.count
            let losses = total - wins
            let winPercentage = total > 0 ? (Double(wins) / Double(total)) * 100.0 : 0.0
            let lossPercentage = total > 0 ? (Double(losses) / Double(total)) * 100.0 : 0.0
            let dayName = self.dayName(for: weekday)
            results.append(WinLossData(weekday: weekday, day: dayName, result: "Wins", percentage: winPercentage))
            results.append(WinLossData(weekday: weekday, day: dayName, result: "Losses", percentage: lossPercentage))
        }
        return results.sorted {
            if $0.weekday == $1.weekday {
                return $0.result < $1.result
            }
            return $0.weekday < $1.weekday
        }
    }

    private func dayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[weekday - 1]
    }

    // MARK: - Data for Win vs Loss Pie Chart

    private var winLossTotals: [WinLossTotal] {
        let wins = filteredTrades.filter { $0.win! }.count
        let losses = filteredTrades.filter { !$0.win! }.count
        return [
            WinLossTotal(result: "Wins", count: wins),
            WinLossTotal(result: "Losses", count: losses)
        ]
    }
}

// MARK: - Helpers

extension Sequence where Element: Hashable {
    /// Returns the unique elements of the sequence in the order they first appear.
    func uniqueSorted() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}

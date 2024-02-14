//
//  TradingViewAPI.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/18/23.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

struct TradingViewChartView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
        uiView.scrollView.isScrollEnabled = false
    }
}



struct TradingViewWidget: View {
    var body: some View {
//        VStack {
            TradingViewChartView(htmlString: "<!-- TradingView Widget BEGIN -->\n<div class=\"tradingview-widget-container\">\n  <div class=\"tradingview-widget-container__widget\"></div>\n  <div class=\"tradingview-widget-copyright\"><a href=\"https://www.tradingview.com/markets/\" rel=\"noopener\" target=\"_blank\"><span class=\"blue-text\">Markets today</span></a> by TradingView</div>\n  <script type=\"text/javascript\" src=\"https://s3.tradingview.com/external-embedding/embed-widget-ticker-tape.js\" async>\n  {\n  \"symbols\": [\n    {\n      \"description\": \"EMS2023\",\n      \"proName\": \"CME_MINI:ESM2023\"\n    },\n    {\n      \"description\": \"DXY\",\n      \"proName\": \"TVC:DXY\"\n    },\n    {\n      \"description\": \"\",\n      \"proName\": \"NQM2023\"\n    },\n    {\n      \"description\": \"\",\n      \"proName\": \"FOREXCOM:EURUSD\"\n    }\n  ],\n  \"showSymbolLogo\": true,\n  \"colorTheme\": \"light\",\n  \"isTransparent\": true,\n  \"displayMode\": \"adaptive\",\n  \"locale\": \"en\"\n}\n  </script>\n</div>\n<!-- TradingView Widget END -->")
                .allowsTightening(false)
//        }
    }
}

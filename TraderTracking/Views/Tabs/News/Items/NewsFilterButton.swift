//
//  NewsFilterButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/18/23.
//

import SwiftUI

struct NewsFilterButton: View {
    @EnvironmentObject var newsController: ForexCrawler
    var body: some View {
        Menu{
            Menu{
                Button {
                    newsController.showHighImpact.toggle()
                } label: {
                    if newsController.showHighImpact{
                        Label("High", systemImage: "checkmark")
                    }else{
                        Text("High")
                    }
                }
                Button {
                    newsController.showMediumImpact.toggle()
                } label: {
                    if newsController.showMediumImpact{
                        Label("Medium", systemImage: "checkmark")
                    }else{
                        Text("Medium")
                    }
                }
                
                Button {
                    newsController.showLowImpact.toggle()
                } label: {
                    if newsController.showLowImpact{
                        Label("Low", systemImage: "checkmark")
                    }else{
                        Text("Low")
                    }
                }
            } label:{
                Text("Impact")
            }
            .menuActionDismissBehavior(.disabled)
            Menu{
                //AUD, CAD, CHF, CNY, EUR, GBP, JPY, NZD,USD
                Button {
                    newsController.newsCurrenciesFilter["USD"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["USD"]!{
                        Label("USD", systemImage: "checkmark")
                    }else{
                        Text("USD")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["AUD"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["AUD"]!{
                        Label("AUD", systemImage: "checkmark")
                    }else{
                        Text("AUD")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["CAD"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["CAD"]!{
                        Label("CAD", systemImage: "checkmark")
                    }else{
                        Text("CAD")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["CHF"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["CHF"]!{
                        Label("CHF", systemImage: "checkmark")
                    }else{
                        Text("CHF")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["CNY"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["CNY"]!{
                        Label("CNY", systemImage: "checkmark")
                    }else{
                        Text("CNY")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["EUR"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["EUR"]!{
                        Label("EUR", systemImage: "checkmark")
                    }else{
                        Text("EUR")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["GBP"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["GBP"]!{
                        Label("GBP", systemImage: "checkmark")
                    }else{
                        Text("GBP")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["JPY"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["JPY"]!{
                        Label("JPY", systemImage: "checkmark")
                    }else{
                        Text("JPY")
                    }
                }
                Button {
                    newsController.newsCurrenciesFilter["NZD"]?.toggle()
                } label: {
                    if newsController.newsCurrenciesFilter["NZD"]!{
                        Label("NZD", systemImage: "checkmark")
                    }else{
                        Text("NZD")
                    }
                }
            } label: {
                Text("Currency")
            }
            .menuActionDismissBehavior(.disabled)
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.circle")
                .frame(width: 20, height: 20)
        }
        .menuActionDismissBehavior(.disabled)
    }
}


//
//  MatchView.swift
//  App
//
//  Created by Shibo Tong on 12/8/21.
//

import SwiftUI
//import SDWebImageSwiftUI

struct MatchView: View {
    @EnvironmentObject var env: DotaEnvironment
    @EnvironmentObject var data: HeroDatabase
    @ObservedObject var vm: MatchViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        if vm.id == nil {
            Text("select a match")
        } else {
            if vm.match == nil {
                LoadingView()
                    .frame(width: 32, height: 32)
                    .onAppear {
                        vm.loadNewMatch()
                    }
            } else {
                if self.vm.match!.id == 0 {
                    Text("An error occured when finding match.")
                } else {
                    ScrollView {
                        if vm.loading {
                            LoadingView()
                                .frame(width: 32, height: 32)
                        }
                        buildStack()
                    }
                    .navigationTitle(vm.match!.radiantWin ? LocalizedStringKey("Radiant Win") : LocalizedStringKey("Dire Win"))
                    .navigationBarTitleDisplayMode(.large)
                    .navigationBarItems(trailing: Button(action: {
                        vm.refresh()
                    }, label: {
                        Image(systemName: "arrow.clockwise")
                    }))
                }
            }
        }
    }
    
    @ViewBuilder private func buildStack() -> some View {
        VStack(spacing: 10) {
            VStack(spacing: 30) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        MatchStatCardView(icon: "calendar", title: "Start Time", label: vm.match!.startTime.convertToTime())
                            .frame(width: 140)
                        MatchStatCardView(icon: "clock", title: "Duration", label: "\(vm.match!.duration.convertToDuration())").colorInvert()
                            .frame(width: 140)
                        MatchStatCardView(icon: "rosette", title: "Game Mode", label: LocalizedStringKey(data.fetchGameMode(id: vm.match!.mode).fetchModeName()))
                            .frame(width: 140)
                        MatchStatCardView(icon: "mappin.and.ellipse", title: "Region", label: vm.fetchGameRegion(id: "\(vm.match!.region)"))
                            .colorInvert()
                            .frame(width: 140)
                    }.padding(.horizontal)
                }
            }.padding([.top])
            if horizontalSizeClass == .regular {
                HStack(alignment: .top) {
                    AllTeamPlayerView(match: vm.match!)
                    AnalysisView(vm: AnalysisViewModel(player: vm.match!.players))
                }
            } else {
                AllTeamPlayerView(match: vm.match!)
                AnalysisView(vm: AnalysisViewModel(player: vm.match!.players))
            }
            DifferenceGraphView(vm: DifferenceGraphViewModel(goldDiff: vm.match!.goldDiff, xpDiff: vm.match!.xpDiff))
                .frame(height: 300)
        }
    }
    
}

struct MatchStatCardView: View {
    var icon: String
    var title: LocalizedStringKey
    var label: LocalizedStringKey
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0).foregroundColor(Color(.secondarySystemBackground))
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Image(systemName: icon).font(.title)
                    Spacer()
                    Text(title).font(.custom(fontString, size: 10)).foregroundColor(Color(.secondaryLabel))
                    Text(label).font(.custom(fontString, size: 15)).bold().lineLimit(2)
                }
                Spacer()
            }.padding(18)
        }
    }
}

struct MatchView_Previews: PreviewProvider {
    static var previews: some View {
        //        NavigationView {
        MatchView(vm: MatchViewModel())
        //        }
            .environmentObject(HeroDatabase.shared)
            .environment(\.locale, .init(identifier: "zh-Hans"))
        
    }
}

struct AllTeamPlayerView: View {
    var match: Match
    @State var selectedPlayer: Player?
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Players").font(.custom(fontString, size: 20)).bold().padding([.horizontal, .top])
            TeamView(players: match.fetchPlayers(isRadiant: true), isRadiant: true, score: match.fetchKill(isRadiant: true), win: match.radiantWin, maxDamage: fetchMaxDamage(players: match.players))
            TeamView(players: match.fetchPlayers(isRadiant: false), isRadiant: false, score: match.fetchKill(isRadiant: false), win: !match.radiantWin, maxDamage: fetchMaxDamage(players: match.players))
        }
        .frame(minWidth: 300)
    }
    
    func fetchMaxDamage(players: [Player]) -> Int {
        if players.first!.heroDamage != nil {
            let sortedPlayers = players.sorted(by: { $0.heroDamage! > $1.heroDamage! })
            return sortedPlayers.first!.heroDamage!
        } else {
            return 0
        }
    }
}

struct DifferenceView: View {
    var body: some View {
        ZStack {
            VStack {
                Rectangle().frame(height: 1)
                Spacer()
                Rectangle().frame(height: 1)
                Spacer()
                Rectangle().frame(height: 1)
            }
        }
    }
}

struct PlayerRowView: View {
    var player: Player
    var isRadiant: Bool
    @EnvironmentObject var env: DotaEnvironment
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var showPlayer = false
    var maxDamage: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HeroImageView(heroID: player.heroID, type: .icon)
                    .frame(width: 35, height: 35)
                    .overlay(HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Circle()
                                .frame(width: 15, height: 15)
                                .overlay(Text("\(player.level)")
                                            .foregroundColor(Color(.systemBackground))
                                            .font(.custom(fontString, size: 8)).bold())
                        }
                    })
                VStack(alignment: .leading) {
                    if player.personaname != nil {
                        Text(player.personaname!).font(.custom(fontString, size: 15)).bold().lineLimit(1)
                    } else {
                        Text("Anonymous").font(.custom(fontString, size: 15)).bold().lineLimit(1)
                    }
                    KDAView(kills: player.kills, deaths: player.deaths, assists: player.assists, size: 13)
                }.frame(minWidth: 0)
                Spacer()
                VStack(spacing: 1) {
                    HStack(spacing: 1) {
                        ItemView(id: player.item0).frame(width: 24, height: 18)
                        ItemView(id: player.item1).frame(width: 24, height: 18)
                        ItemView(id: player.item2).frame(width: 24, height: 18)
                    }
                    HStack(spacing: 1) {
                        ItemView(id: player.item3).frame(width: 24, height: 18)
                        ItemView(id: player.item4).frame(width: 24, height: 18)
                        ItemView(id: player.item5).frame(width: 24, height: 18)
                    }
                }
                VStack(spacing: 0) {
                    HStack(spacing: 3) {
                        Circle().frame(width: 8, height: 8).foregroundColor(Color(.systemYellow))
                        Text("\(player.gpm)").foregroundColor(Color(.systemOrange))
                    }.frame(width: 40)
                    HStack(spacing: 3) {
                        Circle().frame(width: 8, height: 8).foregroundColor(Color(.systemBlue))
                        Text("\(player.xpm)").foregroundColor(Color(.systemBlue))
                    }.frame(width: 40)
                    DamageView(maxDamage: maxDamage, playerDamage: player.heroDamage ?? 0)
                }.font(.custom(fontString, size: 10))
            }.frame(height: 50)
        }
        .onTapGesture {
            showPlayer.toggle()
        }
        .sheet(isPresented: $showPlayer) {
            PlayerDetailView(player: player)
                .environmentObject(env)
        }
    }
}

struct ItemView: View {
    @EnvironmentObject var heroData: HeroDatabase
    var id: Int
    var body: some View {
//        if computeURL() == nil {
//            Image("empty_item").resizable()
//        } else {
//            WebImage(url: computeURL())
//                .resizable()
//                .renderingMode(.original)
//                .indicator(.init(content: { _, _ in
//                    Image("empty_item")
//                        .resizable()
//                }))
//                .transition(.fade)
//        }
        AsyncImage(url: computeURL()) { image in
            image.resizable().renderingMode(.original)
        } placeholder: {
            Image("empty_item").resizable()
        }
        
    }
    
    private func computeURL() -> URL? {
        guard let item = HeroDatabase.shared.fetchItem(id: id) else {
            return nil
        }
        let url = URL(string: "https://api.opendota.com\(item.img)")
        //        let url = URL(string: "https://steamcdn-a.akamaihd.net\(item.img)")
        return url
    }
}

struct TeamHeaderView: View {
    var isRadiant: Bool
    var score: Int
    var win: Bool
    var body: some View {
        HStack {
            HStack {
                Text(buildTeamString())
                    .font(.custom(fontString, size: 15))
                    .bold()
                    .foregroundColor(Color(isRadiant ? .systemGreen : .systemRed))
                Text("\(win ? "🏆" : "")")
            }
            Spacer()
            Image("battle_icon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(Color(isRadiant ? .systemGreen : .systemRed))
            Text("\(score)").font(.custom(fontString, size: 15))
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(isRadiant ? .systemGreen : .systemRed).opacity(0.2))
    }
    
    private func buildTeamString() -> LocalizedStringKey {
        if isRadiant {
            return "Radiant"
        } else {
            return "Dire"
        }
    }
}

struct TeamView: View {
    var players: [Player]
    var isRadiant: Bool
    var score: Int
    var win: Bool
    var maxDamage: Int
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        VStack(spacing: 0) {
            TeamHeaderView(isRadiant: isRadiant, score: score, win: win)
            ForEach(players, id: \.heroID) { player in
                PlayerRowView(player: player, isRadiant: isRadiant, maxDamage: maxDamage)
                    .padding(.horizontal)
            }
        }
        
    }
}

struct DamageView: View {
    var maxDamage: Int
    var playerDamage: Int
    var body: some View {
        ZStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3).frame(width: 40, height: 10)
                    .foregroundColor(Color(.secondarySystemBackground))
                RoundedRectangle(cornerRadius: 3).frame(width: calculateRectangleWidth(), height: 10).foregroundColor(.red.opacity(0.4))
            }
            Text("\(playerDamage)").font(.custom(fontString, size: 10))
        }
    }
    
    private func calculateRectangleWidth() -> CGFloat {
        if maxDamage == 0 {
            return 40.0
        } else {
            return 40.0 * CGFloat(Double(playerDamage) / Double(maxDamage))
        }
    }
}

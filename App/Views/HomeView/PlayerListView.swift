//
//  PlayerListView.swift
//  App
//
//  Created by Shibo Tong on 31/5/2022.
//

import SwiftUI

struct PlayerListView: View {
    @EnvironmentObject var env: DotaEnvironment
    var body: some View {
        ScrollView {
            VStack {
                if env.registerdID == "" {
                    EmptyRegistedView()
                        .frame(height: 190)
                } else {
                    RegisteredPlayerView(vm: SidebarRowViewModel(userid: env.registerdID, isRegistered: true))
                        .background(Color.systemBackground)
                }
                VStack {
                    HStack {
                        Text("Favorite Players")
                            .font(.custom(fontString, size: 20))
                            .bold()
                        Spacer()
                    }.padding()
                    if env.userIDs.isEmpty {
                        VStack {
                            Text("There are no players registered in you favorites.")
                                .font(.custom(fontString, size: 13))
                            Text("Please search and register a player.")
                                .font(.custom(fontString, size: 13))
                            Button {
                                env.selectedTab = .search
                                env.iPadSelectedTab = .search
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Search Player")
                                    Spacer()
                                }
                            }
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondarySystemBackground))
                        }
                        .padding(.vertical)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 100, maximum: 130), spacing: 10, alignment: .leading), count: 3), spacing: 10) {
                            ForEach(env.userIDs, id: \.self) { id in
                                NavigationLink(destination: PlayerProfileView(vm: PlayerProfileViewModel(userid: id))) {
                                    PlayerListRowView(vm: SidebarRowViewModel(userid: id))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Home")
    }
    
}

struct PlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerListView()
        }
        .environmentObject(DotaEnvironment.preview)
        .environmentObject(HeroDatabase.shared)
    }
}

struct EmptyRegistedView: View {
    @State var searchText: String = ""
    @EnvironmentObject var env: DotaEnvironment
    var body: some View {
        VStack {
            HStack {
                Text("Register Your Profile")
                    .font(.custom(fontString, size: 15))
                    .bold()
                Spacer()
            }
            TextField("Search ID", text: $searchText)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(RoundedRectangle(cornerRadius: 10).stroke().foregroundColor(.primaryDota))
                .keyboardType(.numberPad)
            Spacer()
            Button {
                Task {
                    await env.registerUser(userid: self.searchText)
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Register Player")
                    Spacer()
                }
            }
            .frame(height: 40)
            .background(Color.secondarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Color.systemBackground)
        
    }
}

struct RegisteredPlayerView: View {
    @ObservedObject var vm: SidebarRowViewModel
    @EnvironmentObject var env: DotaEnvironment
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                NavigationLink(destination: PlayerProfileView(vm: PlayerProfileViewModel(userid: vm.userid))) {
                    HStack {
                        ProfileAvartar(url: vm.profile?.avatarfull ?? "", sideLength: 70, cornerRadius: 25)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(vm.profile?.personaname ?? "").font(.custom(fontString, size: 20)).bold().lineLimit(1).foregroundColor(.label)
                            Text("\(vm.profile?.id.description ?? "")")
                                .font(.custom(fontString, size: 13))
                                .foregroundColor(Color.secondaryLabel)
                        }
                        
                        Spacer()
                        RankView(rank: vm.profile?.rank, leaderboard: vm.profile?.leaderboard)
                            .frame(width: 70, height: 70)
                            .padding(.trailing)
                        
                    }
                }
                if let matches = vm.recentMatches {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(matches) { match in
                                VStack {
                                    HeroImageView(heroID: match.heroID, type: .icon)
                                    buildWL(win: match.isPlayerWin())
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 80)
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 80)
                    .background(Color.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding(15)
            HStack {
                Spacer()
                VStack {
                    Button {
                        env.deRegisterUser(userid: vm.userid)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.label)
                    }
                    Spacer()
                }
            }.padding()
        }
    }
    @ViewBuilder private func buildWL(win: Bool, size: CGFloat = 15) -> some View {
        ZStack {
            Rectangle().foregroundColor(win ? Color(.systemGreen) : Color(.systemRed))
                .frame(width: size, height: size)
            Text("\(win ? "W" : "L")").font(.custom(fontString, size: 10)).bold().foregroundColor(.white)
        }
    }
}

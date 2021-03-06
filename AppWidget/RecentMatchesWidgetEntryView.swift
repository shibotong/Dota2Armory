//
//  RecentMatchesWidgetEntryView.swift
//  App
//
//  Created by Shibo Tong on 17/6/2022.
//

import WidgetKit
import SwiftUI

struct RecentMatchesWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    private var maxNumberOfMatches: Int {
        switch self.family {
        case .systemSmall:
            return 5
        case .systemMedium:
            return 10
        default:
            return 5
        }
    }
    
    @ViewBuilder
    var body: some View {
        ZStack {
            NetworkImage(urlString: entry.user.avatarfull).blur(radius: 40)
            Color.systemBackground.opacity(0.7)
            GeometryReader { proxy in
                let avatarSize = { () -> CGFloat in
                    if self.family == .systemSmall {
                        return proxy.size.height / 3
                    } else {
                        return proxy.size.height * 3 / 7
                    }
                }()
                VStack(spacing: 0) {
                    buildProfile(user: entry.user, avatarSize: avatarSize)
                        .frame(height: proxy.size.height / 2)
                    buildMatches(width: proxy.size.width)
                        .frame(height: proxy.size.height / 2)
                }
            }
            .padding()
            .blur(radius: entry.subscription ? 0 : 15)
            if !entry.subscription {
                SubscriptionWidgetView()
            }
        }
    }
    
    @ViewBuilder private func buildProfile(user: UserProfile, avatarSize: CGFloat) -> some View {
        switch self.family {
        case .systemSmall:
            VStack {
                NetworkImage(urlString: entry.user.avatarfull)
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                Text("\(entry.user.personaname)")
                    .font(.caption)
            }
        case .systemMedium:
            HStack {
                NetworkImage(urlString: entry.user.avatarfull)
                    .frame(width: avatarSize, height: avatarSize)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("\(entry.user.personaname)")
                        .font(.caption)
                    Text("\(entry.user.id.description)")
                        .font(.caption2)
                        .foregroundColor(.secondaryLabel)
                }
                
                Spacer()
                buildRank(profile: entry.user, size: avatarSize)
            }
        default:
            EmptyView()
        }
    
        
    }
    
    @ViewBuilder private func buildRank(profile: UserProfile, size: CGFloat) -> some View {
        HStack {
            if profile.isPlus ?? false {
                Image("dota_plus")
                    .resizable()
                    .padding(5)
                    .frame(width: size, height: size)
            }
            RankView(rank: profile.rank, leaderboard: profile.leaderboard)
                .frame(width: size, height: size)
        }
    }
    
    @ViewBuilder private func buildMatches(width: CGFloat) -> some View {
        let matches = { () -> [RecentMatch] in
            if entry.matches.count > maxNumberOfMatches {
                return Array(entry.matches[0..<maxNumberOfMatches])
            } else {
                return entry.matches
            }
        }()
        let matchWidth = width / CGFloat(maxNumberOfMatches)
        HStack(spacing: 0) {
            ForEach(matches) { match in
                buildMatch(match: match, width: matchWidth)
                    .frame(width: matchWidth)
            }
        }
//        .blur(radius: (entry.subscription && entry.user.id != 0) ? 0 : 10)
//        .padding(.horizontal)
    }
    
    @ViewBuilder private func buildMatch(match: RecentMatch, width: CGFloat) -> some View {
        // MARK: small
        let imageSize = width / 1.2
        VStack {
            HeroImageView(heroID: match.heroID, type: .icon)
                .frame(width: imageSize, height: imageSize)
            buildWL(win: match.isPlayerWin(), size: width / 1.5)
        }
        .padding(.horizontal, width / 4)
    }
    
    @ViewBuilder private func buildWL(win: Bool, size: CGFloat = 15) -> some View {
        ZStack {
            Rectangle().foregroundColor(win ? Color(.systemGreen) : Color(.systemRed))
                .frame(width: size, height: size)
            Text("\(win ? "W" : "L")").font(.caption).bold().foregroundColor(.white)
        }
    }
}

struct RecentMatchesWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        RecentMatchesWidgetEntryView(entry: SimpleEntry(date: Date(), matches: Array(RecentMatch.sample), user: UserProfile.sample, subscription: false))
//            .environment(\.widgetFamily, .systemSmall)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDevice(iPadPro12)
        
        RecentMatchesWidgetEntryView(entry: SimpleEntry(date: Date(), matches: Array(RecentMatch.sample), user: UserProfile.sample, subscription: false))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDevice(iPodTouch)
        
    }
}

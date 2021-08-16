//
//  MatchViewModel.swift
//  App
//
//  Created by Shibo Tong on 12/8/21.
//

import Foundation

class MatchViewModel: ObservableObject {
    @Published var match: Match = Match.sample
    @Published var loading = false
    @Published var recentMatch: RecentMatch
    private var matchid: String = ""
    init(match: RecentMatch) {
        self.loading = true
        self.matchid = "\(match.id)"
        self.recentMatch = match
    }
    
    init(previewMatch: Match) {
        self.match = previewMatch
        self.loading = false
        self.recentMatch = RecentMatch.sample.first!
    }
    
    func loadMatch() {
        print(matchid)
        OpenDotaController.loadMatchData(matchid: matchid) { match in
            self.match = match!
            DispatchQueue.main.async {
                self.loading = false
            }
        }
        self.match = Match.sample
    }
}

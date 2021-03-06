//
//  WCDBController.swift
//  App
//
//  Created by Shibo Tong on 18/8/21.
//

import Foundation
import WCDBSwift

class WCDBController {
    static let shared = WCDBController()
    var database: Database
    
    init() {
        let groupPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.D2A")!.appendingPathComponent("WCDB.db")
        database = Database(withFileURL: groupPath)
        self.createTables()
    }
    
    private func createTables() {
        do {
            try database.create(table: "Match", of: Match.self)
            try database.create(table: "UserProfile", of: UserProfile.self)
            try database.create(table: "RecentMatch", of: RecentMatch.self)
        } catch {
            fatalError("cannot create table")
        }
    }
    
    func deleteDatabase() {
        do {
            let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.D2A")!.appendingPathComponent("WCDB.db")
            try FileManager.default.removeItem(at: path)
        } catch {
            print("file remove error")
        }
    }
    
    // MARK: - CREATE
    func insertUserProfile(profile: UserProfile) {
        do {
            self.deleteUser(userid: "\(profile.id.description)")
            try database.insertOrReplace(objects: [profile], intoTable: "UserProfile")
        } catch {
            print("cannot insert this object")
        }
    }
    
    func insertMatch(match: Match) {
        do {
            try database.insertOrReplace(objects: [match], intoTable: "Match")
        } catch {
            print("cannot insert this object")
        }
    }
    
    // MARK: - READ
    func fetchRecentMatches(userid: String, offSet: Int = 0) -> [RecentMatch] {
        do {
            let matches: [RecentMatch] = try database.getObjects(fromTable: "RecentMatch",
                                                                 where: RecentMatch.Properties.playerId == Int(userid) ?? 0,
                                                                 orderBy: [RecentMatch.Properties.startTime.asOrder(by: .descending)],
                                                                 limit: 20,
                                                                 offset: offSet)
            return matches
        } catch {
            return []
        }
    }
    
    func fetchRecentMatch(userid: String, matchid: Int) -> RecentMatch? {
        do {
            let match: RecentMatch? = try database.getObject(fromTable: "RecentMatch",
                                                                 where: RecentMatch.Properties.playerId == Int(userid)! && RecentMatch.Properties.id == matchid)
            return match
        } catch {
            return nil
        }
    }
    
    func searchMatchOnDate(_ date: Date) -> [RecentMatch] {
        let start = date.startOfDay
        let end = date.endOfDay
        do {
            let matches: [RecentMatch] = try database.getObjects(fromTable: "RecentMatch",
                                                                 where: RecentMatch.Properties.startTime >= start.timeIntervalSince1970 && RecentMatch.Properties.startTime <= end.timeIntervalSince1970,
                                                                 orderBy: [RecentMatch.Properties.startTime.asOrder(by: .descending)])
            return matches
        } catch {
            return []
        }
    }
    
    func fetchUserProfile(userid: String) -> UserProfile? {
        do {
            let profile: UserProfile? = try database.getObject(fromTable: "UserProfile", where: UserProfile.Properties.id == Int(userid) ?? 0)
            return profile
        } catch {
            print("fetch User profile error")
            return nil
        }
    }
    
    func fetchUserProfile(userName: String) -> [UserProfile] {
        do {
            let profiles: [UserProfile] = try database.getObjects(fromTable: "UserProfile", where: UserProfile.Properties.personaname.like("%\(userName)%"))
            return profiles
        } catch {
            print("fetch Uesr profile error")
            return []
        }
    }
    
    func fetchMatch(matchid: String) -> Match? {
        do {
            let match: Match? = try database.getObject(fromTable: "Match", where: Match.Properties.id == Int(matchid)!)
            return match
        } catch {
            print("fetch match error")
            return nil
        }
    }
    
    // MARK: - UPDATE
    
    // MARK: - DELETE
    func deleteMatch(matchid: String) {
        do {
            try database.delete(fromTable: "Match", where: Match.Properties.id == Int(matchid)!)
        } catch {
            print("cannot delete match")
        }
    }
    
    func deleteRecentMatch(matchid: Int, userid: Int) {
        do {
            try database.delete(fromTable: "RecentMatch", where: RecentMatch.Properties.id == matchid && RecentMatch.Properties.playerId == userid)
        } catch {
            print("cannot delete match")
        }
    }
    
    func deleteUser(userid: String) {
        do {
            try database.delete(fromTable: "UserProfile", where: UserProfile.Properties.id == userid)
        } catch {
            print("cannot delete userProfile")
        }
    }
}

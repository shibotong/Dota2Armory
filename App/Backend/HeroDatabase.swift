//
//  HeroDatabase.swift
//  App
//
//  Created by Shibo Tong on 11/8/21.
//

import Foundation
import SwiftUI

class HeroDatabase: ObservableObject {
    @Published var loading = false
    @Published var error = false
    var heroes = [String: Hero]()
    var gameModes = [String: GameMode]()
    var lobbyTypes = [String: LobbyType]()
    var regions = [String: String]()
    var items = [String: Item]()
    var itemIDTable = [String: String]()
    var abilityIDTable = [String: String]()
    var abilities = [String: Ability]()
    var heroAbilities = [String: HeroAbility]()
    var talentData = [String: String]()
    
    static var shared = HeroDatabase()
    
    let url = "https://api.opendota.com/api/herostats"
    
    init() {
        self.loading = true
        self.gameModes = loadGameModes()
        self.regions = loadRegion()!
        self.lobbyTypes = loadLobby()!
        
        
        Task {
            async let idTable = loadItemIDs()
            async let items = loadItems()
            async let heroes = loadHeroes()
            async let abilityIDTable = loadAbilityID()
            async let abilities = loadAbilities()
            async let heroAbilities = loadHeroAbilities()
            async let talentData = loadTalentData()
            
            self.itemIDTable = await idTable
            self.items = await items
            self.heroes = await heroes
            self.abilityIDTable = await abilityIDTable
            self.abilities = await abilities
            self.heroAbilities = await heroAbilities
            self.talentData = await talentData
            
            DispatchQueue.main.async {
                if self.abilities.count == 0 {
                    self.error = true
                } else {
                    self.loading = false
                }
            }
        }
    }

    func fetchHeroWithID(id: Int) -> Hero? {
        return heroes["\(id)"]
    }
    
    func fetchGameMode(id: Int) -> GameMode {
        return gameModes["\(id)"]!
    }
    
    func fetchItem(id: Int) -> Item? {
        if id == 0 {
            return nil
        } else {
            guard let itemString = itemIDTable["\(id)"] else {
                return nil
            }
            guard let item = items[itemString] else {
                return nil
            }
            return item
        }
    }
    
    func fetchRegion(id: String) -> String {
        guard let region = self.regions[id] else {
            return "Unknown"
        }
        return region
    }
    
    func fetchLobby(id: Int) -> LobbyType {
        return lobbyTypes["\(id)"] ?? LobbyType(id: id, name: "Unknown Lobby")
    }
    
    func fetchAbilityName(id: Int) -> String? {
        guard let abilityName = self.abilityIDTable["\(id)"] else {
            return nil
        }
        return abilityName
    }
    
    func fetchAbility(name: String) -> Ability? {
        return abilities[name]
    }
    
    func fetchHeroAbility(name: String) -> HeroAbility? {
        return heroAbilities[name]
    }
    
    func fetchAllHeroes() -> [Hero] {
        var sortedHeroes = [Hero]()
        for i in 1..<150 {
            if let hero = heroes["\(i)"] {
                sortedHeroes.append(hero)
            }
        }
        
        sortedHeroes.sort { hero1, hero2 in
            return hero1.localizedName < hero2.localizedName
        }
        return sortedHeroes
    }
}

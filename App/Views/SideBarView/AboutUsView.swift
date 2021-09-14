//
//  AboutUsView.swift
//  App
//
//  Created by Shibo Tong on 22/8/21.
//

import SwiftUI

struct AboutUsView: View {
    @EnvironmentObject var env: DotaEnvironment
    private var versionNumber: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Error", comment: "")
    }
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Our App").font(.custom(fontString, size: 15))) {
                makeRow(image: "chevron.left.slash.chevron.right", text: "Source Code / Report an Issue", link: URL(string: "https://github.com/shibotong/Dota2Armory"))
                makeRow(image: "star", text: "Rate the app on App Store", link: URL(string: ""))
                makeRow(image: "lock", text: "Privacy Policy", link: URL(string: ""))
                makeRow(image: "person", text: "Term of Use", link: URL(string: ""))
                makeDetailRow(image: "app.badge", text: "App Version", detail: versionNumber)
                makeDetailRow(image: "gamecontroller", text: "Game Patch", detail: gameVersion)
                }
                Section(header: Text("Thanks To").font(.custom(fontString, size: 15))) {
                    makeRow(image: "heart.fill", text: "OpenDotaAPI", link: URL(string: "https://www.opendota.com"))
                    makeRow(image: "heart.fill", text: "Our Loved Dota2", link: URL(string: "https://www.dota2.com/home"))
                }
            }
            .navigationBarItems(leading: Button(action: {
                env.aboutUs.toggle()
            }) {
                Image(systemName: "xmark.circle.fill")
            })
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    private func makeRow(image: String,
                         text: LocalizedStringKey,
                         link: URL? = nil) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(.primaryDota)
                .frame(width: 30)
            Group {
                if let link = link {
                    Link(text, destination: link)
                        .foregroundColor(Color(.label))
                } else {
                    Text(text)
                }
            }
            .font(.custom(fontString, size: 18))
            Spacer()
            Image(systemName: "chevron.right").imageScale(.medium)
        }
    }
    
    private func makeDetailRow(image: String, text: LocalizedStringKey, detail: String) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(.primaryDota)
                .frame(width: 30)
            Text(text)
                .font(.custom(fontString, size: 18))
            Spacer()
            Text(detail)
                .foregroundColor(.gray)
                .font(.callout)
        }
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {

            AboutUsView()
        
        
    }
}
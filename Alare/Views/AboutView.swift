//
//  AboutView.swift
//  Alare
//
//  Created by Cizzuk on 2026/02/22.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section("Alare") {
                HStack {
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    let currentBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
                    Label("Version", systemImage: "info.circle")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(currentVersion ?? "Unknown") (\(currentBuild ?? "Unknown"))")
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label("Developer", systemImage: "hammer")
                        .foregroundStyle(.primary)
                    Spacer()
                    Link(destination:URL(string: "https://cizzuk.net/")!, label: {
                        Text("Cizzuk")
                    })
                }
                Link(destination:URL(string: "https://github.com/Cizzuk/Alare")!, label: {
                    Label("Source", systemImage: "ladybug")
                })
                Link(destination:URL(string: "https://i.cizzuk.net/privacy/")!, label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                })
            }
            
            Section {} header: {
                Text("License")
            } footer: {
                Text("MIT License\n\nCopyright (c) 2026 Cizzuk\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files (the \"Software\"), to deal\nin the Software without restriction, including without limitation the rights\nto use, copy, modify, merge, publish, distribute, sublicense, and/or sell\ncopies of the Software, and to permit persons to whom the Software is\nfurnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all\ncopies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\nIMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\nFITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\nAUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\nLIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\nOUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\nSOFTWARE.")
                    .environment(\.layoutDirection, .leftToRight)
                    .textSelection(.enabled)
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

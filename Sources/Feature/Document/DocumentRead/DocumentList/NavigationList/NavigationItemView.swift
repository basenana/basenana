//
//  NavigationItemView.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import os
import SwiftUI
import Foundation
import SwiftUIMasonry
import Domain


struct NavigationItemView: View {
    private let section: String
    @State private var doc: DocumentItem
    private let viewModel: DocumentListViewModel

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: NavigationItemView.self)
        )

    init(section: String, doc: DocumentItem, viewModel: DocumentListViewModel ) {
        self.section = section
        self._doc = State(initialValue: doc)
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading){

                HStack(alignment: .top) {
                    Text("\(self.groupName.prefix(25))")
                        .foregroundColor(Color.gray)

                    Spacer()

                    Text(self.docTime)
                        .font(.caption)
                        .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )
                }

                Text(self.docTitle)
                    .font(.headline)
                    .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )

            }

            HStack{
                if viewModel.showTextPreview {
                    Text("\(doc.info.documentAbstract?.prefix(100) ?? "")")
                        .font(.body)
                        .foregroundColor(Color.gray)
                        .frame(idealWidth: 200,  maxWidth: .infinity, idealHeight: 40, maxHeight: 50, alignment: .leading)
                }

                if viewModel.showImagePreview {
                    NavigationItemBannerView(bannerURL: doc.info.documentHeaderImage ?? "")
                        .frame(width: 50, height: 50)
                }
            }
            Text(self.docURL)
                .foregroundColor(Color.gray)
        }
        .padding(.vertical, 3)
        .contextMenu {
            DocumentMenuView(section: section, document: $doc, parentURI: doc.info.parentURI, viewModel: viewModel)
        }
    }

    var docTitle: String {
        return doc.info.documentTitle ?? doc.info.name
    }

    var docTime: String {
        var datetime = doc.info.createdAt

        if let publishAt = doc.info.documentPublishAt {
            datetime = publishAt
        }

        return dateFormatter.string(from: datetime)
    }

    var docURL: String {
        if let urlStr = doc.info.documentURL, !urlStr.isEmpty {
            return URL(string: urlStr)?.host() ?? ""
        }
        return ""
    }

    var groupName: String {
        if let siteName = doc.info.documentSiteName {
            return siteName
        }
        let parent = doc.info.parentName
        if parent.isEmpty || parent.hasPrefix(".") {
            return ""
        }
        return parent
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
}


struct NavigationItemBannerView: View{
    var bannerURL: String

    var body: some View {
        if let safeUrl = URL(string: bannerURL) {
            GeometryReader { geometry in
                AsyncImage(url: safeUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .padding(.vertical, 5)
                        .clipped()
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(10)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundStyle(.gray)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

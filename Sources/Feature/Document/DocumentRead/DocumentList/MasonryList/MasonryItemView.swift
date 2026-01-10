//
//  MasonryItemView.swift
//  Document
//
//  Created by Hypo on 2024/12/4.
//

import os
import SwiftUI
import Domain
import Styleguide


struct MasonryItemView: View {
    private let section: String
    @State private var doc: DocumentItem
    private let viewModel: DocumentListViewModel

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: MasonryItemView.self)
        )

    init(section: String, doc: DocumentItem, viewModel: DocumentListViewModel ) {
        self.section = section
        self._doc = State(initialValue: doc)
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(groupName.prefix(25))")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
                Spacer()

                Text(docTime)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.gray)
            }
            Spacer(minLength: 20)

            Text(docTitle)
                .font(.title2)
                .multilineTextAlignment(.leading)
                .foregroundColor(doc.keepLowProfile ? Color.gray : Color.primary  )

            Spacer(minLength: 10)

            if viewModel.showImagePreview {
                MasonryItemBannerView(bannerURL: self.doc.info.documentHeaderImage ?? "")
                Spacer(minLength: 20)
            }

            if viewModel.showTextPreview {
                Text("\(subContent)... ")
                    .font(.body)
                    .lineSpacing(2)
                    .foregroundColor(Color.CardFrontground)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 10)
            Text(docURL)
                .font(.caption2)
                .fontWeight(.light)
                .foregroundColor(Color.gray)

        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(Color.CardBackground)
        .cornerRadius(5)
        .contextMenu {
            DocumentMenuView(section: section, document: $doc, parentURI: doc.info.parentURI, viewModel: viewModel)
        }
        .onAppear {
            Self.logger.debug("MasonryItemView onAppear: uri=\(self.doc.uri)")
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

    var subContent: String {
        if viewModel.showImagePreview && doc.info.documentHeaderImage != nil {
            return String(doc.info.documentAbstract?.prefix(200) ?? "")
        }
        return String(doc.info.documentAbstract ?? "")
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
}


struct MasonryItemBannerView: View{
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
                        .padding(50)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundStyle(.gray)
                }
            }
            .aspectRatio(3/2, contentMode: .fit)
        }
    }
}

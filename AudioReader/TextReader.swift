//
//  TextReader.swift
//  AudioReader
//
//  Created by alexanderlin-com on 3/20/25.
//

import SwiftUI
import PDFKit

struct TextReader: View {
    let fileURL: URL

    var body: some View {
        PDFKitView(url: fileURL)
            .navigationTitle(fileURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(url: url)
    }
}

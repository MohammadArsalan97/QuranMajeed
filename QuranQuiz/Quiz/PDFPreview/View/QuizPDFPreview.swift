//
//  QuizPDFPreview.swift
//  QuranQuiz
//
//  Created by Takasur Azeem on 31/07/2023.
//

import SwiftUI
import PDFKit

struct QuizPDFPreview: View {
    var documentData: Data?
    var body: some View {
        VStack {
            // Using the PDFKitView and passing the previously created pdfURL
            if let documentData {
                PDFKitView(documentData: documentData)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuizPDFPreview(
                documentData: PDFGenerator(
                    title: "Quiz",
                    verses: []
                )
                .generateQuiz()
            )
        }
    }
}

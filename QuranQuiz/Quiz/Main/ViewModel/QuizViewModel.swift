//
//  QuizViewModel.swift
//  Quran
//
//  Created by Takasur Azeem on 30/07/2023.
//  Copyright © 2023 Takasur Azeem. All rights reserved.
//

import Foundation
import PDFKit

extension QuizView {
    class ViewModel: ObservableObject {
        
        init() {
            selectedAyahNumber = 1
            surahs = []
            selectedVerse = Verse(id: 1, text: "")
            selectedSurah = Bundle.main.decode(SurahElement.self, from: "Al-Fatihah.json")
            surahs = Bundle.main.decode(Surahs.self, from: "Quran.json")
            selectedVerse = selectedSurah.verses.first!
            setTextForSelectedAya()
        }
        
        func setTextForSelectedAya() {
            for surah in surahs {
                if surah.id == selectedSurah.id {
                    for verse in selectedSurah.verses {
                        if verse.id == selectedAyahNumber {
                            selectedVerse = verse
                        }
                    }
                }
            }
        }
        
        func addSelectedVerseToQuiz() {
            if selectedVerses.contains(where: { verse in
                (verse.surahId == selectedSurah.id && verse.ayahId == selectedVerse.id) || verse.text == selectedVerse.text
            }) == false {
                let verse = QuizVerse(
                    surahId: selectedSurah.id,
                    ayahId: selectedVerse.id,
                    text: selectedVerse.text
                )
                print(verse)
                selectedVerses.append(verse)
            }
        }

        func delete(at offsets: IndexSet) {
            selectedVerses.remove(atOffsets: offsets)
        }
        
        func generatePDF() -> URL? {
            _ = PDFCreator(title: "Test", verses: selectedVerses)
            
            
            return nil
        }
        
        
        @Published var selectedAyahNumber: Int
        @Published var selectedSurah: SurahElement
        @Published var surahs: Surahs
        @Published private(set) var selectedVerse: Verse
        
        @Published private(set) var selectedVerses: [QuizVerse] = []
        
        @Published var showingPDFPreview = false
    }
}
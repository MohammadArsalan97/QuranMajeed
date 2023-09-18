//
//  AppDependencyContainer.swift
//  QuranMajeed
//
//  Created by Takasur Azeem on 14/09/2023.
//

import Foundation

class AppDependencyContainer {
    private init() {
        self.theQuranProvider = MainQuranProvider()
    }
    
    static let shared = AppDependencyContainer()
    
    lazy var theQuranDependencyContainer: QuranDataDependencyContainer = {
        QuranDataDependencyContainer(providerForQuran: theQuranProvider)
    }()
    
    private let theQuranProvider: QuranProvider
}

import Analytics
import Logging
import VLogging

struct LoggingAnalyticsLibrary: AnalyticsLibrary {
    func logEvent(_ name: String, value: String) {
        logger.info("[Analytics] \(name)=\(value)")
    }
}


import Analytics
import AppDependencies
import BatchDownloader
import CoreDataModel
import CoreDataPersistence
import LastPagePersistence
import NotePersistence
import PageBookmarkPersistence
import ReadingService

/// Hosts singleton dependencies
class Container: AppDependencies {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = Container()

    let readingResources = ReadingResourcesService()
    let analytics: AnalyticsLibrary = LoggingAnalyticsLibrary()

    private(set) lazy var lastPagePersistence: LastPagePersistence = CoreDataLastPagePersistence(stack: coreDataStack)
    private(set) lazy var pageBookmarkPersistence: PageBookmarkPersistence = CoreDataPageBookmarkPersistence(stack: coreDataStack)
    private(set) lazy var notePersistence: NotePersistence = CoreDataNotePersistence(stack: coreDataStack)

    private(set) lazy var downloadManager: DownloadManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadsBackgroundIdentifier")
        configuration.timeoutIntervalForRequest = 60 * 5 // 5 minutes
        return DownloadManager(
            maxSimultaneousDownloads: 600,
            configuration: configuration,
            downloadsURL: Constant.databasesURL.appendingPathComponent("downloads.db", isDirectory: false)
        )
    }()

    var databasesURL: URL { Constant.databasesURL }
    var wordsDatabase: URL { Constant.wordsDatabase }
    var filesAppHost: URL { Constant.filesAppHost }
    var appHost: URL { Constant.appHost }

    var supportsCloudKit: Bool { false }

    // MARK: Private

    private lazy var coreDataStack: CoreDataStack = {
        let stack = CoreDataStack(name: "Quran", modelUrl: CoreDataModelResources.quranModel) {
            let lastPage = CoreDataLastPageUniquifier()
            let pageBookmark = CoreDataPageBookmarkUniquifier()
            let note = CoreDataNoteUniquifier()
            return [lastPage, pageBookmark, note]
        }
        return stack
    }()
}

private enum Constant {
    static let wordsDatabase = Bundle.main
        .url(forResource: "words", withExtension: "db")!

    static let appHost: URL = URL(validURL: "https://quran.app/")

    static let filesAppHost: URL = URL(validURL: "https://files.quran.app/")

    static let databasesURL = FileManager.documentsURL
        .appendingPathComponent("databases", isDirectory: true)
}

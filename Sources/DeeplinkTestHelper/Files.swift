import XCTest
import UIKit

internal enum DeeplinksData {
    case url(URL)
    case html(String)
}

internal final class Files {
    private enum Const {
        static let longPressDuration = 1.3
        static let filesAppId = "com.apple.DocumentsApp"
        static let htmlPasteboardType = "public.html"
        static let fileNameIdentifierFormat = "%@, html"
        static let folderIdentifierFormat = "%@, Folder"

        enum Label {
            static let moreButton = "More"

            // TODO: Localization
            static let browseButton = "Browse"
            static let pasteButton = "Paste"
            static let deleteButton = "Delete"
            static let doneButton = "Done"
            static let openButton = "Open"

            static let onMyPhone = "On My iPhone"
            static let newFolder = "New Folder"
        }

        enum ID {
            static let newFolder = "Folder"
            static let renameField = "DOC.inlineRenameField"
        }
    }

    private var doneButton: XCUIElement {
        app.navigationBars.buttons[Const.Label.doneButton].firstMatch
    }

    private var moreButton: XCUIElement {
        app.navigationBars.buttons[Const.Label.moreButton].firstMatch
    }

    private var newFolderButton: XCUIElement {
        app.buttons[Const.Label.newFolder].firstMatch
    }

    private var deleteButton: XCUIElement {
        app.buttons[Const.Label.deleteButton].firstMatch
    }

    let app = XCUIApplication(bundleIdentifier: Const.filesAppId)
    private let data: DeeplinksData

    init(deeplinksData: DeeplinksData) {
        data = deeplinksData
    }

    func restart() {
        app.terminate()
        app.launch()
        XCTAssertTrue(app.waitForExistence())
    }

    func alreadyOpened(fileName: String) -> Bool {
        doneButton.exists && app.navigationBars[fileName].exists
    }

    func closeCurrentFileIfNeeded() {
        if doneButton.exists {
            doneButton.tap()
        }
    }

    func openLink(with name: String) {
        let link = app.staticTexts[name].firstMatch
        link.tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence())
        alert.buttons[Const.Label.openButton].tap()
    }

    func openDeeplinksFolderIfNeeded(with folderName: String?) {
        guard let folderName else {
            return openOnMyIphone()
        }
        guard !app.navigationBars.staticTexts[folderName].exists else { return }
        openOnMyIphone()

        let folderIdentifier = String(format: Const.folderIdentifierFormat, folderName)
        let folder = app.collectionViews.firstMatch.cells[folderIdentifier].firstMatch
        if !folder.exists {
            createAndOpenFolder(with: folderName)
        }
        folder.tap()
    }

    func openFile(with fileName: String) {
        let fileNameIdentifier = String(format: Const.fileNameIdentifierFormat, fileName)
        let fileElement = app.collectionViews.firstMatch.cells[fileNameIdentifier].firstMatch
        if !fileElement.exists {
            saveHTMLToFilesIfNeeded(fileName: fileName)
            guard fileElement.waitForExistence() else {
                return XCTFail("Can't paste html content")
            }
        }
        fileElement.tap()
        XCTAssertTrue(app.navigationBars[fileName].waitForExistence())
    }

    func remove(name: String, isFolder: Bool) {
        closeCurrentFileIfNeeded()
        openOnMyIphone()
        let identifier = if isFolder {
            String(format: Const.folderIdentifierFormat, name)
        } else {
            String(format: Const.fileNameIdentifierFormat, name)
        }
        let element = app.collectionViews.firstMatch.cells[identifier].firstMatch
        guard element.exists else { return }
        element.press(forDuration: Const.longPressDuration)
        XCTAssertTrue(deleteButton.waitForExistence())
        deleteButton.tap()
    }

    private func saveHTMLToFilesIfNeeded(fileName: String) {
        configurePasteboard(with: fileName)

        app.collectionViews.firstMatch
            .press(forDuration: Const.longPressDuration)
        let pasteButton = app.buttons[Const.Label.pasteButton].firstMatch
        XCTAssertTrue(pasteButton.waitForExistence())
        pasteButton.tap()
    }

    private func configurePasteboard(with fileName: String) {
        let provider = NSItemProvider()
        switch data {
        case .html(let string):
            guard let htmlData = string.data(using: .utf8) else { return }
            provider.registerDataRepresentation(forTypeIdentifier: Const.htmlPasteboardType, visibility: .all) { block in
                block(htmlData, nil)
                return nil
            }
        case .url(let fileURL):
            provider.registerFileRepresentation(forTypeIdentifier: Const.htmlPasteboardType, visibility: .all) { block in
                block(fileURL, false, nil)
                return nil
            }
        }
        provider.suggestedName = fileName
        UIPasteboard.general.setItemProviders([provider], localOnly: true, expirationDate: nil)
    }

    private func createAndOpenFolder(with folderName: String) {
        moreButton.tap()
        XCTAssertTrue(newFolderButton.waitForExistence())
        newFolderButton.tap()
        let field = if app.textViews[Const.ID.renameField].exists {
            app.textViews[Const.ID.renameField]
        } else {
            app.textViews.firstMatch
        }
        field.typeText(folderName)

        app.cells[Const.ID.newFolder].images.firstMatch.tap()
    }

    private func openOnMyIphone() {
        if !app.navigationBars.staticTexts[Const.Label.onMyPhone].exists {
            app.tabBars.buttons[Const.Label.browseButton].doubleTap()
            app.cells.staticTexts[Const.Label.onMyPhone].tap()
            XCTAssertTrue(app.navigationBars.staticTexts[Const.Label.onMyPhone].waitForExistence())
        }
    }
}

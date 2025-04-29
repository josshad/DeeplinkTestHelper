import XCTest

public final class DeeplinkTestHelper {
    private let fileManager: FileManager = .default

    private let fileName: String
    private let folderName: String?
    private let files: Files

    public init?(
        fileURL: URL,
        fileName: String = "Deeplinks",
        folderName: String? = nil
    ) {
        guard fileURL.isFileURL else { return nil }

        self.files = Files(deeplinksData: .url(fileURL))
        self.fileName = fileName
        self.folderName = folderName
    }

    public init(
        deeplinksHTML: String,
        fileName: String = "Deeplinks",
        folderName: String? = nil
    ) {
        self.files = Files(deeplinksData: .html(deeplinksHTML))
        self.fileName = fileName
        self.folderName = folderName
    }

    public func openDeeplink(withName name: String) {
        files.restart()

        if !files.alreadyOpened(fileName: fileName) {
            files.closeCurrentFileIfNeeded()
            files.openDeeplinksFolderIfNeeded(with: folderName)
            files.openFile(with: fileName)
        }

        files.openLink(with: name)
    }

    public func removeElement(name: String, isFolder: Bool) {
        files.remove(name: name, isFolder: isFolder)
    }
}

internal extension XCUIElement {
    func waitForExistence() -> Bool {
        waitForExistence(timeout: 5)
    }
}

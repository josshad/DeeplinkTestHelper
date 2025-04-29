# Description

This helper drop in solution allows to test deeplinks with "user emulated" behaviour. It's more quick and stable than soulution with typing of this deeplinks.
And it's emulate users behaviour, comparing to the `XCUISystem.open(_:)`/`XCUIApplication.open(_:)`

# Usage

Initialise helper tool via html string or path to html file. Optianally configure file and folder name.

## HTML string
```swift
let deeplinksHTML = """
    <html>
        <body>
            <h1>
                <a href='testdeeplink://showSettings'>Show settings</a>
                <a href='testdeeplink://showVersion'>Show version</a>
                <a href='https://josshad.glatop.com/app/showSettings'>Universal</a>
            </h1>
        </body>
    </html>
"""

let helper = DeeplinkTestHelper(deeplinksHTML: deeplinksHTML, fileName: "_Deeplinks_")
```

## File path
```swift
guard let url = Bundle(for: type(of: self)).url(forResource: "testDeeplinks", withExtension: "html") else {
    return XCTFail("Can't find html file")
}

guard let helper = DeeplinkTestHelper(fileURL: url, fileName: "_Deeplinks_") else {
    return XCTFail("Can't initialize helper")
}
```

After initialisation you may call `public func openDeeplink(withName name: String)` to open deeplink by it's name in html file

```swift
helper.openDeeplink(withName: "Show version")
```

# Installation

## Manual
Copy `DeeplinkTestHelper.swift` and `Files.swift` to your UI tests target. 

## SPM
Under construction

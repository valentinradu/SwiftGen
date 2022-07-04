//
// SwiftGenKit
// Copyright © 2020 SwiftGen
// MIT Licence
//

import AppKit.NSFont
import Foundation
import PathKit

public enum Fonts {
  public final class Parser: SwiftGenKit.Parser {
    var entries: [String: Set<Font>] = [:]
    private let options: ParserOptionValues
    public var warningHandler: Parser.MessageHandler?

    public init(options: [String: Any] = [:], warningHandler: Parser.MessageHandler? = nil) throws {
      self.options = try ParserOptionValues(options: options, available: Parser.allOptions)
      self.warningHandler = warningHandler
    }

    public static let defaultFilter = filterRegex(forExtensions: ["otf", "ttc", "ttf"])

    public func parse(path: Path, relativeTo parent: Path) throws {
      guard let values = try? path.url.resourceValues(forKeys: [.typeIdentifierKey]) {
          warningHandler?("Unable to read path for file \(path)", #file, #line)
      }
        
      guard let uti = values.typeIdentifier else {
        warningHandler?("Unable to determine the Universal Type Identifier for file \(path)", #file, #line)
        return
      }
      
      guard UTTypeConformsTo(uti as CFString, kUTTypeFont) else {
        warningHandler?("File is not a known font type: \(path)", #file, #line)
        return
      }

      let fonts = CTFont.parse(file: path, relativeTo: parent)
      fonts.forEach { addFont($0) }
    }

    private func addFont(_ font: Font) {
      let familyName = font.familyName
      entries[familyName, default: []].insert(font)
    }
  }
}

//
//  SwiftuiSnapshotTests.swift
//  SwiftuiSnapshotTests
//
//  Created by Mohammad Zulqurnain on 09/06/2024.
//

import SwiftUI
@testable import SwiftuiSnapshot
import UIKit
import XCTest

class ContentViewSnapshotTests: XCTestCase {
    func testMyViewSnapshot() throws {
        XCTAssertTrue(try SnapshotTesting.isTestPassed(view: ContentView(), mseTolerance: 0.02), "Snapshot test for \(Self.self) failed")
    }
}

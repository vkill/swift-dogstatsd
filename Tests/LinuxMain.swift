import XCTest

import DatadogStatsdTests

var tests = [XCTestCaseEntry]()
tests += DatadogStatsdTests.allTests()
XCTMain(tests)
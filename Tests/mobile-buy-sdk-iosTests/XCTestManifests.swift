import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(mobile_buy_sdk_iosTests.allTests),
    ]
}
#endif

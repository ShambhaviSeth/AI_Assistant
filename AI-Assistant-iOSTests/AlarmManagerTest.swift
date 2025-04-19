import XCTest
@testable import AI_Assistant_iOS

final class AlarmManagerTests: XCTestCase {
    var alarmManager: AlarmManager!
    
    override func setUp() {
        super.setUp()
        alarmManager = AlarmManager()
    }
    
    func testParseTime_24Hour() {
        let date = alarmManager.test_parseTime("07:30")
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date!)
        XCTAssertEqual(comps.hour, 7)
        XCTAssertEqual(comps.minute, 30)
    }
    
    func testParseTime_12HourPM() {
        let date = alarmManager.test_parseTime("10pm")
        let comps = Calendar.current.dateComponents([.hour], from: date!)
        XCTAssertEqual(comps.hour, 22)
    }
    
    func testParseTime_12HourWithMinutes() {
        let date = alarmManager.test_parseTime("9:45AM")
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date!)
        XCTAssertEqual(comps.hour, 9)
        XCTAssertEqual(comps.minute, 45)
    }
    
    func testParseTime_invalid() {
        XCTAssertNil(alarmManager.test_parseTime("not a time"))
    }
}

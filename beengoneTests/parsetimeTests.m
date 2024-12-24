- (void)testParseTimeString {
    unsigned long result;

    result = parse_time_string("1d");
    XCTAssertEqual(result, 86400, @"1 day should be 86400 seconds");

    result = parse_time_string("1h");
    XCTAssertEqual(result, 3600, @"1 hour should be 3600 seconds");

    result = parse_time_string("1m");
    XCTAssertEqual(result, 60, @"1 minute should be 60 seconds");

    result = parse_time_string("1s");
    XCTAssertEqual(result, 1, @"1 second should be 1 second");

    result = parse_time_string("1d 1h 1m 1s");
    XCTAssertEqual(result, 90061, @"1 day, 1 hour, 1 minute, and 1 second should be 90061 seconds");

    result = parse_time_string("2d 3h 4m 5s");
    XCTAssertEqual(result, 183845, @"2 days, 3 hours, 4 minutes, and 5 seconds should be 183845 seconds");

    result = parse_time_string("2d3h4m5s");
    XCTAssertEqual(result, 183845, @"2 days, 3 hours, 4 minutes, and 5 seconds should be 183845 seconds");

    result = parse_time_string("10m 30s");
    XCTAssertEqual(result, 630, @"10 minutes and 30 seconds should be 630 seconds");

    result = parse_time_string("5h 45m");
    XCTAssertEqual(result, 20700, @"5 hours and 45 minutes should be 20700 seconds");

    result = parse_time_string("300");
    XCTAssertEqual(result, 20700, @"A raw number should be treated as seconds");

    result = parse_time_string("invalid");
    XCTAssertEqual(result, 0, @"Invalid input should return 0 seconds");
}

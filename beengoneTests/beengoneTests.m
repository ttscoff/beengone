//
//  test_main.m
//  beengoneTests
//
//  Created by Brett Terpstra on 12/23/24.
//

#import <XCTest/XCTest.h>
#import "main.m"

@interface beengoneTests : XCTestCase

@end

@implementation beengoneTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIdleTimeInitialization {
    IdleTime *idleTime = [[IdleTime alloc] init];
    XCTAssertNotNil(idleTime, @"IdleTime instance should not be nil");
}

- (void)testIdleTimeDealloc {
    IdleTime *idleTime = [[IdleTime alloc] init];
    XCTAssertNoThrow([idleTime dealloc], @"IdleTime dealloc should not throw an exception");
}

- (void)testTimeIdle {
    IdleTime *idleTime = [[IdleTime alloc] init];
    XCTAssertNoThrow([idleTime timeIdle], @"timeIdle method should not throw an exception");
    XCTAssertTrue([idleTime timeIdle] > 0, @"timeIdle should return a positive value");
}

- (void)testSecondsIdle {
    IdleTime *idleTime = [[IdleTime alloc] init];
    XCTAssertNoThrow([idleTime secondsIdle], @"secondsIdle method should not throw an exception");
    XCTAssertTrue([idleTime secondsIdle] > 0, @"secondsIdle should return a positive value");
}

- (void)testMainFunction {
    int argc = 1;
    char *argv[] = {"beengone"};
    XCTAssertEqual(main(argc, argv), EXIT_SUCCESS, @"main function should return EXIT_SUCCESS");
}

- (void)testMainFunctionWithNoNewlineOption {
    int argc = 2;
    char *argv[] = {"beengone", "--no-newline"};
    XCTAssertEqual(main(argc, argv), EXIT_SUCCESS, @"main function should return EXIT_SUCCESS with --no-newline option");
}

- (void)testMainFunctionWithMinimumOption {
    int argc = 3;
    char *argv[] = {"beengone", "--minimum", "10"};
    int result = main(argc, argv);
    XCTAssertTrue(result == EXIT_SUCCESS || result == EXIT_FAILURE, @"main function should return EXIT_SUCCESS or EXIT_FAILURE with --minimum option");
}

@end

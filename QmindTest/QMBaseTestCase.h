/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <QTestKit/QTestKit.h>

#define hasSize(number) hasCount(equalToInt(number))
#define consistsOf(...) contains(__VA_ARGS__, nil)
#define consistsOfInAnyOrder(...) containsInAnyOrder(__VA_ARGS__, nil)

#define FAIL XCTFail(@"yet to be implemented")

@interface QMBaseTestCase : XCTestCase @end


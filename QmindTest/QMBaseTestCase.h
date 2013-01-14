#import <SenTestingKit/SenTestingKit.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <QTestKit/QTestKit.h>

#define hasSize(number) hasCount(equalToInt(number))
#define consistsOf(...) contains(__VA_ARGS__, nil)
#define consistsOfInAnyOrder(...) containsInAnyOrder(__VA_ARGS__, nil)

#define FAIL STFail(@"yet to be implemented")

@interface QMBaseTestCase : SenTestCase @end


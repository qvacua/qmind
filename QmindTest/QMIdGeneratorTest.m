#import "QMBaseTestCase.h"
#import "QMIdGenerator.h"

@interface QMIdGeneratorTest : QMBaseTestCase
@end

@implementation QMIdGeneratorTest {
    QMIdGenerator *generator;
}

- (void)setUp {
    generator = [[QMIdGenerator alloc] init];
}

- (void)testNotNull {
    NSString *nodeId = [generator nodeId];

    assertThat(nodeId, startsWith(@"ID_"));
    assertThat(@(nodeId.length), greaterThan(@3));
}

@end

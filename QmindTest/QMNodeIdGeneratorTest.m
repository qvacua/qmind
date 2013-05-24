#import "QMBaseTestCase.h"
#import "QMNodeIdGenerator.h"

@interface QMNodeIdGeneratorTest : QMBaseTestCase
@end

@implementation QMNodeIdGeneratorTest {
    QMNodeIdGenerator *generator;
}

- (void)setUp {
    generator = [[QMNodeIdGenerator alloc] init];
}

- (void)testNotNull {
    assertThat([generator nodeId], isNot(nilValue()));
}

@end

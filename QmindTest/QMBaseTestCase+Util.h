/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMCell.h"

static int const NUMBER_OF_CHILD = 10;
static int const NUMBER_OF_LEFT_CHILD = 10;
static int const NUMBER_OF_GRAND_CHILD = 10;
static int const NUMBER_OF_LEFT_GRAND_CHILD = 10;

@class QMRootNode;
@class QMRootCell;
@class QMMindmapView;
@class QMDocument;
@class QMNode;

@interface QMBaseTestCase (Util)

- (QMRootNode *)rootNodeForTest;
- (QMRootCell *)rootCellForTestWithView:(QMMindmapView *)view;
- (NSURL *)urlForResource:(NSString *)fileNameWoExt extension:(NSString *)extension;
- (NSFileWrapper *)fileWrapperForResource:(NSString *)fileNameWoExt extension:(NSString *)extension;

@end

@interface QMCell (Testing)
- (void)setFamilySize:(NSSize)aSize;
@end

// terminate the coordinates with n < 0
OBJC_EXPORT id item_coord(id root, ...);
OBJC_EXPORT id left_item_coord(id root, ...);

#define CELL(...) (QMCell *)item_coord(rootCell, __VA_ARGS__, -1)
#define LCELL(...) (QMCell *)left_item_coord(rootCell, __VA_ARGS__, -1)

#define NODE(...) (QMNode *)item_coord(rootNode, __VA_ARGS__, -1)
#define LNODE(...) (QMNode *)left_item_coord(rootNode, __VA_ARGS__, -1)

OBJC_EXPORT void wireRootNodeOfDoc(QMDocument *doc, QMRootNode *rootNode);

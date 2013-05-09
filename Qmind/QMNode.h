/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>
#import <Qkit/Qkit.h>

static NSString * const qNodeTextAttributeKey = @"TEXT";
static NSString * const qNodeFoldedAttributeKey = @"FOLDED";
static NSString * const qNodePositionAttributeKey = @"POSITION";

static NSString * const qNodeParentArchiveKey = @"parent";
static NSString * const qNodeChildrenArchiveKey = @"children";
static NSString * const qNodeLeftChildrenArchiveKey = @"leftChildren";
static NSString * const qNodeAttributesArchiveKey = @"attributes";
static NSString * const qNodeUnsupportedChildrenArchiveKey = @"unsupportedChildren";
static NSString * const qNodeFontArchiveKey = @"font";
static NSString * const qNodeIconsArchiveKey = @"icons";

static NSString * const qNodeUti = @"com.qvacua.mindmap.node";

static NSString * const qNodeStringValueKey = @"stringValue";
static NSString * const qNodeChildrenKey = @"children";
static NSString * const qNodeFontKey = @"font";
static NSString * const qNodeIconsKey = @"icons";
static NSString * const qNodeFoldingKey = @"folded";

/**
* Model representation of a Mindmap's node.
*
* @implements NSCoding, NSPasteboardReading, NSPasteboardWriting, NSKeyValueCoding, NSKeyValueObserving
*/
@interface QMNode : QObservedObject <NSCopying, NSCoding, NSPasteboardWriting, NSPasteboardReading>

@property (weak) NSUndoManager *undoManager;

@property (getter=isFolded) BOOL folded;
@property (readonly, getter=isLeaf) BOOL leaf;

@property (getter=isCreatedNewly) BOOL createdNewly;

/**
* plain text value of the node.
*/
@property NSString *stringValue;

/**
* NO for QMNode. YES for QMRootNode.
*/
@property (readonly, getter=isRoot) BOOL root;

/**
* The parent of the node. If this is nil, the node is most probably a detached node for copying or sth. like that.
*/
@property (weak) QMNode *parent;

@property (readonly, weak) NSArray *allChildren;

/**
* Returns the children on the RIGHT side. If the node is not a direct child of the root, then this will give you
* all children of the node.
*/
@property (readonly) NSArray *children;

/**
* Dictionary in which all attributes of the NODE xml element are stored, e.g. the TEXT or FOLDED attribute
*/
@property (readonly) NSDictionary *attributes;

/**
* Array that stores the unsupported XML elements.
*/
@property NSMutableArray *unsupportedChildren;

/**
* the custom font the node has. This is nil, iff the node uses the default font.
*/
@property NSFont *font;

/**
* an array containing the FreeMind icon codes as NSString.
*/
@property (readonly) NSArray *icons;

/**
* The initializer used to create a new node
*/
- (id)init;

/**
* The initializer used to create an existing XML node.
* 
* @param xmlAttributes is the dictionary containing all XML attribute of the XML NODE element
*/
- (id)initWithAttributes:(NSDictionary *)xmlAttributes;

- (void)addObjectInChildren:(QMNode *)childNode;
- (void)addObjectInIcons:(NSString *)icon;

- (NSUInteger)countOfChildren;
- (QMNode *)objectInChildrenAtIndex:(NSUInteger)index;
- (void)insertObject:(QMNode *)childNode inChildrenAtIndex:(NSUInteger)index;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

- (NSUInteger)countOfIcons;
- (NSString *)objectInIconsAtIndex:(NSUInteger)index;
- (void)insertObject:(NSString *)iconCode inIconsAtIndex:(NSUInteger)index;
- (void)removeObjectFromIconsAtIndex:(NSUInteger)index;

@end

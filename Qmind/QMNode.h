/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>
#import <Qkit/Qkit.h>

extern NSString *const qNodeIdAttributeKey;
extern NSString *const qNodeTextAttributeKey;
extern NSString *const qNodeFoldedAttributeKey;
extern NSString *const qNodePositionAttributeKey;

extern NSString *const qNodeParentArchiveKey;
extern NSString *const qNodeChildrenArchiveKey;
extern NSString *const qNodeLeftChildrenArchiveKey;
extern NSString *const qNodeAttributesArchiveKey;
extern NSString *const qNodeUnsupportedChildrenArchiveKey;
extern NSString *const qNodeFontArchiveKey;
extern NSString *const qNodeIconsArchiveKey;

extern NSString *const qNodeUti;

extern NSString *const qNodeStringValueKey;
extern NSString *const qNodeChildrenKey;
extern NSString *const qNodeFontKey;
extern NSString *const qNodeIconsKey;
extern NSString *const qNodeFoldingKey;


/**
* Model representation of a Mindmap's node.
*
* @implements NSCoding, NSPasteboardReading, NSPasteboardWriting, NSKeyValueCoding, NSKeyValueObserving
*/
@interface QMNode : QObservedObject <NSCopying, NSCoding, NSPasteboardWriting, NSPasteboardReading>

@property(weak) NSUndoManager *undoManager;

@property(getter=isFolded) BOOL folded;
@property(readonly, getter=isLeaf) BOOL leaf;

@property(getter=isCreatedNewly) BOOL createdNewly;

/**
* ID of the node: Prefixed with ID_
* Only QMProxyNode should write this.
*/
@property NSString *nodeId;

/**
* plain text value of the node.
*/
@property NSString *stringValue;

/**
* NO for QMNode. YES for QMRootNode.
*/
@property(readonly, getter=isRoot) BOOL root;

/**
* The parent of the node. If this is nil, the node is most probably a detached node for copying or sth. like that.
*/
@property(weak) QMNode *parent;

@property(readonly, weak) NSArray *allChildren;

/**
* Returns the children on the RIGHT side. If the node is not a direct child of the root, then this will give you
* all children of the node.
*/
@property(readonly) NSArray *children;

/**
* Dictionary in which all attributes of the NODE xml element are stored, e.g. the TEXT or FOLDED attribute
*/
@property(readonly) NSDictionary *attributes;

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
@property(readonly) NSArray *icons;

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

/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMMindmapViewDataSource.h"

static NSString * const qMindmapVersion = @"0.9.0";
static NSString * const qMindmapUti = @"com.qvacua.mindmap";
static NSString * const qObjectiveCppUti = @"public.objective-c-plus-plus-source";

@class QMDocumentWindowController;
@class QMMindmapReader;
@class QMMindmapWriter;
@class QMAppSettings;

/**
* Subclass of NSDocument for Qmind. It serves as DAO for nodes.
*/
@interface QMDocument : NSDocument

@property (weak) QMAppSettings *settings;
@property (weak) QMMindmapReader *mindmapReader;
@property (weak) QMMindmapWriter *mindmapWriter;

@property QMDocumentWindowController *windowController;

- (BOOL)isNodeLeft:(id)item;

- (NSInteger)numberOfChildrenOfNode:(id)item;
- (id)child:(NSInteger)index ofNode:(id)item;

- (NSInteger)numberOfLeftChildrenOfNode:(id)item;
- (id)leftChild:(NSInteger)index ofNode:(id)item;

- (BOOL)isNodeFolded:(id)item;
- (BOOL)isNodeLeaf:(id)item;

- (id)stringValueOfNode:(id)item;
- (id)fontOfNode:(id)node;
- (id)iconsOfNode:(id)item;

-(BOOL)item:(id)givenItem isDescendantOfItem:(id)potentialParentItem;

// TODO: get rid of these...
- (void)copyItemsToPasteboard:(NSArray *)items;
- (void)cutItemsToPasteboard:(NSArray *)items;

- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asChildrenToItem:(id)item;
- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asLeftChildrenToItem:(id)item;
- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asPreviousSiblingToItem:(id)item;
- (void)appendItemsFromPBoard:(NSPasteboard *)pasteboard asNextSiblingToItem:(id)item;

- (id)identifierForItem:(id)item;

- (void)markAsNotNew:(id)item;

- (void)setStringValue:(NSString *)str ofItem:(id)item;
- (void)setFont:(NSFont *)font ofItem:(id)item;
- (void)addIcon:(NSString *)iconCode toItem:(id)item;
- (void)deleteIconOfItem:(id)item atIndex:(NSUInteger)index;
- (void)deleteAllIconsOfItem:(id)item;

- (BOOL)itemIsNewlyCreated:(id)item;

- (void)moveItems:(NSArray *)itemsToMove toItem:(id)targetItem inDirection:(QMDirection)direction;
- (void)copyItems:(NSArray *)itemsToMove toItem:(id)targetItem inDirection:(QMDirection)direction;

- (void)addNewChildToItem:(id)item atIndex:(NSUInteger)index;
- (void)addNewLeftChildToItem:(id)item atIndex:(NSUInteger)index;
- (void)addNewNextSiblingToItem:(id)item;
- (void)addNewPreviousSiblingToItem:(id)item;

- (void)deleteItem:(id)item;

- (void)toggleFoldingForItem:(id)item;

@end


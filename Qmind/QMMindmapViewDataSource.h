/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>
#import "QMTypes.h"

@class QMMindmapView;
@class QMIcon;

@protocol QMMindmapViewDataSource
@required

#pragma mark Viewing
- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemLeft:(id)item;

- (NSInteger)mindmapView:(QMMindmapView *)mindmapView numberOfChildrenOfItem:(id)item;
- (id)mindmapView:(QMMindmapView *)mindmapView child:(NSInteger)index ofItem:(id)item;

- (NSInteger)mindmapView:(QMMindmapView *)mindmapView numberOfLeftChildrenOfItem:(id)item;
- (id)mindmapView:(QMMindmapView *)mindmapView leftChild:(NSInteger)index ofItem:(id)item;

- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemFolded:(id)item;
- (BOOL)mindmapView:(QMMindmapView *)mindmapView isItemLeaf:(id)item;

- (id)mindmapView:(QMMindmapView *)mindmapView stringValueOfItem:(id)item;
- (id)mindmapView:(QMMindmapView *)mindmapView fontOfItem:(id)item;
- (id)mindmapView:(QMMindmapView *)mindmapView iconsOfItem:(id)item;

#pragma mark Editing
- (id)mindmapView:(QMMindmapView *)mindmapView identifierForItem:(id)item;

- (void)mindmapView:(QMMindmapView *)mindmapView setStringValue:(NSString *)str ofItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView setFont:(NSFont *)font ofItems:(NSArray *)items;
- (void)mindmapView:(QMMindmapView *)mindmapView addIcon:(QMIcon *)icon toItem:(id)item;

- (void)mindmapView:(QMMindmapView *)mindmapView insertChildrenFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView insertLeftChildrenFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView insertNextSiblingsFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView insertPreviousSiblingsFromPasteboard:(NSPasteboard *)pasteboard toItem:(id)item;

- (void)mindmapView:(QMMindmapView *)mindmapView moveItems:(NSArray *)itemsToMove toItem:(id)itemToModify inDirection:(QMDirection)direction;
- (void)mindmapView:(QMMindmapView *)mindmapView copyItems:(NSArray *)itemsToMove toItem:(id)itemToModify inDirection:(QMDirection)direction;

- (void)mindmapView:(QMMindmapView *)mindmapView addNewChildToItem:(id)item atIndex:(NSInteger)index;
- (void)mindmapView:(QMMindmapView *)mindmapView addNewLeftChildToItem:(id)item atIndex:(NSInteger)index;
- (void)mindmapView:(QMMindmapView *)mindmapView addNewNextSiblingToItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView addNewPreviousSiblingToItem:(id)item;

- (void)mindmapView:(QMMindmapView *)mindmapView editingEndedForItem:(id)item;
- (void)mindmapView:(QMMindmapView *)mindmapView editingCancelledForItem:(id)item withAttrString:(NSAttributedString *)newAttrStr;
- (void)mindmapView:(QMMindmapView *)mindmapView deleteItems:(NSArray *)items;
- (void)mindmapView:(QMMindmapView *)mindmapView toggleFoldingForItem:(id)item;

#pragma mark Drag and Drop
- (void)mindmapView:(QMMindmapView *)mindmapView prepareDragAndDropWithCells:(NSArray *)items;

@end

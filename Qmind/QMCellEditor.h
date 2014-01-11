/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMMindmapView;
@class QMCell;
@class QMAppSettings;
@protocol QMCellEditorDelegate;
@class QMBorderedView;

@interface QMCellEditor : NSObject <NSTextFieldDelegate>

@property (weak) QMAppSettings *settings;

@property (weak) id<QMCellEditorDelegate> delegate;
@property (readonly, weak) QMCell *currentlyEditedCell;
@property (readonly, getter=isEditing) BOOL editing;

@property (weak) QMMindmapView *view;
@property (readonly) QMBorderedView *editorView;

- (void)beginEditStringValueForCell:(QMCell *)cellToEdit;
- (void)endEditing;

@end

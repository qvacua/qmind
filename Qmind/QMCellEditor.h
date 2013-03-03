/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

@class QMMindmapView;
@class QMCell;
@class QMAppSettings;
@protocol QMCellEditorDelegate;

@interface QMCellEditor : NSObject <NSTextViewDelegate>

@property (weak) QMAppSettings *settings;

@property (weak) QMMindmapView *view;
@property (weak) id<QMCellEditorDelegate> delegate;
@property (readonly, weak) QMCell *currentlyEditedCell;

- (void)beginEditStringValueForCell:(QMCell *)cellToEdit;
- (BOOL)isEditing;
- (void)endEditing;

@end

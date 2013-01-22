/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMCellEditor.h"
#import "QMBaseTestCase+Util.h"
#import <Qkit/Qkit.h>
#import "QMMindmapView.h"

@interface CellEditorTest : QMBaseTestCase
@end

@implementation CellEditorTest {
    QMCellEditor *editor;

    QMMindmapView *view;
    NSWindow *window;

    QMRootCell *rootCell;
}

- (void)setUp {
    [super setUp];

    view = mock([QMMindmapView class]);
    window = mock([NSWindow class]);
    [given([view window]) willReturn:window];

    rootCell = [self rootCellForTestWithView:view];

    editor = [[QMCellEditor alloc] init];
    editor.view = view;
    editor.delegate = view;
}

- (void)testBeginEditing {
    [editor beginEditStringValueForCell:CELL(4)];
    assertThat(editor.currentlyEditedCell, is(CELL(4)));

    [verify(view) addSubview:instanceOf([QShadowedView class])];
    [verify(window) makeFirstResponder:instanceOf([NSTextView class])];
}

- (void)testEndEditing {
    NSUndoManager *const undoManager = [editor undoManagerForTextView:nil];
    [undoManager registerUndoWithTarget:self selector:@selector(testEndEditing) object:self];

    [editor beginEditStringValueForCell:CELL(4)];
    [editor textDidEndEditing:nil];

    [verify(view) editingEndedWithString:instanceOf([NSAttributedString class]) forCell:CELL(4) byChar:NSCarriageReturnCharacter];
    assertThat(editor.currentlyEditedCell, nilValue());
    [verify(window) makeFirstResponder:view];

    assertThatBool([undoManager canUndo], isFalse);
}

- (void)testIsEditing {
    [editor beginEditStringValueForCell:CELL(4)];
    assertThatBool([editor isEditing], isTrue);

    [editor textDidEndEditing:nil];
    assertThatBool([editor isEditing], isFalse);
}

- (void)testCancelEditing {
    // TODO ?
}

@end

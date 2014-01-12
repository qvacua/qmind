/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMCellEditor.h"
#import "QMBaseTestCase+Util.h"
#import "QMMindmapView.h"
#import "QMBorderedView.h"


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

  assertThat(@(editor.editorView.isHidden), is(@NO));
  [verify(window) makeFirstResponder:instanceOf([NSTextField class])];
}

- (void)testEndEditing {
  [editor beginEditStringValueForCell:CELL(4)];
  [editor controlTextDidEndEditing:nil];

  [verify(view) editingEndedWithString:instanceOf([NSAttributedString class]) forCell:CELL(4) byChar:NSCarriageReturnCharacter];
  assertThat(@(editor.editorView.isHidden), is(@YES));
  assertThat(editor.currentlyEditedCell, nilValue());
  [verify(window) makeFirstResponder:view];
}

- (void)testIsEditing {
  [editor beginEditStringValueForCell:CELL(4)];
  assertThat(@(editor.editing), isYes);

  [editor controlTextDidEndEditing:nil];
  assertThat(@(editor.editing), isNo);
}

- (void)testCancelEditing {
  // TODO ?
}

@end

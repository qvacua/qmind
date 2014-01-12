/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMCellEditor.h"
#import "QMMindmapView.h"
#import "QMCell.h"
#import "QMAppSettings.h"
#import "QMBorderedView.h"


static NSInteger const qEscUnicode = 27;

static const int qEditBoxBorderWidth = 1;

static inline unichar current_event_char() {
  return [[[NSApp currentEvent] characters] characterAtIndex:0];
}

@interface QMCellEditor ()

@property (readwrite, weak) QMCell *currentlyEditedCell;
@property BOOL editingCanceled;
@property (readonly) NSTextField *textField;

@end


@implementation QMCellEditor

TB_MANUALWIRE(settings)

#pragma mark Public
- (BOOL)isEditing {
  return self.currentlyEditedCell != nil;
}

- (void)endEditing {
  [self.view.window makeFirstResponder:self.view];
}

- (NSSize)textFieldSizeForCell:(QMCell *)cell {
  const NSSize textSize = cell.textSize;

  CGFloat defaultCellWidth = [self.settings floatForKey:qSettingNodeEditMinWidth];
  CGFloat widthForTextView = MAX(defaultCellWidth, textSize.width);
  CGFloat maxWidth = [self.settings floatForKey:qSettingNodeEditMaxWidth];
  widthForTextView = MIN(maxWidth, widthForTextView);

  /**
  * when the default font size is 14, the text view size was ok, however, now with 12, it's too small, thus + 2
  */
  CGFloat heightForTextView = textSize.height + 2;

  if (cell.stringValue.length == 0) {
    NSFont *font = self.settings[qSettingDefaultFont];
    if (cell.font != nil) {
      font = cell.font;
    }

    heightForTextView += font.pointSize;
  }

  return NewSize(widthForTextView, heightForTextView);
}

- (void)beginEditStringValueForCell:(QMCell *)cellToEdit {
  self.currentlyEditedCell = cellToEdit;

  NSString *str = cellToEdit.stringValue;
  self.textField.stringValue = str;

  NSFont *font = self.settings[qSettingDefaultFont];
  if (cellToEdit.font != nil) {
    font = cellToEdit.font;
  }

  self.textField.font = font;

  NSPoint textOrigin = cellToEdit.textOrigin;
  NSSize textFieldSize = [self textFieldSizeForCell:cellToEdit];
  NSPoint containerOrigin = NewPoint(
      textOrigin.x - qEditBoxBorderWidth - 2,
      textOrigin.y - qEditBoxBorderWidth - 1
  );  // using heuristic such that the text in the text field is at the same position as the node text
  NSSize containerSize = NewSize(textFieldSize.width + qEditBoxBorderWidth, textFieldSize.height + qEditBoxBorderWidth);

  [self.editorView setFrame:NewRectWithOriginAndSize(containerOrigin, containerSize)];

  self.editorView.hidden = NO;
  [self.view scrollRectToVisible:self.editorView.frame];
  [self.view.window makeFirstResponder:self.textField];

  [self.view setNeedsDisplay:YES];
}

#pragma mark NSControlSubclassNotifications
- (void)controlTextDidEndEditing:(NSNotification *)notification {
  NSAttributedString *attrString = [[NSAttributedString alloc] initWithAttributedString:self.textField.attributedStringValue];

  if (self.editingCanceled) {

    [self.delegate editingCancelledWithString:attrString forCell:self.currentlyEditedCell];

  } else {

    unichar character;
    NSEventType eventType = [[NSApp currentEvent] type];
    if (eventType == NSKeyDown || eventType == NSKeyUp) {
      character = current_event_char();
    } else {
      character = NSCarriageReturnCharacter;
    }

    [self.delegate editingEndedWithString:attrString forCell:self.currentlyEditedCell byChar:character];

  }

  self.editingCanceled = NO;
  self.currentlyEditedCell = nil;
  self.editorView.hidden = YES;

  [self.view.window makeFirstResponder:self.view];
  [self.view setNeedsDisplay:YES];
}

#pragma mark NSControlTextEditingDelegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
  if (commandSelector == @selector(insertNewline:)) {
    log4Debug(@"insertNewLine:");
  }

  return NO;
}

- (NSArray *)control:(NSControl *)control
            textView:(NSTextView *)textView
         completions:(NSArray *)words
 forPartialWordRange:(NSRange)charRange
 indexOfSelectedItem:(NSInteger *)index {

  if (current_event_char() == qEscUnicode) {
    self.editingCanceled = YES;
    [self.view.window makeFirstResponder:self.view];

    return nil;
  }

  return words;
}

#pragma mark NSObject
- (id)init {
  self = [super init];
  if (self) {
    [[TBContext sharedContext] autowireSeed:self];

    _editingCanceled = NO;

    _textField = [[NSTextField alloc] initWithFrame:NewRect(1, 1, 20, 20)];
    _textField.delegate = self;
//    _textField.allowsEditingTextAttributes = YES;
    _textField.focusRingType = NSFocusRingTypeNone;
    _textField.bordered = NO;
    _textField.bezeled = NO;
    _textField.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    _editorView = [[QMBorderedView alloc] initWithFrame:NewRect(0, 0, 22, 22)];
    _editorView.borderWidth = qEditBoxBorderWidth;
    _editorView.autoresizesSubviews = YES;
    [_editorView addSubview:_textField];
  }

  return self;
}

@end

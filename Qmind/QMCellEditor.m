/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMCellEditor.h"
#import "QMMindmapView.h"
#import "QMCell.h"
#import <Qkit/Qkit.h>
#import "QMAppSettings.h"


static NSInteger const qEscUnicode = 27;

@interface QMCellEditor ()

@property (readwrite, weak) QMCell *currentlyEditedCell;

@property NSUndoManager *undoManager;
@property BOOL editingCanceled;

@property NSLayoutManager *layoutManager;
@property NSTextStorage *textStorage;
@property NSTextContainer *textContainer;
@property NSTextView *textView;
@property NSScrollView *scrollView;

@end


@implementation QMCellEditor

TB_MANUALWIRE(settings)

- (BOOL)isEditing {
    return self.currentlyEditedCell != nil;
}

- (NSSize)textViewSizeForCell:(QMCell *)cell {
    const NSSize textSize = cell.textSize;

    CGFloat defaultCellWidth = [self.settings floatForKey:qSettingNodeEditMinWidth];
    CGFloat widthForTextView = MAX(defaultCellWidth, textSize.width);
    CGFloat maxWidth = [self.settings floatForKey:qSettingNodeEditMaxWidth];
    widthForTextView = MIN(maxWidth, widthForTextView);

    /**
    * when the default font size is 14, the text view size was ok, however, now with 12, it's too small, thus + 2
    */
    CGFloat heightForTextView = textSize.height + 2;

    if ([cell.stringValue length] == 0) {
        NSFont *font = [self.settings settingForKey:qSettingDefaultFont];
        if (cell.font != nil) {
            font = cell.font;
        }

        heightForTextView += [font pointSize];
    }

    return NewSize(widthForTextView, heightForTextView);
}

- (void)beginEditStringValueForCell:(QMCell *)cellToEdit {
    self.currentlyEditedCell = cellToEdit;

    [self.textStorage setAttributedString:cellToEdit.attributedString];

    if (self.textStorage.length == 0) {
        NSFont *font = [self.settings settingForKey:qSettingDefaultFont];

        if (cellToEdit.font != nil) {
            font = cellToEdit.font;
        }

        [self.textView setFont:font];
    }

    NSSize textViewSize = [self textViewSizeForCell:cellToEdit];
    NSSize scrollViewSize = [NSScrollView frameSizeForContentSize:textViewSize hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSBezelBorder];

    [self.scrollView setFrame:NewRectWithSize(0, 0, scrollViewSize)];

    NSPoint textOrigin = cellToEdit.textOrigin;
    NSPoint containerOrigin = NewPoint(textOrigin.x - CONTAINER_BORDER_WIDTH, textOrigin.y - CONTAINER_BORDER_WIDTH);

    [self.scrollView setFrameOrigin:containerOrigin];

    [self.view addSubview:self.scrollView];
    [self.view scrollRectToVisible:self.scrollView.frame];
    [self.view.window makeFirstResponder:self.textView];

    [self.view setNeedsDisplay:YES];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSAttributedString *const attrString = [[NSAttributedString alloc] initWithAttributedString:self.textStorage];

    if (self.editingCanceled) {
        [self.delegate editingCancelledWithString:attrString forCell:self.currentlyEditedCell];
    } else {
        NSEventType eventType = [[NSApp currentEvent] type];

        unichar character;
        if (eventType == NSKeyDown || eventType == NSKeyUp) {
            character = [[[NSApp currentEvent] characters] characterAtIndex:0];
        } else {
            character = NSCarriageReturnCharacter;
        }

        [self.delegate editingEndedWithString:attrString forCell:self.currentlyEditedCell byChar:character];
    }

    self.editingCanceled = NO;
    self.currentlyEditedCell = nil;

    [self.scrollView removeFromSuperview];

    [self.undoManager removeAllActions];

    [self.view.window makeFirstResponder:self.view];
    [self.view setNeedsDisplay:YES];
}

- (NSArray *)textView:(NSTextView *)textView
          completions:(NSArray *)words
  forPartialWordRange:(NSRange)charRange
  indexOfSelectedItem:(NSInteger *)index {

    unichar character = [[[NSApp currentEvent] characters] characterAtIndex:0];

    if (character == qEscUnicode) {
        self.editingCanceled = YES;
        [self.view.window makeFirstResponder:self.view];

        return nil;
    }

    return words;
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(insertNewline:)) {
        log4Debug(@"insertNewLine:");
    }

    return NO;
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view {
    return self.undoManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [[TBContext sharedContext] autowireSeed:self];

        _editingCanceled = NO;

        _undoManager = [[NSUndoManager alloc] init];

        _layoutManager = [[NSLayoutManager alloc] init];
        _textStorage = [[NSTextStorage alloc] init];
        _textContainer = [[NSTextContainer alloc] init];

        [_textContainer setLineFragmentPadding:0.0];
        [_textContainer setWidthTracksTextView:YES];
        [_textContainer setContainerSize:NewSize(0, MAX_CGFLOAT)];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager addTextContainer:_textContainer];

        _textView = [[NSTextView alloc] initWithFrame:NewRect(0, 0, 100, 24) textContainer:_textContainer];
        _scrollView = [[NSScrollView alloc] initWithFrame:NewRect(0, 0, 150, 40)];

        [_textView setDelegate:self];
        [_textView setAllowsUndo:YES];
        [_textView setEditable:YES];
        [_textView setTextContainerInset:NSZeroSize];
        [_textView setVerticallyResizable:YES];
        [_textView setHorizontallyResizable:YES];
        [_textView setRichText:NO];
        [_textView setFieldEditor:YES];
        [_textView setContinuousSpellCheckingEnabled:YES];
        [_textView setAutoresizingMask:NSViewWidthSizable];
        [_textView setMaxSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];

        [_scrollView setDocumentView:_textView];
        [_scrollView setBorderType:NSBezelBorder];
        [_scrollView setHasHorizontalScroller:NO];
        [_scrollView setHasVerticalScroller:NO];
    }

    return self;
}

- (void)endEditing {
    [self.view.window makeFirstResponder:self.view];
}

@end

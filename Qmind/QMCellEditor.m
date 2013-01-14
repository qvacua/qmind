/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMCellEditor.h"
#import "QMMindmapView.h"
#import "QMCell.h"
#import <Qkit/Qkit.h>
#import "QMAppSettings.h"

static NSInteger const qEscUnicode = 27;

@implementation QMCellEditor {
    __weak QMAppSettings *_settings;

    __weak QMMindmapView *_view;
    __weak id <QMCellEditorDelegate> _delegate;
    __weak QMCell *_currentlyEditedCell;

    BOOL _editingCanceled;

    NSUndoManager *_undoManager;

    NSLayoutManager *_layoutManager;
    NSTextStorage *_textStorage;
    NSTextContainer *_textContainer;
    NSTextView *_textView;
    NSScrollView *_scrollView;
    QShadowedView *_containerView;
}

TB_MANUALWIRE_WITH_INSTANCE_VAR(settings, _settings)

@synthesize view = _view;
@synthesize delegate = _delegate;
@synthesize currentlyEditedCell = _currentlyEditedCell;

- (BOOL)isEditing {
    return _currentlyEditedCell != nil;
}

- (NSSize)textViewSizeForCell:(QMCell *)cell {
    const NSSize textSize = cell.textSize;

    CGFloat defaultCellWidth = [_settings floatForKey:qSettingNodeEditMinWidth];
    CGFloat widthForTextView = MAX(defaultCellWidth, textSize.width);
    CGFloat maxWidth = [_settings floatForKey:qSettingNodeEditMaxWidth];
    widthForTextView = MIN(maxWidth, widthForTextView);

    /**
    * when the default font size is 14, the text view size was ok, however, now with 12, it's too small, thus + 2
    */
    CGFloat heightForTextView = textSize.height + 2;

    if ([cell.stringValue length] == 0) {
        NSFont *font = [_settings settingForKey:qSettingDefaultFont];
        if (cell.font != nil) {
            font = cell.font;
        }

        heightForTextView += [font pointSize];
    }

    return NewSize(widthForTextView, heightForTextView);
}

- (void)beginEditStringValueForCell:(QMCell *)cellToEdit {
    _currentlyEditedCell = cellToEdit;

    [_textStorage setAttributedString:cellToEdit.attributedString];

    if (_textStorage.length == 0) {
        NSFont *font = [_settings settingForKey:qSettingDefaultFont];

        if (cellToEdit.font != nil) {
            font = cellToEdit.font;
        }

        [_textView setFont:font];
    }

    NSSize textViewSize = [self textViewSizeForCell:cellToEdit];
    [_textView setMinSize:textViewSize];

    NSSize scrollViewSize = [NSScrollView frameSizeForContentSize:textViewSize hasHorizontalScroller:NO hasVerticalScroller:NO borderType:NSNoBorder];

    [_scrollView setFrame:NewRectWithSize(0, 0, scrollViewSize)];

    NSPoint textOrigin = cellToEdit.textOrigin;
    [_containerView setFrameOrigin:NewPoint(textOrigin.x - CONTAINER_BORDER_WIDTH,
                                            textOrigin.y - CONTAINER_BORDER_WIDTH)];

    [_containerView addOnlySubview:_scrollView];

    [_view addSubview:_containerView];
    [_view scrollRectToVisible:_containerView.frame];
    [_view.window makeFirstResponder:_textView];

    [_view setNeedsDisplay:YES];
}

- (void)textDidEndEditing:(NSNotification *)notification {
    NSAttributedString *const attrString = [[NSAttributedString alloc] initWithAttributedString:_textStorage];

    if (_editingCanceled) {
        [_delegate editingCancelledWithString:attrString forCell:_currentlyEditedCell];
    } else {
        NSEventType eventType = [[NSApp currentEvent] type];

        unichar character;
        if (eventType == NSKeyDown || eventType == NSKeyUp) {
            character = [[[NSApp currentEvent] characters] characterAtIndex:0];
        } else {
            character = NSCarriageReturnCharacter;
        }

        [_delegate editingEndedWithString:attrString forCell:_currentlyEditedCell byChar:character];
    }

    _editingCanceled = NO;
    _currentlyEditedCell = nil;

    [_containerView removeFromSuperview];
    [_scrollView removeFromSuperview];

    [_undoManager removeAllActions];

    [_view.window makeFirstResponder:_view];
    [_view setNeedsDisplay:YES];
}

- (NSArray *)textView:(NSTextView *)textView
          completions:(NSArray *)words
  forPartialWordRange:(NSRange)charRange
  indexOfSelectedItem:(NSInteger *)index {

    unichar character = [[[NSApp currentEvent] characters] characterAtIndex:0];

    if (character == qEscUnicode) {
        _editingCanceled = YES;
        [_view.window makeFirstResponder:_view];

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
    return _undoManager;
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
        _containerView = [[QShadowedView alloc] initWithFrame:NewRect(0, 0, 200, 100)];

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
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setHasHorizontalScroller:NO];
        [_scrollView setHasVerticalScroller:NO];

        [_containerView addOnlySubview:_scrollView];
    }

    return self;
}

- (void)endEditing {
    [_view.window makeFirstResponder:_view];
}

@end

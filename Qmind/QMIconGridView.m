/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import "QMIconGridView.h"
#import "QMMindmapView.h"
#import "QMIconCollectionViewItem.h"

static CGFloat const kBackgroundBoxRadius = 6;
static CGFloat const kBackgroundBoxPadding = -1;

@implementation QMIconGridView {
    __unsafe_unretained QMIconCollectionViewItem *_viewController;

    NSColor *_backgroundColor;
}

@synthesize viewController = _viewController;

#pragma mark NSView
- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _backgroundColor = [QMIconGridView normalBackgroundColor];
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect roundBoxFrame = NewRectExpanding([self bounds], kBackgroundBoxPadding, kBackgroundBoxPadding);
    NSBezierPath *roundBox = [NSBezierPath bezierPathWithRoundedRect:roundBoxFrame xRadius:kBackgroundBoxRadius yRadius:kBackgroundBoxRadius];

    [_backgroundColor set];
    [roundBox fill];

    [super drawRect:dirtyRect];
}

#pragma mark NSResponder
- (void)mouseDown:(NSEvent *)theEvent {
    if (![_viewController canSetIcon]) {
        return;
    }

    _backgroundColor = [QMIconGridView pressedBackgroundColor];
    [self setNeedsDisplay:YES];

    NSEvent *currentEvent;
    BOOL keepMouseTrackOn = YES;
    while (keepMouseTrackOn) {
        currentEvent = [self.window nextEventMatchingMask:NSLeftMouseUpMask];

        switch ([currentEvent type]) {
            case NSLeftMouseUp:
                _backgroundColor = [QMIconGridView normalBackgroundColor];
                [self setNeedsDisplay:YES];

                [_viewController setIcon];

                keepMouseTrackOn = NO;
                break;

            default:
                break;
        }
    }
}

#pragma mark Static
+ (NSColor *)normalBackgroundColor {
    static NSColor *normalBackgroundColor = nil;

    if (normalBackgroundColor == nil) {
        normalBackgroundColor = [NSColor colorWithDeviceWhite:0.94 alpha:1.0];
    }

    return normalBackgroundColor;
}

+ (NSColor *)pressedBackgroundColor {
    static NSColor *pressedBackgroundColor = nil;

    if (pressedBackgroundColor == nil) {
        pressedBackgroundColor = [NSColor yellowColor];
    }

    return pressedBackgroundColor;
}


@end

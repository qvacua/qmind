/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */
#import <Qkit/Qkit.h>
#import "DummyView.h"


@implementation DummyView

- (BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [[NSColor redColor] set];
    logRect4Debug(@"dummy bounds", [self bounds]);
    logRect4Debug(@"dummy frame", [self frame]);
    NSRectFill([self bounds]);
}

- (void)setFrame:(NSRect)rect {
    logRect4Debug(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! set frame:", rect);
    [super setFrame:rect];
}

@end

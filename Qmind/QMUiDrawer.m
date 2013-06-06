/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>
#import "QMUiDrawer.h"

static const NSSize qSizeOfBadgeCircle = {20., 20.};

@implementation QMUiDrawer

- (void)drawBadgeWithNumber:(NSUInteger)number atPoint:(NSPoint)location {
    NSColor *red = [NSColor redColor];
    NSColor *darkRed = [NSColor colorWithCalibratedRed:0.71 green:0 blue:0.13 alpha:1];
    NSColor *clear = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0];
    NSColor *halfClear = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.5];

    NSGradient *redGradient = [[NSGradient alloc] initWithStartingColor:red endingColor:darkRed];
    NSGradient *shinyGradient = [[NSGradient alloc] initWithColorsAndLocations:
        halfClear, 0.0,
        [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.25], 0.20,
        clear, 0.50,
        nil];

    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowOffset:NewSize(0, -1)];
    [shadow setShadowBlurRadius:5];

    NSBezierPath *redCirclePath = [NSBezierPath bezierPathWithOvalInRect:NewRectWithOriginAndSize(location, qSizeOfBadgeCircle)];
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [shadow.shadowColor setFill];
    [redCirclePath fill];
    [redGradient drawInBezierPath:redCirclePath angle:-45];
    [NSGraphicsContext restoreGraphicsState];

    [[NSColor whiteColor] setStroke];
    [redCirclePath setLineWidth:1];
    [redCirclePath stroke];

    NSBezierPath *shinyCirclePath = [NSBezierPath bezierPathWithOvalInRect:NewRectWithOriginAndSize(location, qSizeOfBadgeCircle)];
    [shinyGradient drawInBezierPath:shinyCirclePath angle:-45];
}

@end

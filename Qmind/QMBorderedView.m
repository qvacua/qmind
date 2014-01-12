/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

#import "QMBorderedView.h"
#import <Qkit/Qkit.h>


@interface QMBorderedView ()

@property NSBezierPath *borderPath;

@end

@implementation QMBorderedView

#pragma mark NSView
- (void)setFrame:(NSRect)frameRect {
  self.borderPath = [NSBezierPath bezierPathWithRect:NewRectWithSize(0, 0, frameRect.size)];
  self.borderPath.lineWidth = self.borderWidth;

  [super setFrame:frameRect];
}

- (void)drawRect:(NSRect)dirtyRect {
  [NSGraphicsContext saveGraphicsState];
  {
    [[NSColor grayColor] setStroke];
    [[NSColor whiteColor] setFill];

    [self.borderPath fill];
    [self.borderPath stroke];
  }
  [NSGraphicsContext restoreGraphicsState];

  [super drawRect:dirtyRect];
}

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _borderWidth = 1;

    _borderPath = [NSBezierPath bezierPathWithRect:frameRect];
    _borderPath.lineWidth = _borderWidth;
  }

  return self;
}

- (BOOL)isFlipped {
  return YES;
}

@end

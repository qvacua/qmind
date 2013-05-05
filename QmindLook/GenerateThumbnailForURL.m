#include <QuickLook/QuickLook.h>
#import "QMLookUtil.h"
#import "QMRootCell.h"

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef cfUrl, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize) {
    @autoreleasepool {
        QMRootCell *rootCell = [QMLookUtil rootCellForUrl:(__bridge NSURL *) cfUrl];
        CGSize canvasSize = rootCell.familySize;

        CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, canvasSize, false, NULL);
        if (!cgContext) {
            return noErr;
        }

        /**
        * When I use
        * [NSGraphicsContext graphicsContextWithGraphicsPort:(void *) cgContext flipped:YES]
        * and draw the mindmap, the whole mindmap is drawn upside down.
        * When I use flipped:NO, then the NSLayoutManager is correctly flipped, but drawings of other primitive objects
        * are not flipped => wrong rendering.
        * Thus, we flip the whole CGContext which is the base of the NSGraphicsContext. Not very elegant, but it works.
        */
        CGAffineTransform verticalFlipTrafo = CGAffineTransformMake(1, 0, 0, -1, 0, canvasSize.height);
        CGContextConcatCTM(cgContext, verticalFlipTrafo);

        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *) cgContext flipped:YES];
        if (!context) {
            return noErr;
        }

        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];

        // TODO: more intelligent thumbnail generation
        [rootCell drawRect:NSMakeRect(qMindmapOrigin.x, qMindmapOrigin.y, canvasSize.width, canvasSize.height)];

        [NSGraphicsContext restoreGraphicsState];

        QLThumbnailRequestFlushContext(thumbnail, cgContext);
        CFRelease(cgContext);
    }

    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail) {
    // Implement only if supported
}

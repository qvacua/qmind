#include <QuickLook/QuickLook.h>
#import "QMDocument.h"
#import "QMRootCell.h"
#import "QMLookUtil.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef cfUrl, CFStringRef contentTypeUTI, CFDictionaryRef options);

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef cfUrl, CFStringRef contentTypeUTI, CFDictionaryRef options) {
    @autoreleasepool {
        QMRootCell *rootCell = [QMLookUtil rootCellForUrl:(__bridge NSURL *) cfUrl];
        CGSize canvasSize = rootCell.familySize;

        CGContextRef cgContext = QLPreviewRequestCreateContext(preview, canvasSize, false, NULL);
        if (!cgContext) {
            return noErr;
        }

        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *) cgContext flipped:YES];
        if (!context) {
            return noErr;
        }

        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];

        [rootCell drawRect:NSMakeRect(0, 0, canvasSize.width, canvasSize.height)];

        [NSGraphicsContext restoreGraphicsState];

        QLPreviewRequestFlushContext(preview, cgContext);
        CFRelease(cgContext);
    }

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview) {
    // Implement only if supported
}

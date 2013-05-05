#include <QuickLook/QuickLook.h>
#import <Qkit/QLog.h>
#import <TBCacao/TBContext.h>
#import "QMIconManager.h"
#import "QMMindmapReader.h"
#import "QMDocument.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef cfUrl, CFStringRef contentTypeUTI, CFDictionaryRef options);

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef cfUrl, CFStringRef contentTypeUTI, CFDictionaryRef options) {
    NSURL *url = (__bridge NSURL *) cfUrl;
    TBContext *context = [TBContext sharedContext];

    QMDocument *doc = [[QMDocument alloc] init];
    doc.fileURL = url;

    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initWithURL:url options:(NSFileWrapperReadingOptions) 0 error:NULL];
    [doc readFromFileWrapper:fileWrapper ofType:nil error:NULL];




    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview) {
    // Implement only if supported
}

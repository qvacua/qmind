/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import <Qkit/Qkit.h>
#import "QMIcon.h"
#import "QMIconManager.h"
#import "QMAppSettings.h"
#import "QMTextDrawer.h"
#import "QMTextLayoutManager.h"

@implementation QMIcon {
    __weak QMIconManager *_iconManager;
    __weak QMAppSettings *_settings;
    __weak QMTextDrawer *_textDrawer;
    __weak QMTextLayoutManager *_textLayoutManager;

    QMIconKind _kind;

    NSPoint _origin;
    NSSize _size;

    NSString *_code;

    NSString *_unicode;
    NSImage *_image;
    NSImage *_flippedImage;
}

TB_AUTOWIRE_WITH_INSTANCE_VAR(iconManager, _iconManager)
TB_AUTOWIRE_WITH_INSTANCE_VAR(settings, _settings)
TB_AUTOWIRE_WITH_INSTANCE_VAR(textDrawer, _textDrawer)
TB_AUTOWIRE_WITH_INSTANCE_VAR(textLayoutManager, _textLayoutManager)

@synthesize kind = _kind;
@synthesize origin = _origin;
@synthesize size = _size;
@synthesize code = _code;
@synthesize unicode = _unicode;
@synthesize image = _image;
@synthesize flippedImage = _flippedImage;

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    QMIcon *copy = [[QMIcon alloc] initWithCode:_code];
    copy.origin = _origin;
    copy.size = _size;

    return copy;
}

#pragma mark Initializer
- (id)initWithCode:(NSString *)aCode {
    self = [super init];
    if (self) {
        TBContext *context = [TBContext sharedContext];

        _iconManager = [context beanWithClass:[QMIconManager class]];
        _settings = [context beanWithClass:[QMAppSettings class]];
        _textDrawer = [context beanWithClass:[QMTextDrawer class]];
        _textLayoutManager = [context beanWithClass:[QMTextLayoutManager class]];

        _code = aCode;
        _kind = [_iconManager kindForCode:_code];

        if (_kind == QMIconKindString) {
            _unicode = [_iconManager iconRepresentationForCode:_code];
        } else if (_kind == QMIconKindImage) {
            _image = [_iconManager iconRepresentationForCode:_code];
            [self initFlippedImage];
        }

        CGFloat iconSize = [_settings floatForKey:qSettingIconDrawSize];
        _size = NewSize(iconSize, iconSize);
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect frame = NewRectWithOriginAndSize(self.origin, self.size);
    if (!NSIntersectsRect(dirtyRect, frame)) {
        return;
    }

    if (_kind == QMIconKindString) {
        [self drawStringIconInRect:frame];

        return;
    }

    if (_kind == QMIconKindImage) {
        [_image drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

#pragma mark Private
- (void)drawStringIconInRect:(NSRect)frame {
    NSFont *iconFont = [_settings settingForKey:qSettingIconFont];
    NSDictionary *attrDict = [_textLayoutManager stringAttributesDictWithFont:iconFont];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:_unicode attributes:attrDict];

    NSRect tempRect = frame;
    tempRect.origin.y -= 4;
    [_textDrawer drawAttributedString:attrStr inRect:tempRect range:NSMakeRange(0, 1)];
}

- (void)initFlippedImage {
    NSSize imgSize = [_image size];
    _flippedImage = [[NSImage alloc] initWithSize:imgSize];

    [_flippedImage lockFocus];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:imgSize.height];
    [transform scaleXBy:1 yBy:-1];
    [transform concat];
    [_image drawAtPoint:NSZeroPoint fromRect:NewRect(0, 0, imgSize.width, imgSize.height) operation:NSCompositeSourceOver fraction:1];
    [_flippedImage unlockFocus];
}

@end

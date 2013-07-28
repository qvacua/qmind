/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
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
#import "QMFontManager.h"


@implementation QMIcon {

}

@dynamic frame;

#pragma mark Public
- (NSRect)frame {
    return NewRectWithOriginAndSize(self.origin, self.size);
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    QMIcon *copy = [[QMIcon alloc] initWithCode:self.code];
    copy.origin = self.origin;
    copy.size = self.size;

    return copy;
}

#pragma mark Initializer
- (id)initWithCode:(NSString *)aCode {
    self = [super init];
    if (self) {
        [self initBeans];

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

- (id)initAsLink {
    self = [super init];
    if (self) {
        [self initBeans];

        _unicode = @"\\u%f023";
        _kind = QMIconKindFontawesome;

        CGFloat iconSize = [_settings floatForKey:qSettingLinkIconDrawSize];
        _size = NewSize(iconSize, iconSize);
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect frame = NewRectWithOriginAndSize(self.origin, self.size);
    if (!NSIntersectsRect(dirtyRect, frame)) {
        return;
    }

    if (self.kind == QMIconKindString) {
        [self drawStringIconInRect:frame];
        return;
    }

    if (self.kind == QMIconKindImage) {
        [self.image drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        return;
    }

    if (self.kind == QMIconKindFontawesome) {
        [self drawFontawesomeInRect:frame];
        return;
    }
}

#pragma mark Private
- (void)drawFontawesomeInRect:(NSRect)rect {
    NSFont *fontawesome = [[self.fontManager fontawesomeFont] copy];
    // TODO: we should set the font for links in app settings and use it here
    [self.systemFontManager convertFont:fontawesome toSize:16];
    NSDictionary *attrDict = [self.textLayoutManager stringAttributesDictWithFont:fontawesome];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:self.unicode attributes:attrDict];

    [self.textDrawer drawAttributedString:attrStr inRect:rect range:NSMakeRange(0, 1)];
}

- (void)initBeans {
    TBContext *context = [TBContext sharedContext];

    _iconManager = [context beanWithClass:[QMIconManager class]];
    _settings = [context beanWithClass:[QMAppSettings class]];
    _textDrawer = [context beanWithClass:[QMTextDrawer class]];
    _textLayoutManager = [context beanWithClass:[QMTextLayoutManager class]];
    _fontManager = [context beanWithClass:[QMFontManager class]];
    _systemFontManager = [context beanWithClass:[NSFontManager class]];
}

- (void)drawStringIconInRect:(NSRect)frame {
    NSFont *iconFont = [self.settings settingForKey:qSettingIconFont];
    NSDictionary *attrDict = [self.textLayoutManager stringAttributesDictWithFont:iconFont];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:self.unicode attributes:attrDict];

    NSRect tempRect = frame;
    tempRect.origin.y -= 4;
    [self.textDrawer drawAttributedString:attrStr inRect:tempRect range:NSMakeRange(0, 1)];
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

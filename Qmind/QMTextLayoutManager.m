/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMTextLayoutManager.h"
#import "QMAppSettings.h"
#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>

@interface QMTextLayoutManager ()

@property (readonly, strong) NSLayoutManager *layoutManager;
@property (readonly, strong) NSTextStorage *textStorage;
@property (readonly, strong) NSTextContainer *textContainer;

@end

@implementation QMTextLayoutManager {
    NSLayoutManager *_layoutManager;
    NSTextStorage *_textStorage;
    NSTextContainer *_textContainer;

    __weak QMAppSettings *_settings;
}

TB_BEAN

TB_AUTOWIRE_WITH_INSTANCE_VAR(settings, _settings);

@synthesize layoutManager = _layoutManager;
@synthesize textStorage = _textStorage;
@synthesize textContainer = _textContainer;

- (CGFloat)widthOfString:(NSString *)string {
    return [self widthOfString:string usingFont:[_settings settingForKey:qSettingDefaultFont]];
}

- (CGFloat)widthOfString:(NSString *)string usingFont:(NSFont *)font {
    NSSize result = [self sizeOfString:string maxWidth:MAX_CGFLOAT usingFont:font];

    return result.width;
}

- (NSSize)sizeOfString:(NSString *)string maxWidth:(CGFloat)maxWidth {
    return [self sizeOfString:string
                     maxWidth:maxWidth
                    usingFont:[_settings settingForKey:qSettingDefaultFont]];
}

- (NSSize)sizeOfString:(NSString *)string maxWidth:(CGFloat)maxWidth usingFont:(NSFont *)font {
    NSDictionary *attrDict = [self stringAttributesDictWithFont:font];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrDict];

    return [self sizeOfAttributedString:attrStr maxWidth:maxWidth];
}

- (NSSize)sizeOfAttributedString:(NSAttributedString *)attrStr maxWidth:(CGFloat)maxWidth {
    if (attrStr.length == 0) {
        return NewSize(0.0, 0.0);
    }

    @synchronized (_textStorage) {
        [self.textStorage setAttributedString:attrStr];
        [self.textContainer setContainerSize:NewSize(MAX_CGFLOAT, MAX_CGFLOAT)];

        /*
        * Because the layout manager performs layout lazily, on demand,
        * you must force it to lay out the text, even though you don’t need the glyph range returned by this function.
        */
        (void)[self.layoutManager glyphRangeForTextContainer:self.textContainer];
        NSRect rectAs1Line = [self.layoutManager usedRectForTextContainer:self.textContainer];
        NSSize sizeAs1Line = rectAs1Line.size;

        if (sizeAs1Line.width < maxWidth) {
            return sizeAs1Line;
        }

        [self.textContainer setContainerSize:NewSize(maxWidth, MAX_CGFLOAT)];
        NSRange completeRange = [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        NSRect rectAsMultiLine = [self.layoutManager boundingRectForGlyphRange:completeRange inTextContainer:self.textContainer];

        return rectAsMultiLine.size;
    }
}

- (id)init {
    if ((self = [super init])) {
        _textContainer = [[NSTextContainer alloc] init];
        _layoutManager = [[NSLayoutManager alloc] init];
        _textStorage = [[NSTextStorage alloc] init];

        [_textContainer setLineFragmentPadding:0.0];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager addTextContainer:_textContainer];
    }

    return self;
}

- (NSSize)sizeOfAttributedString:(NSAttributedString *)attrStr {
    return [self sizeOfAttributedString:attrStr maxWidth:[_settings floatForKey:qSettingMaxTextNodeWidth]];
}

+ (QMTextLayoutManager *)sharedManager {
    static QMTextLayoutManager *_sharedManager = nil;

    @synchronized (self) {
        if (_sharedManager == nil) {
            _sharedManager = [[self alloc] init];
        }
    }

    return _sharedManager;
}

- (NSRange)completeRangeOfAttributedString:(NSAttributedString *)attrStr {
    @synchronized (_textStorage) {
        [_textStorage setAttributedString:attrStr];
        return [_layoutManager glyphRangeForTextContainer:_textContainer];
    }
}

- (NSDictionary *)stringAttributesDictWithFont:(NSFont *)font {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [style setAlignment:NSLeftTextAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];

    NSDictionary *dict = @{
        NSParagraphStyleAttributeName: style,
        NSFontAttributeName: font
    };

    return dict;
}

- (NSDictionary *)stringAttributesDict {
    return [[QMAppSettings sharedSettings] settingForKey:qSettingDefaultStringAttributeDict];
}

@end

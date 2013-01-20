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

@implementation QMTextLayoutManager {
    NSLayoutManager *_layoutManager;
    NSTextStorage *_textStorage;
    NSTextContainer *_textContainer;
}

TB_BEAN
TB_AUTOWIRE_WITH_INSTANCE_VAR(settings, _settings)

#pragma mark Public
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
        [_textStorage setAttributedString:attrStr];
        [_textContainer setContainerSize:NewSize(MAX_CGFLOAT, MAX_CGFLOAT)];

        /*
        * Because the layout manager performs layout lazily, on demand,
        * you must force it to lay out the text, even though you don’t need the glyph range returned by this function.
        */
        (void)[_layoutManager glyphRangeForTextContainer:_textContainer];
        NSRect rectAs1Line = [_layoutManager usedRectForTextContainer:_textContainer];
        NSSize sizeAs1Line = rectAs1Line.size;

        if (sizeAs1Line.width < maxWidth) {
            return sizeAs1Line;
        }

        [_textContainer setContainerSize:NewSize(maxWidth, MAX_CGFLOAT)];
        NSRange completeRange = [_layoutManager glyphRangeForTextContainer:_textContainer];
        NSRect rectAsMultiLine = [_layoutManager boundingRectForGlyphRange:completeRange inTextContainer:_textContainer];

        return rectAsMultiLine.size;
    }
}

- (NSSize)sizeOfAttributedString:(NSAttributedString *)attrStr {
    return [self sizeOfAttributedString:attrStr maxWidth:[_settings floatForKey:qSettingMaxTextNodeWidth]];
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
    return [_settings settingForKey:qSettingDefaultStringAttributeDict];
}

#pragma mark NSObject
- (id)init {
    self = [super init];
    if (self) {
        _textContainer = [[NSTextContainer alloc] init];
        _layoutManager = [[NSLayoutManager alloc] init];
        _textStorage = [[NSTextStorage alloc] init];

        [_textContainer setLineFragmentPadding:0.0];
        [_textStorage addLayoutManager:_layoutManager];
        [_layoutManager addTextContainer:_textContainer];
    }

    return self;
}

@end

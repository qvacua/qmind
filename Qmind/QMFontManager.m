/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMFontManager.h"
#import <Qkit/Qkit.h>
#import "QMAppSettings.h"

static NSString * const qNameKey = @"NAME";
static NSString * const qSizeKey = @"SIZE";
static NSString * const qBoldKey = @"BOLD";
static NSString * const qItalicKey = @"ITALIC";
static NSString * const qTrueValue = @"true";
static NSString * const qDefaultSansSerifFontName = @"SansSerif";
static NSString * const qDefaultSerifFondName = @"Serif";
static NSString * const qTimesFontName = @"Times";

@implementation QMFontManager {
    NSFont *_defaultFont;
}

TB_AUTOWIRE(settings)
TB_AUTOWIRE(fontManager)

#pragma mark Public
- (NSFont *)fontFromFontAttrDict:(NSDictionary *)fontAttrDict {
    NSString *fontName = [fontAttrDict objectForKey:qNameKey];
    NSNumber *fontSizeObj = [fontAttrDict objectForKey:qSizeKey];
    NSNumber *boldObj = [fontAttrDict objectForKey:qBoldKey];
    NSNumber *italicObj = [fontAttrDict objectForKey:qItalicKey];

    CGFloat fontSize = fontSizeObj.floatValue;

    if (fontName == nil || [fontName isEqualToString:qDefaultSansSerifFontName]) {
        fontName = _defaultFont.familyName;
    }

    if ([fontName isEqualToString:qDefaultSerifFondName]) {
        fontName = qTimesFontName;
    }

    if (fontSizeObj == nil) {
        fontSize = [_defaultFont pointSize];
    }

    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    if (font == nil) {
        log4Debug(@"Unknown font '%@' encountered, falling back to default font", fontName);
        font = [NSFont fontWithName:[_defaultFont familyName] size:fontSize];
    }

    if (boldObj != nil) {
        font = [_fontManager convertFont:font toHaveTrait:NSBoldFontMask];
    }

    if (italicObj != nil) {
        font = [_fontManager convertFont:font toHaveTrait:NSItalicFontMask];
    }

    return font;
}

- (NSDictionary *)fontAttrDictFromFont:(NSFont *)font {
    if ([font isEqual:_defaultFont]) {
        return nil;
    }

    NSMutableDictionary *attrDict = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:4];
    
    NSString *fontName = font.familyName;
    if ([fontName isEqualToString:[_defaultFont familyName]] == NO) {
        [attrDict setObject:fontName forKey:qNameKey];
    }

    NSInteger fontSize = (NSInteger)font.pointSize;
    if ([_fontManager traitsOfFont:font] & NSFontBoldTrait) {
        [attrDict setObject:qTrueValue forKey:qBoldKey];
    }

    if ([_fontManager traitsOfFont:font] & NSFontItalicTrait) {
        [attrDict setObject:qTrueValue forKey:qItalicKey];
    }

    if (fontSize != [_defaultFont pointSize] || [attrDict count] > 0) {
        [attrDict setObject:[NSString stringWithFormat:@"%li", fontSize] forKey:qSizeKey];
    }

    return attrDict;
}

#pragma mark TBInitializingBean
- (void)postConstruct {
    _defaultFont = [_settings settingForKey:qSettingDefaultFont];
}

@end

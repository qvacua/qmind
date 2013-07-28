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

static NSString *const qNameKey = @"NAME";
static NSString *const qSizeKey = @"SIZE";
static NSString *const qBoldKey = @"BOLD";
static NSString *const qItalicKey = @"ITALIC";
static NSString *const qTrueValue = @"true";
static NSString *const qDefaultSansSerifFontName = @"SansSerif";
static NSString *const qDefaultSerifFondName = @"Serif";
static NSString *const qTimesFontName = @"Times";

@interface QMFontManager ()

@property (readonly) NSFont *defaultFont;

@end

@implementation QMFontManager

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
        fontName = self.defaultFont.familyName;
    }

    if ([fontName isEqualToString:qDefaultSerifFondName]) {
        fontName = qTimesFontName;
    }

    if (fontSizeObj == nil) {
        fontSize = [self.defaultFont pointSize];
    }

    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    if (font == nil) {
        log4Debug(@"Unknown font '%@' encountered, falling back to default font", fontName);
        font = [NSFont fontWithName:[self.defaultFont familyName] size:fontSize];
    }

    if (boldObj != nil) {
        font = [self.fontManager convertFont:font toHaveTrait:NSBoldFontMask];
    }

    if (italicObj != nil) {
        font = [self.fontManager convertFont:font toHaveTrait:NSItalicFontMask];
    }

    return font;
}

- (NSDictionary *)fontAttrDictFromFont:(NSFont *)font {
    if ([font isEqual:self.defaultFont]) {
        return nil;
    }

    NSMutableDictionary *attrDict = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:4];

    NSString *fontName = font.familyName;
    if ([fontName isEqualToString:[self.defaultFont familyName]] == NO) {
        [attrDict setObject:fontName forKey:qNameKey];
    }

    NSInteger fontSize = (NSInteger) font.pointSize;
    if ([self.fontManager traitsOfFont:font] & NSFontBoldTrait) {
        [attrDict setObject:qTrueValue forKey:qBoldKey];
    }

    if ([self.fontManager traitsOfFont:font] & NSFontItalicTrait) {
        [attrDict setObject:qTrueValue forKey:qItalicKey];
    }

    if (fontSize != [self.defaultFont pointSize] || [attrDict count] > 0) {
        [attrDict setObject:[NSString stringWithFormat:@"%li", fontSize] forKey:qSizeKey];
    }

    return attrDict;
}

#pragma mark TBInitializingBean
- (void)postConstruct {
    _defaultFont = [self.settings settingForKey:qSettingDefaultFont];

    NSString *fontPath = [[NSBundle bundleForClass:self.class] pathForResource:@"fontawesome-webfont" ofType:@"ttf"];
    NSData *fontData = [[NSData alloc] initWithContentsOfFile:fontPath];

    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef) fontData);
    CGFontRef cgFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);

    // if we pass NULL for attributes, we crash when releasing the font descriptor
    CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef) @{});
    CTFontRef ctFont = CTFontCreateWithGraphicsFont(cgFont, 0, NULL, fontDescriptor);
    CFRelease(fontDescriptor);
    CGFontRelease(cgFont);

    _fontawesomeFont = (__bridge_transfer NSFont *)ctFont;

}

@end

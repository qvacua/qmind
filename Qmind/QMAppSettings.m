/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMAppSettings.h"

static inline NSCharacterSet *single_key_charset(NSUInteger charCode) {
    return [NSCharacterSet characterSetWithRange:NSMakeRange(charCode, 1)];
}

@interface QMAppSettings ()

@property NSMutableDictionary *settingsDict;

@end

@implementation QMAppSettings

TB_BEAN

#pragma mark Public
- (id)settingForKey:(NSString *)key {
    return self.settingsDict[key];
}

- (CGFloat)floatForKey:(NSString *)key {
    return (CGFloat) [self.settingsDict[key] floatValue];
}

#pragma mark NSObject
- (id)init {
    self = [super init];
    if (self) {
        [self initSettingsDict];
    }

    return self;
}

#pragma mark Private
- (void)initSettingsDict {
    NSFont *defaultFont = [NSFont fontWithName:@"Helvetica" size:12.0];
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];

    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    [style setAlignment:NSLeftTextAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];

    attrDict[NSParagraphStyleAttributeName] = style;
    attrDict[NSFontAttributeName] = defaultFont;

    _settingsDict = [[NSMutableDictionary alloc] initWithDictionary:@{
            qSettingDefaultFont : defaultFont,
            qSettingDefaultParagraphStyle : style,
            qSettingDefaultStringAttributeDict : attrDict,
            qSettingIconFont : [NSFont fontWithName:@"Apple Color Emoji" size:14],
            qSettingBackgroundColor : [NSColor whiteColor],

            qSettingInternodeHorizontalDistance : @30,
            qSettingInternodeVerticalDistance : @7.5,
            qSettingInternodeLineWidth : @1,

            qSettingNodeEditMinWidth : @200,
            qSettingNodeEditMinHeight : @9,
            qSettingNodeEditMaxWidth : @640,

            qSettingNodeMinWidth : @100,
            qSettingNodeMinHeight : @14,

            qSettingFoldingMarkerRadius : @6,
            qSettingFoldingMarkerLineWidth : @1,

            qSettingMaxTextNodeWidth : @640,
            qSettingMaxRootCellTextWidth : @400,

            qSettingMindMapViewMargin : @20,

            qSettingNodeFocusRingMargin : @0,
            qSettingNodeFocusRingBorderRadius : @2,

            qSettingBezierControlPoint1 : @20,
            qSettingBezierControlPoint2 : @15,

            qSettingDefaultNewNodeWidth : @100,

            qSettingCellHorizontalPadding : @3,
            qSettingCellVerticalPadding : @3,

            qSettingIconTextDistance : @5,
            qSettingInterIconDistance : @3,
            qSettingIconDrawSize : @16,


            qSettingNewChildNodeChars : single_key_charset(NSTabCharacter),
            qSettingNewLeftChildNodeChars : single_key_charset(NSBackTabCharacter),
            qSettingEditSelectedNodeChars : single_key_charset(NSCarriageReturnCharacter),
            qSettingNewSiblingNodeChars : single_key_charset(NSCarriageReturnCharacter),
            qSettingDeleteNodeChars : single_key_charset(NSDeleteFunctionKey),
            qSettingDeselectCell : single_key_charset(27 /* ESC */),
            qSettingFoldingChars : single_key_charset(0x20 /* SPACE */),
    }];
}

@end

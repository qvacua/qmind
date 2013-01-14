/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import <Qkit/Qkit.h>
#import "QMAppSettings.h"

#define SINGLE_KEY_CHARSET(x) [NSCharacterSet characterSetWithRange:NSMakeRange((NSUInteger) x, 1)]

@implementation QMAppSettings {
    NSMutableDictionary *_settingsDict;
}

TB_BEAN

#pragma mark Public
- (id)settingForKey:(NSString *)key {
    return _settingsDict[key];
}

- (CGFloat)floatForKey:(NSString *)key {
    return (CGFloat) [_settingsDict[key] floatValue];
}

#pragma mark Static
+ (QMAppSettings *)sharedSettings {
    static QMAppSettings *_sharedAppSettings = nil;

    @synchronized (self) {
        if (_sharedAppSettings == nil) {
            _sharedAppSettings = [[self alloc] init];
        }
    }

    return _sharedAppSettings;
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

    [attrDict setObject:style forKey:NSParagraphStyleAttributeName];
    [attrDict setObject:defaultFont forKey:NSFontAttributeName];

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


            qSettingNewChildNodeChars : SINGLE_KEY_CHARSET(NSTabCharacter),
            qSettingNewLeftChildNodeChars : SINGLE_KEY_CHARSET(NSBackTabCharacter),
            qSettingEditSelectedNodeChars : SINGLE_KEY_CHARSET(NSCarriageReturnCharacter),
            qSettingNewSiblingNodeChars : SINGLE_KEY_CHARSET(NSCarriageReturnCharacter),
            qSettingDeleteNodeChars : SINGLE_KEY_CHARSET(NSDeleteFunctionKey),
            qSettingDeselectCell : SINGLE_KEY_CHARSET(27 /* ESC */),
            qSettingFoldingChars : SINGLE_KEY_CHARSET(0x20 /* SPACE */),
    }];
}

@end

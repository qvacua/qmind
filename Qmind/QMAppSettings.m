/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMAppSettings.h"

NSString * const qSettingInternodeHorizontalDistance = @"InternodeHorizontalDistance";
NSString * const qSettingInternodeVerticalDistance = @"InternodeVerticalDistance";
NSString * const qSettingInternodeLineWidth = @"InterNodeLineWidth";
NSString * const qSettingBezierControlPoint1 = @"BezierControlPoint1";
NSString * const qSettingBezierControlPoint2 = @"BezierControlPoint2";
NSString * const qSettingMaxTextNodeWidth = @"MaxTextNodeWidth";
NSString * const qSettingMaxRootCellTextWidth = @"MaxRootCellTextWidth";
NSString * const qSettingMindMapViewMargin = @"MindMapViewMargin";
NSString * const qSettingNodeFocusRingMargin = @"NodeFocusRingMargin";
NSString * const qSettingNodeFocusRingBorderRadius = @"NodeFocusRingBorderRadius";
NSString * const qSettingBackgroundColor = @"BackgroundColor";
NSString * const qSettingDefaultNewNodeWidth = @"DefaultNewNodeWidth";
NSString * const qSettingDefaultFont = @"DefaultFont";
NSString * const qSettingDefaultStringAttributeDict = @"DefaultStringAttributeDict";
NSString * const qSettingDefaultParagraphStyle = @"DefaultParagraphStyle";
NSString * const qSettingEditSelectedNodeChars = @"EditSelectedNodeChars";
NSString * const qSettingNewChildNodeChars = @"AppendNewChildNodeChars";
NSString * const qSettingNewLeftChildNodeChars = @"AppendNewLeftChildNodeChars";
NSString * const qSettingNewSiblingNodeChars = @"AppendNewSiblingNodeChars";
NSString * const qSettingDeleteNodeChars = @"DeleteNodeChars";
NSString * const qSettingDeselectCell = @"DeselectCellChars";
NSString * const qSettingInterIconDistance = @"IntericonDistance";
NSString * const qSettingLinkIconDrawSize = @"LinkIconDrawSize";
NSString * const qSettingLinkIconFont = @"LinkIconFont";
NSString * const qSettingLinkIconHorizontalMargin = @"LinkIconHorizontalMargin";
NSString * const qSettingIconDrawSize = @"IconDrawSize";
NSString * const qSettingIconFont = @"IconFont";
NSString * const qSettingNodeEditMinWidth = @"NodeEditMinWidth";
NSString * const qSettingNodeEditMinHeight = @"NodeEditMinHeight";
NSString * const qSettingNodeEditMaxWidth = @"NodeEditMaxWidth";
NSString * const qSettingNodeMinWidth = @"NodeMinWidth";
NSString * const qSettingNodeMinHeight = @"NodeMinHeight";
NSString * const qSettingFoldingChars = @"FoldingChars";
NSString * const qSettingIconTextDistance = @"IconTextDistance";

NSString * const qSettingFoldingMarkerRadius = @"FoldingMarkerRadius";
NSString * const qSettingFoldingMarkerLineWidth = @"FoldingMarkerLindWidth";

NSString * const qSettingCellHorizontalPadding = @"CellHorizontalPadding";
NSString * const qSettingCellVerticalPadding = @"CellVerticalPadding";

static const NSUInteger qEscCharacter = 27;
static const NSUInteger qSpaceCharacter = 0x20;

static inline NSCharacterSet *single_key_charset(NSUInteger charCode) {
    return [NSCharacterSet characterSetWithRange:NSMakeRange(charCode, 1)];
}

@interface QMAppSettings ()

@property NSMutableDictionary *settingsDict;

@end

@implementation QMAppSettings

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

            qSettingLinkIconDrawSize: @16,
            qSettingLinkIconHorizontalMargin: @3,

            qSettingNewChildNodeChars : single_key_charset(NSTabCharacter),
            qSettingNewLeftChildNodeChars : single_key_charset(NSBackTabCharacter),
            qSettingEditSelectedNodeChars : single_key_charset(NSCarriageReturnCharacter),
            qSettingNewSiblingNodeChars : single_key_charset(NSCarriageReturnCharacter),
            qSettingDeleteNodeChars : single_key_charset(NSDeleteFunctionKey),
            qSettingDeselectCell : single_key_charset(qEscCharacter),
            qSettingFoldingChars : single_key_charset(qSpaceCharacter),
    }];
}

@end

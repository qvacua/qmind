/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

static NSString * const qSettingInternodeHorizontalDistance = @"InternodeHorizontalDistance";
static NSString * const qSettingInternodeVerticalDistance = @"InternodeVerticalDistance";
static NSString * const qSettingInternodeLineWidth = @"InterNodeLineWidth";
static NSString * const qSettingBezierControlPoint1 = @"BezierControlPoint1";
static NSString * const qSettingBezierControlPoint2 = @"BezierControlPoint2";
static NSString * const qSettingMaxTextNodeWidth = @"MaxTextNodeWidth";
static NSString * const qSettingMaxRootCellTextWidth = @"MaxRootCellTextWidth";
static NSString * const qSettingMindMapViewMargin = @"MindMapViewMargin";
static NSString * const qSettingNodeFocusRingMargin = @"NodeFocusRingMargin";
static NSString * const qSettingNodeFocusRingBorderRadius = @"NodeFocusRingBorderRadius";
static NSString * const qSettingBackgroundColor = @"BackgroundColor";
static NSString * const qSettingDefaultNewNodeWidth = @"DefaultNewNodeWidth";
static NSString * const qSettingDefaultFont = @"DefaultFont";
static NSString * const qSettingDefaultStringAttributeDict = @"DefaultStringAttributeDict";
static NSString * const qSettingDefaultParagraphStyle = @"DefaultParagraphStyle";
static NSString * const qSettingEditSelectedNodeChars = @"EditSelectedNodeChars";
static NSString * const qSettingNewChildNodeChars = @"AppendNewChildNodeChars";
static NSString * const qSettingNewLeftChildNodeChars = @"AppendNewLeftChildNodeChars";
static NSString * const qSettingNewSiblingNodeChars = @"AppendNewSiblingNodeChars";
static NSString * const qSettingDeleteNodeChars = @"DeleteNodeChars";
static NSString * const qSettingDeselectCell = @"DeselectCellChars";
static NSString * const qSettingInterIconDistance = @"IntericonDistance";
static NSString * const qSettingIconDrawSize = @"IconDrawSize";
static NSString * const qSettingIconFont = @"IconFont";
static NSString * const qSettingNodeEditMinWidth = @"NodeEditMinWidth";
static NSString * const qSettingNodeEditMinHeight = @"NodeEditMinHeight";
static NSString * const qSettingNodeEditMaxWidth = @"NodeEditMaxWidth";
static NSString * const qSettingNodeMinWidth = @"NodeMinWidth";
static NSString * const qSettingNodeMinHeight = @"NodeMinHeight";
static NSString * const qSettingFoldingChars = @"FoldingChars";
static NSString * const qSettingIconTextDistance = @"IconTextDistance";

static NSString * const qSettingFoldingMarkerRadius = @"FoldingMarkerRadius";
static NSString * const qSettingFoldingMarkerLineWidth = @"FoldingMarkerLindWidth";

static NSString * const qSettingCellHorizontalPadding = @"CellHorizontalPadding";
static NSString * const qSettingCellVerticalPadding = @"CellVerticalPadding";

/**
* Application-wide settings for Qmind, eg constatns for drawing. These settings are not persistent for now. They'll be
* eventually persisted.
*/
@interface QMAppSettings : NSObject

/**
* General getter for a setting. When the result is a number, an NSNumber is returned.
*/
- (id)settingForKey:(NSString *)key;

/**
* If you want to access CGFloat values, for example folding marker radius, use this method.
*/
- (CGFloat)floatForKey:(NSString *)key;

@end

/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Cocoa/Cocoa.h>

extern NSString * const qSettingInternodeHorizontalDistance;
extern NSString * const qSettingInternodeVerticalDistance;
extern NSString * const qSettingInternodeLineWidth;
extern NSString * const qSettingBezierControlPoint1;
extern NSString * const qSettingBezierControlPoint2;
extern NSString * const qSettingMaxTextNodeWidth;
extern NSString * const qSettingMaxRootCellTextWidth;
extern NSString * const qSettingMindMapViewMargin;
extern NSString * const qSettingNodeFocusRingMargin;
extern NSString * const qSettingNodeFocusRingBorderRadius;
extern NSString * const qSettingBackgroundColor;
extern NSString * const qSettingDefaultNewNodeWidth;
extern NSString * const qSettingDefaultFont;
extern NSString * const qSettingDefaultStringAttributeDict;
extern NSString * const qSettingDefaultParagraphStyle;
extern NSString * const qSettingEditSelectedNodeChars;
extern NSString * const qSettingNewChildNodeChars;
extern NSString * const qSettingNewLeftChildNodeChars;
extern NSString * const qSettingNewSiblingNodeChars;
extern NSString * const qSettingDeleteNodeChars;
extern NSString * const qSettingDeselectCell;
extern NSString * const qSettingInterIconDistance;
extern NSString * const qSettingLinkIconDrawSize;
extern NSString * const qSettingIconDrawSize;
extern NSString * const qSettingIconFont;
extern NSString * const qSettingNodeEditMinWidth;
extern NSString * const qSettingNodeEditMinHeight;
extern NSString * const qSettingNodeEditMaxWidth;
extern NSString * const qSettingNodeMinWidth;
extern NSString * const qSettingNodeMinHeight;
extern NSString * const qSettingFoldingChars;
extern NSString * const qSettingIconTextDistance;

extern NSString * const qSettingFoldingMarkerRadius;
extern NSString * const qSettingFoldingMarkerLineWidth;

extern NSString * const qSettingCellHorizontalPadding;
extern NSString * const qSettingCellVerticalPadding;

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

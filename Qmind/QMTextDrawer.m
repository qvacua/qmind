/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMTextDrawer.h"
#import "QMAppSettings.h"

@implementation QMTextDrawer {
    NSLayoutManager *_layoutManager;
    NSTextStorage *_textStorage;
    NSTextContainer *_textContainer;
}

TB_BEAN

#pragma mark Public
- (void)drawAttributedString:(NSAttributedString *)attrStr inRect:(NSRect)frame range:(NSRange)range {
    @synchronized (_textStorage) {
        [_textStorage setAttributedString:attrStr];
        [_textContainer setContainerSize:frame.size];

        [_layoutManager drawGlyphsForGlyphRange:range atPoint:frame.origin];
    }
}

#pragma mark NSObject
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


@end

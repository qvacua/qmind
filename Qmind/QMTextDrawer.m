/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMTextDrawer.h"
#import "QMAppSettings.h"

@interface QMTextDrawer ()

@property (readonly, strong) NSLayoutManager *layoutManager;
@property (readonly, strong) NSTextStorage *textStorage;
@property (readonly, strong) NSTextContainer *textContainer;

@end

@implementation QMTextDrawer {
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

- (void)drawAttributedString:(NSAttributedString *)attrStr inRect:(NSRect)frame range:(NSRange)range {
    @synchronized (_textStorage) {
        [self.textStorage setAttributedString:attrStr];
        [self.textContainer setContainerSize:frame.size];

        [self.layoutManager drawGlyphsForGlyphRange:range atPoint:frame.origin];
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


@end

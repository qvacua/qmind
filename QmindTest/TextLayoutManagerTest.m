/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMBaseTestCase.h"
#import "QMTextLayoutManager.h"
#import <Qkit/Qkit.h>
#import "QMAppSettings.h"
#import "QMCacaoTestCase.h"

#define INFINITE_WIDTH 10000.0

@interface TextLayoutManagerTest : QMCacaoTestCase
@end

@implementation TextLayoutManagerTest {
    QMTextLayoutManager *manager;
    NSFont *smallFont;
    NSFont *bigFont;
    NSString *shortStr;
    NSString *longStr;
    NSString *multilineStr;
    QMAppSettings *settings;
}

- (void)setUp {
    [super setUp];

    settings = [self.context beanWithClass:[QMAppSettings class]];
    manager = [self.context beanWithClass:[QMTextLayoutManager class]];

    smallFont = [NSFont menuBarFontOfSize:13.0];
    bigFont = [NSFont boldSystemFontOfSize:50.0];

    shortStr = @"short string";
    longStr = @"Jetzt wird es eng für Christian Wulff: Die Staatsanwaltschaft Hannover hat die Aufhebung der Immunität des Bundespräsidenten beantragt. Nach umfassender Prüfung neuer Unterlagen soll es nun einen Anfangsverdacht wegen Vorteilsannahme und Vorteilsgewährung geben. Jetzt muss der Bundestag entscheiden, ob gegen Wulff strafrechtlich ermittelt werden darf.";

    multilineStr = @"aaaa\nbbbb\ncccc";
}

- (void)testRange {
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"test ñ"];
    NSRange range = [manager completeRangeOfAttributedString:attrStr];
    assertThat(@(range.location), is(@(0)));
    assertThat(@(range.length), is(@(6)));
}

- (void)testAttributesDict {
    NSDictionary *attrDict = [manager stringAttributesDictWithFont:bigFont];

    assertThat(attrDict, atKey(NSFontAttributeName, is(bigFont)));

    assertThat(attrDict, hasKey(NSParagraphStyleAttributeName));
    NSParagraphStyle *style = [attrDict objectForKey:NSParagraphStyleAttributeName];
    assertThat(@(style.alignment), is(@(NSLeftTextAlignment)));
    assertThat(@(style.lineBreakMode), is(@(NSLineBreakByWordWrapping)));
}

- (void)testAttributesDictDefault {
    NSDictionary *attrDict = [manager stringAttributesDict];

    assertThat(attrDict, atKey(NSFontAttributeName, is([settings settingForKey:qSettingDefaultFont])));

    assertThat(attrDict, hasKey(NSParagraphStyleAttributeName));

    NSParagraphStyle *style = [attrDict objectForKey:NSParagraphStyleAttributeName];
    assertThat(@(style.alignment), is(@(NSLeftTextAlignment)));
    assertThat(@(style.lineBreakMode), is(@(NSLineBreakByWordWrapping)));
}

- (void)testAttributedStringMeasure {
    NSDictionary *smallAttrDict = [manager stringAttributesDictWithFont:smallFont];
    NSAttributedString *smallString = [[NSAttributedString alloc] initWithString:longStr attributes:smallAttrDict];

    NSDictionary *bigAttrDict = [manager stringAttributesDictWithFont:bigFont];
    NSAttributedString *bigString = [[NSAttributedString alloc] initWithString:longStr attributes:bigAttrDict];

    const CGFloat maxWidth = [settings floatForKey:qSettingMaxTextNodeWidth];
    assertThatSize([manager sizeOfAttributedString:smallString],
                   equalToSize([manager sizeOfAttributedString:smallString maxWidth:maxWidth]));

    assertThatSize([manager sizeOfAttributedString:bigString],
                   equalToSize([manager sizeOfAttributedString:bigString maxWidth:maxWidth]));

    assertThatSize([manager sizeOfAttributedString:smallString maxWidth:INFINITE_WIDTH],
                   smallerThanSize([manager sizeOfAttributedString:bigString maxWidth:INFINITE_WIDTH]));

    assertThatSize([manager sizeOfAttributedString:smallString maxWidth:INFINITE_WIDTH],
                   smallerThanSize([manager sizeOfAttributedString:bigString maxWidth:INFINITE_WIDTH]));
}

- (void)testMeasure {
    assertThatSize([manager sizeOfString:shortStr maxWidth:INFINITE_WIDTH usingFont:smallFont],
                   smallerThanSize([manager sizeOfString:longStr maxWidth:INFINITE_WIDTH usingFont:smallFont]));

    assertThatSize([manager sizeOfString:longStr maxWidth:MAX_CGFLOAT usingFont:smallFont],
                   smallerThanSize([manager sizeOfString:longStr maxWidth:MAX_CGFLOAT usingFont:bigFont]));

    assertThat(@([manager sizeOfString:longStr maxWidth:300 usingFont:smallFont].width),
                    equalToFloat([manager sizeOfString:longStr maxWidth:300 usingFont:bigFont].width));
    assertThatSize([manager sizeOfString:longStr maxWidth:300 usingFont:smallFont],
                   smallerThanSize([manager sizeOfString:longStr maxWidth:300 usingFont:bigFont]));

    assertThat(@([manager widthOfString:shortStr]),
                    greaterThanFloat([manager widthOfString:multilineStr]));
    assertThat(@([manager sizeOfString:shortStr maxWidth:MAX_CGFLOAT].height),
                    lessThanFloat([manager sizeOfString:multilineStr maxWidth:MAX_CGFLOAT].height));
}

@end

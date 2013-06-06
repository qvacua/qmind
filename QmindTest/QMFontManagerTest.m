/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase.h"
#import "QMFontManager.h"
#import "QMAppSettings.h"
#import "QMCacaoTestCase.h"

@interface QMFontManagerTest : QMCacaoTestCase @end

@implementation QMFontManagerTest {
    QMFontManager *fontManager;
    NSFont *defaultFont;

    NSFontManager *nsFontManager;
}

- (void)setUp {
    [super setUp];

    fontManager = [self.context beanWithClass:[QMFontManager class]];
    defaultFont = [[self.context beanWithClass:[QMAppSettings class]] settingForKey:qSettingDefaultFont];
    nsFontManager = [self.context beanWithClass:[NSFontManager class]];
}

- (void)testFontawesomeFont {
    assertThat(fontManager.fontawesomeFont.fontName, containsString(@"fontawesome"));
}

- (void)testSimpleToXml {
    NSFont *font = [NSFont fontWithName:@"Times" size:200];

    NSDictionary *result = [fontManager fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", is(@"Times")));
    assertThat(result, atKey(@"SIZE", is(@"200")));
}

- (void)testTraitsToXml {
    NSFont *font = [NSFont fontWithName:@"Times" size:200];
    font = [nsFontManager convertFont:font toHaveTrait:NSFontItalicTrait];

    NSDictionary *result = [fontManager fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", is(@"Times")));
    assertThat(result, atKey(@"SIZE", is(@"200")));
    assertThat(result, atKey(@"ITALIC", is(@"true")));
    assertThat(result, hasSize(3));

    font = [nsFontManager convertFont:font toHaveTrait:NSFontBoldTrait];
    font = [nsFontManager convertFont:font toNotHaveTrait:NSFontItalicTrait];
    result = [fontManager fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", is(@"Times")));
    assertThat(result, atKey(@"SIZE", is(@"200")));
    assertThat(result, atKey(@"BOLD", is(@"true")));
    assertThat(result, hasSize(3));

    font = [nsFontManager convertFont:font toHaveTrait:NSFontBoldTrait];
    font = [nsFontManager convertFont:font toHaveTrait:NSFontItalicTrait];
    result = [fontManager fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", is(@"Times")));
    assertThat(result, atKey(@"SIZE", is(@"200")));
    assertThat(result, atKey(@"BOLD", is(@"true")));
    assertThat(result, atKey(@"ITALIC", is(@"true")));
    assertThat(result, hasSize(4));
}

/**
* @bug
*/
- (void)testCustomFontWithStandardSize {
    NSFont *font = [nsFontManager convertFont:defaultFont toHaveTrait:NSFontBoldTrait];
    NSDictionary *result = [fontManager fontAttrDictFromFont:font];

    assertThat(result, atKey(@"SIZE", is([@([defaultFont pointSize]) stringValue])));
    assertThat(result, atKey(@"BOLD", is(@"true")));
    assertThat(result, hasSize(2));
}

- (void)testDefaultToNil {
    NSDictionary *result = [fontManager fontAttrDictFromFont:defaultFont];
    assertThat(result, nilValue());
}

- (void)testSimpleFontFromXml {
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] init];
    [attrDict setObject:@"Times" forKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];

    NSFont *result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is(@"Times"));
    assertThat(@(result.pointSize), is(@(100)));

    [attrDict removeObjectForKey:@"SIZE"];
    result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is(@"Times"));
    assertThat(@(result.pointSize), is(@([defaultFont pointSize])));

    [attrDict removeObjectForKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];
    result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is([defaultFont familyName]));
    assertThat(@(result.pointSize), is(@(100)));

    [attrDict setObject:@"fdsjklfdjs" forKey:@"NAME"];
    result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is([defaultFont familyName]));
    assertThat(@(result.pointSize), is(@(100)));
}

- (void)testWithTraitsFromXml {
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] init];
    [attrDict setObject:@"Times" forKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];
    [attrDict setObject:@"true" forKey:@"ITALIC"];

    NSFont *result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is(@"Times"));
    assertThat(@(result.pointSize), is(@(100)));
    assertThatBool([nsFontManager traitsOfFont:result] & NSFontItalicTrait, isTrue);

    [attrDict removeObjectForKey:@"ITALIC"];
    [attrDict setObject:@"true" forKey:@"BOLD"];

    result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is(@"Times"));
    assertThat(@(result.pointSize), is(@(100)));
    assertThatBool([nsFontManager traitsOfFont:result] & NSFontBoldTrait, isTrue);

    [attrDict setObject:@"true" forKey:@"ITALIC"];

    result = [fontManager fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, is(@"Times"));
    assertThat(@(result.pointSize), is(@(100)));
    assertThatBool([nsFontManager traitsOfFont:result] & NSFontBoldTrait, isTrue);
    assertThatBool([nsFontManager traitsOfFont:result] & NSFontItalicTrait, isTrue);
}

@end

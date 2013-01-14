#import "QMBaseTestCase.h"
#import "QMFontConverter.h"
#import "QMAppSettings.h"
#import "QMCacaoTestCase.h"

@interface FontConverterTest : QMCacaoTestCase @end

@implementation FontConverterTest {
    QMFontConverter *fontConverter;
    NSFont *defaultFont;

    NSFontManager *fontManager;
}

- (void)setUp {
    [super setUp];

    fontConverter = [self.context beanWithClass:[QMFontConverter class]];
    defaultFont = [[self.context beanWithClass:[QMAppSettings class]] settingForKey:qSettingDefaultFont];
    fontManager = [NSFontManager sharedFontManager];
}

- (void)testSimpleToXml {
    NSFont *font = [NSFont fontWithName:@"Times" size:200];

    NSDictionary *result = [fontConverter fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", equalTo(@"Times")));
    assertThat(result, atKey(@"SIZE", equalTo(@"200")));
}

- (void)testTraitsToXml {
    NSFont *font = [NSFont fontWithName:@"Times" size:200];
    font = [fontManager convertFont:font toHaveTrait:NSFontItalicTrait];

    NSDictionary *result = [fontConverter fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", equalTo(@"Times")));
    assertThat(result, atKey(@"SIZE", equalTo(@"200")));
    assertThat(result, atKey(@"ITALIC", equalTo(@"true")));
    assertThat(result, hasSize(3));

    font = [fontManager convertFont:font toHaveTrait:NSFontBoldTrait];
    font = [fontManager convertFont:font toNotHaveTrait:NSFontItalicTrait];
    result = [fontConverter fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", equalTo(@"Times")));
    assertThat(result, atKey(@"SIZE", equalTo(@"200")));
    assertThat(result, atKey(@"BOLD", equalTo(@"true")));
    assertThat(result, hasSize(3));

    font = [fontManager convertFont:font toHaveTrait:NSFontBoldTrait];
    font = [fontManager convertFont:font toHaveTrait:NSFontItalicTrait];
    result = [fontConverter fontAttrDictFromFont:font];
    assertThat(result, atKey(@"NAME", equalTo(@"Times")));
    assertThat(result, atKey(@"SIZE", equalTo(@"200")));
    assertThat(result, atKey(@"BOLD", equalTo(@"true")));
    assertThat(result, atKey(@"ITALIC", equalTo(@"true")));
    assertThat(result, hasSize(4));
}

/**
* BUG
*/
- (void)testCustomFontWithStandardSize {
    NSFont *font = [fontManager convertFont:defaultFont toHaveTrait:NSFontBoldTrait];
    NSDictionary *result = [fontConverter fontAttrDictFromFont:font];

    assertThat(result, atKey(@"SIZE", equalTo([[NSNumber numberWithFloat:[defaultFont pointSize]] stringValue])));
    assertThat(result, atKey(@"BOLD", equalTo(@"true")));
    assertThat(result, hasSize(2));
}

- (void)testDefaultToNil {
    NSDictionary *result = [fontConverter fontAttrDictFromFont:defaultFont];
    assertThat(result, nilValue());
}

- (void)testSimpleFontFromXml {
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] init];
    [attrDict setObject:@"Times" forKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];

    NSFont *result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo(@"Times"));
    assertThatFloat(result.pointSize, equalToFloat(100));

    [attrDict removeObjectForKey:@"SIZE"];
    result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo(@"Times"));
    assertThatFloat(result.pointSize, equalToFloat([defaultFont pointSize]));

    [attrDict removeObjectForKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];
    result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo([defaultFont familyName]));
    assertThatFloat(result.pointSize, equalToFloat(100));

    [attrDict setObject:@"fdsjklfdjs" forKey:@"NAME"];
    result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo([defaultFont familyName]));
    assertThatFloat(result.pointSize, equalToFloat(100));
}

- (void)testWithTraitsFromXml {
    NSMutableDictionary *attrDict = [[NSMutableDictionary alloc] init];
    [attrDict setObject:@"Times" forKey:@"NAME"];
    [attrDict setObject:@"100" forKey:@"SIZE"];
    [attrDict setObject:@"true" forKey:@"ITALIC"];

    NSFont *result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo(@"Times"));
    assertThatFloat(result.pointSize, equalToFloat(100));
    assertThatBool([fontManager traitsOfFont:result] & NSFontItalicTrait, isTrue);

    [attrDict removeObjectForKey:@"ITALIC"];
    [attrDict setObject:@"true" forKey:@"BOLD"];

    result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo(@"Times"));
    assertThatFloat(result.pointSize, equalToFloat(100));
    assertThatBool([fontManager traitsOfFont:result] & NSFontBoldTrait, isTrue);

    [attrDict setObject:@"true" forKey:@"ITALIC"];

    result = [fontConverter fontFromFontAttrDict:attrDict];
    assertThat(result.familyName, equalTo(@"Times"));
    assertThatFloat(result.pointSize, equalToFloat(100));
    assertThatBool([fontManager traitsOfFont:result] & NSFontBoldTrait, isTrue);
    assertThatBool([fontManager traitsOfFont:result] & NSFontItalicTrait, isTrue);
}

@end

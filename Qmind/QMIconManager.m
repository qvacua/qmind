/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMIconManager.h"
#import <Qkit/Qkit.h>
#import <TBCacao/TBCacao.h>

static NSString * const KindKey = @"kind";
static NSString * const UnicodeValue = @"unicode";
static NSString * const FilaNameKey = @"filename";
static NSString * const PdfValue = @"pdf";

@implementation QMIconManager {
    NSDictionary *_conversionDict;
    NSArray *_iconCodes;
}

TB_BEAN

@synthesize iconCodes = _iconCodes;

- (id)init {
    if ((self = [super init])) {
        NSURL *path = [[NSBundle bundleForClass:self.class] URLForResource:@"IconsFreeMindToQmind" withExtension:@"plist"];
        NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfURL:path];

        _conversionDict = [plistDict objectForKey:@"FreeMindIconCodeToUnicode"];

        NSMutableArray *tempIconArray = [[NSMutableArray alloc] init];
        [[_conversionDict allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger index, BOOL *stop) {
            if ([[_conversionDict[key] objectForKey:@"supported"] boolValue] == YES) {
                [tempIconArray addObject:key];
            }
        }];
        [tempIconArray sortUsingSelector:@selector(compare:)];
        _iconCodes = [[NSArray alloc] initWithArray:tempIconArray];
    }

    return self;
}

- (id)iconRepresentationForCode:(NSString *)iconCode {
    NSDictionary *iconDesc = [_conversionDict objectForKey:iconCode];

    if (iconDesc == nil) {
        log4Warn(@"Unknown Icon found: %@. Falling back to a dummy icon.", iconCode);

        NSString *fileName = [iconDesc objectForKey:@"dummy"];
        NSURL *path = [[NSBundle bundleForClass:self.class] URLForResource:fileName withExtension:PdfValue];

        NSImage *image = [[NSImage alloc] initWithContentsOfURL:path];
        [image setFlipped:YES];

        return image;
    }

    NSString *kind = [iconDesc objectForKey:KindKey];
    if ([kind isEqualToString:UnicodeValue]) {
        return [iconDesc objectForKey:@"value"];
    }

    if ([kind isEqualToString:PdfValue]) {
        NSString *fileName = [iconDesc objectForKey:FilaNameKey];
        NSString *fileNameWoExt = [fileName substringToIndex:fileName.length - 4];
        NSURL *path = [[NSBundle bundleForClass:self.class] URLForResource:fileNameWoExt withExtension:PdfValue];

        NSImage *image = [[NSImage alloc] initWithContentsOfURL:path];
        [image setFlipped:YES];

        return image;
    }
    
    return nil;
}

- (QMIconKind)kindForCode:(NSString *)iconCode {
    NSDictionary *iconDesc = [_conversionDict objectForKey:iconCode];
    NSString *kind = [iconDesc objectForKey:KindKey];

    if ([kind isEqualToString:UnicodeValue]) {
        return QMIconKindString;
    }

    if ([kind isEqualToString:PdfValue]) {
        return QMIconKindImage;
    }
    
    return QMIconKindNone;
}

@end

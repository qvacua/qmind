/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>
#import <TBCacao/TBCacao.h>
#import "QMBaseTestCase.h"

@interface QMCacaoTestCase : QMBaseTestCase

@property (readonly) TBContext *context;

-(void)replaceBeans:(NSArray *)targetSources;

@end

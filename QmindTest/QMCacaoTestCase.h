/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
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

/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>
#import "QMMindmapViewDataSource.h"

@class QMDocument, QMIconManager;

@interface QMMindmapViewDataSourceImpl : NSObject <QMMindmapViewDataSource>

@property (weak) QMAppSettings *settings;
@property (weak) QMIconManager *iconManager;

- (id)initWithDoc:(QMDocument *)doc view:(QMMindmapView *)view;

@end

/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import "QMLookUtil.h"
#import "QMRootCell.h"
#import "QMCellPropertiesManager.h"
#import "QMMindmapViewDataSourceImpl.h"
#import "QMDocument.h"

@implementation QMLookUtil

+ (QMRootCell *)rootCellForUrl:(NSURL *)url {
    QMDocument *doc = [[QMDocument alloc] init];
    doc.fileURL = url;

    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initWithURL:url options:(NSFileWrapperReadingOptions) 0 error:NULL];
    BOOL success = [doc readFromFileWrapper:fileWrapper ofType:nil error:NULL];

    if (!success) {
        return nil;
    }

    QMMindmapViewDataSourceImpl *dataSource = [[QMMindmapViewDataSourceImpl alloc] initWithDoc:doc view:nil];
    QMCellPropertiesManager *cellPropertiesManager = [[QMCellPropertiesManager alloc] initWithDataSource:dataSource];

    QMRootCell *rootCell = (QMRootCell *) [cellPropertiesManager cellWithParent:nil itemOfParent:nil];
    rootCell.familyOrigin = NSMakePoint(0, 0);
    [rootCell computeGeometry];

    NSSize canvasSize = rootCell.familySize;
    canvasSize.width += 25;
    canvasSize.height += 25;

    return rootCell;
}

@end

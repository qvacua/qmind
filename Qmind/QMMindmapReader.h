/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>

@class QMProxyNode;
@class QMDocument;
@class QMRootNode;
@protocol TBBean;

/**
* A mindmap document model which uses the Node class to internally represent the mindmap node. Reads the mindmap XML file
* event-driven and builds up the rootNode.
*
* @implements NSXMLParserDelegate
*/
@interface QMMindmapReader : NSObject <TBBean, NSXMLParserDelegate>

- (QMRootNode *)rootNodeForFileUrl:(NSURL *)fileUrl;

@end

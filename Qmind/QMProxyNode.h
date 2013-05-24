/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <Foundation/Foundation.h>

@class QMNode;
@class QMMindmapReader;
@class QMRootNode;
@class QMFontManager;

/**
* Helper class to build up the mindmap internally using event-driven xml reading and the class QMNode.
* 
* @see QMNode
*/
@interface QMProxyNode : NSObject <NSXMLParserDelegate>

/**
* The initializer to use when creating a non-root ProxyNode
*/
- (id)initWithParent:(QMProxyNode *)parent node:(QMNode *)node;

/**
* The initializer to use when encountering the root node
*/
- (id)initAsRootNode:(QMRootNode *)node;

/**
* The initializer to use when encountering an unsupported xml element
*/
- (id)initAsUnsupportedXmlElement:(NSXMLElement *)xmlElement withParent:(QMProxyNode *)parent;

@end


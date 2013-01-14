/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMMindmapWriter.h"
#import "QMNode.h"
#import "QMDocument.h"
#import "QMFontConverter.h"
#import "QMRootNode.h"

@implementation QMMindmapWriter

TB_BEAN

#pragma mark Public
- (NSData *)dataForRootNode:(QMRootNode *)rootNode {
    NSXMLElement *mapElement = [[NSXMLElement allocWithZone:nil] initWithName:@"map"];
    NSXMLNode *versionNode = [NSXMLNode attributeWithName:@"version" stringValue:qMindmapVersion];

    [mapElement addAttribute:versionNode];
    [mapElement addChild:[self nodeToXmlNode:rootNode left:NO]];

    NSXMLDocument *xmlDoc = [[NSXMLDocument allocWithZone:nil] initWithRootElement:mapElement];
    /**
    * NSXMLNodePrettyPrint will destroy characters in HTML element, for example, from
    *
    * a <b>b c<u>d e</u> f g</b> h i
    *
    * NSXMLNodePrettyPrint will make
    *
    *  a <b>b c<u>d e</u>
    *                                f g</b>
    *                            h i
    */
    NSData *xmlData = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLDocumentTidyXML | NSXMLNodeCompactEmptyElement];

    return xmlData;
}

#pragma mark Private
- (NSXMLElement *)nodeToXmlNode:(QMNode *)node left:(BOOL)isLeft {
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"node"];
    NSMutableDictionary *const attributes = [NSMutableDictionary dictionaryWithDictionary:node.attributes];

    if (isLeft) {
        [attributes setObject:@"left" forKey:qNodePositionAttributeKey];
    }

    [element setAttributesWithDictionary:attributes];

    for (NSString *iconCode in node.icons) {
        NSXMLElement *iconXmlElement = [[NSXMLElement alloc] initWithName:@"icon"];
        [iconXmlElement setAttributesWithDictionary:[NSDictionary dictionaryWithObject:iconCode forKey:@"BUILTIN"]];
        [element addChild:iconXmlElement];
    }

    NSArray *children = node.children;
    for (QMNode *childNode in children) {
        [element addChild:[self nodeToXmlNode:childNode left:NO]];
    }

    if ([node isRoot]) {
        NSArray *leftChildren = [(QMRootNode *) node leftChildren];
        for (QMNode *leftChildNode in leftChildren) {
            [element addChild:[self nodeToXmlNode:leftChildNode left:YES]];
        }
    }

    NSFont *font = node.font;
    if (font != nil) {
        NSDictionary *attrDictFromFont = [[QMFontConverter sharedConverter] fontAttrDictFromFont:font];

        if (attrDictFromFont != nil) {
            NSXMLElement *fontElement = [[NSXMLElement allocWithZone:nil] initWithName:@"font"];
            [fontElement setAttributesWithDictionary:attrDictFromFont];
            [element addChild:fontElement];
        }
    }

    NSArray *unsupportedChildren = node.unsupportedChildren;
    for (NSString *unsupportedChildAsString in unsupportedChildren) {
        NSXMLElement *xmlElement = [[NSXMLElement allocWithZone:nil] initWithXMLString:unsupportedChildAsString error:nil];
        [element addChild:xmlElement];
    }

    return element;
}

@end

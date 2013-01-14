/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import "QMProxyNode.h"
#import "QMNode.h"
#import "QMMindmapReader.h"
#import "QMFontConverter.h"
#import "QMRootNode.h"

@implementation QMProxyNode {
    __weak QMProxyNode *_parent;
    NSMutableArray *_children;

    id _node;
    NSXMLElement *_unsupportedXmlElement;

    __weak QMMindmapReader *_reader;
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser
        didStartElement:(NSString *)elementName
           namespaceURI:(NSString *)namespaceURI
          qualifiedName:(NSString *)qName
             attributes:(NSDictionary *)anAttributeDict {

    NSMutableDictionary *attributeDict = [[NSMutableDictionary alloc] initWithDictionary:anAttributeDict];

    if ([elementName isEqualToString:@"node"]) {

        if ([[attributeDict objectForKey:qNodePositionAttributeKey] isEqualToString:@"right"]) {
            [attributeDict removeObjectForKey:qNodePositionAttributeKey];
        }

        QMNode *childNode = [[QMNode alloc] initWithAttributes:attributeDict];

        if ([_node isRoot]) {
            if ([[attributeDict objectForKey:qNodePositionAttributeKey] isEqualToString:@"left"]) {
                [_node addObjectInLeftChildren:childNode];
            } else {
                [_node addObjectInChildren:childNode];
            }
        } else {
            [_node addObjectInChildren:childNode];
        }

        QMProxyNode *proxyNode = [[QMProxyNode alloc] initWithParent:self node:childNode mindmapReader:_reader];
        [_children addObject:proxyNode];

        [parser setDelegate:proxyNode];

        return;
    }

    if ([elementName isEqualToString:@"icon"]) {
        NSString *iconCode = [attributeDict objectForKey:@"BUILTIN"];
        if (iconCode.length == 0) {
            return;
        }

        [_node insertObject:iconCode inIconsAtIndex:[_node countOfIcons]];
        return;
    }

    if ([elementName isEqualToString:@"font"]) {
        [_node setFont:[[QMFontConverter sharedConverter] fontFromFontAttrDict:attributeDict]];

        return;
    }

    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:elementName];
    [xmlElement setAttributesWithDictionary:attributeDict];

    QMProxyNode *proxyNode = [[QMProxyNode alloc] initAsUnsupportedXmlElement:xmlElement
                                                                   withParent:self
                                                                mindmapReader:_reader];

    [_children addObject:proxyNode];

    if ([self isUnsupportedElement]) {
        [_unsupportedXmlElement addChild:xmlElement];
    } else {
        // if this element is a "NODE"
        [[_node unsupportedChildren] addObject:xmlElement];
    }

    [parser setDelegate:proxyNode];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self isUnsupportedElement]) {
        NSXMLNode *xmlString = [NSXMLNode textWithStringValue:string];
        [_unsupportedXmlElement addChild:xmlString];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {

    if ([elementName isEqualToString:@"node"]) {

        /**
        * Convert NSXMLElements representing unsupported elements to xml strings.
        * This way, we can use NSCoding for drag and drop and copy/paste.
        */
        NSMutableArray *unsupportedChildren = [_node unsupportedChildren];
        NSMutableArray *unsupportedChildrenAsString = [[NSMutableArray alloc] initWithCapacity:unsupportedChildren.count];

        for (NSXMLElement *unsupportedXmlElement in unsupportedChildren) {
            [unsupportedChildrenAsString addObject:unsupportedXmlElement.XMLString];
        }

        [unsupportedChildren removeAllObjects];
        [unsupportedChildren addObjectsFromArray:unsupportedChildrenAsString];

        if (_parent == nil) {
            [parser setDelegate:_reader];
        } else {
            [parser setDelegate:_parent];
        }

        return;

    }

    if ([elementName isEqualToString:_unsupportedXmlElement.name]) {

        [parser setDelegate:_parent];
        return;

    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

    log4Warn(@"An error occurred: %@", parseError);

}

#pragma mark Initializer
- (id)initWithParent:(QMProxyNode *)parent node:(QMNode *)node mindmapReader:(QMMindmapReader *)reader {
    if ((self = [super init])) {
        _parent = parent;

        _node = node;
        _reader = reader;

        _children = [[NSMutableArray alloc] initWithCapacity:3];
    }

    return self;
}

- (id)initAsRootNode:(QMRootNode *)node mindmapReader:(QMMindmapReader *)reader {
    if ((self = [super init])) {
        _node = node;
        _reader = reader;

        _children = [[NSMutableArray alloc] initWithCapacity:5];
    }

    return self;
}

- (id)initAsUnsupportedXmlElement:(NSXMLElement *)xmlElement
                       withParent:(QMProxyNode *)parent
                    mindmapReader:(QMMindmapReader *)reader {
    if ((self = [super init])) {
        _node = nil;
        _reader = reader;
        _unsupportedXmlElement = xmlElement;
        _parent = parent;

        _children = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark Private
- (BOOL)isUnsupportedElement {
    return _node == nil;
}

@end

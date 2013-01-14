/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMProxyNode.h"
#import "QMNode.h"
#import "QMMindmapReader.h"
#import "QMFontConverter.h"
#import "QMRootNode.h"

@implementation QMProxyNode {
    __weak QMFontConverter *_fontConverter;
    __weak QMMindmapReader *_reader;

    __weak QMProxyNode *_parent;
    NSMutableArray *_children;

    id _node;
    NSXMLElement *_unsupportedXmlElement;
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

        QMProxyNode *proxyNode = [[QMProxyNode alloc] initWithParent:self node:childNode];
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
        [_node setFont:[_fontConverter fontFromFontAttrDict:attributeDict]];

        return;
    }

    NSXMLElement *xmlElement = [[NSXMLElement alloc] initWithName:elementName];
    [xmlElement setAttributesWithDictionary:attributeDict];

    QMProxyNode *proxyNode = [[QMProxyNode alloc] initAsUnsupportedXmlElement:xmlElement withParent:self];

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
- (id)initWithParent:(QMProxyNode *)parent node:(QMNode *)node {
    if ((self = [super init])) {
        _reader = [[TBContext sharedContext] beanWithClass:[QMMindmapReader class]];

        _parent = parent;
        _node = node;

        _children = [[NSMutableArray alloc] initWithCapacity:3];
        _fontConverter = [[TBContext sharedContext] beanWithClass:[QMFontConverter class]];
    }

    return self;
}

- (id)initAsRootNode:(QMRootNode *)node {
    if ((self = [super init])) {
        _reader = [[TBContext sharedContext] beanWithClass:[QMMindmapReader class]];

        _node = node;

        _children = [[NSMutableArray alloc] initWithCapacity:5];
        _fontConverter = [[TBContext sharedContext] beanWithClass:[QMFontConverter class]];
    }

    return self;
}

- (id)initAsUnsupportedXmlElement:(NSXMLElement *)xmlElement withParent:(QMProxyNode *)parent {
    if ((self = [super init])) {
        _reader = [[TBContext sharedContext] beanWithClass:[QMMindmapReader class]];

        _node = nil;
        _unsupportedXmlElement = xmlElement;
        _parent = parent;

        _children = [[NSMutableArray alloc] init];
        _fontConverter = [[TBContext sharedContext] beanWithClass:[QMFontConverter class]];
    }

    return self;
}

#pragma mark Private
- (BOOL)isUnsupportedElement {
    return _node == nil;
}

@end

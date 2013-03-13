/**
 * Tae Won Ha
 * http://qvacua.com
 * https://github.com/qvacua
 *
 * See LICENSE
 */

#import <TBCacao/TBCacao.h>
#import "QMMindmapReader.h"
#import "QMNode.h"
#import "QMProxyNode.h"
#import "QMRootNode.h"

static NSString * const qMapKey = @"map";
static NSString * const qDefaultsVersionKey = @"version";
static NSString * const qNodeKey = @"node";

@implementation QMMindmapReader {
    NSURL *_fileUrl;

    QMRootNode *_rootNode;
    QMProxyNode *_proxyRoot;
}

TB_BEAN

#pragma mark Public
- (QMRootNode *)rootNodeForFileUrl:(NSURL *)fileUrl {
    _fileUrl = fileUrl;

    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
        log4Warn(@"File %@ does not exist!", [fileUrl path]);
        return nil;
    }

    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:_fileUrl];

    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:NO];

    [xmlParser parse];

    return _rootNode;
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser
        didStartElement:(NSString *)elementName
           namespaceURI:(NSString *)namespaceURI
          qualifiedName:(NSString *)qName
             attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:qMapKey]) {
        // This is the map node which contains everything
        NSString *version = [attributeDict objectForKey:qDefaultsVersionKey];
        log4Debug(@"MindMap version: %@", version);

        return;
    }

    if ([elementName isEqualToString:qNodeKey]) {

        // This is the root node
        _rootNode = [[QMRootNode alloc] initWithAttributes:attributeDict];
        _proxyRoot = [[QMProxyNode alloc] initAsRootNode:_rootNode];

        [parser setDelegate:_proxyRoot];

        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
    log4Debug(@"comment encountered: %@", [comment stringByCropping]);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    log4Warn(@"An error occurred reading the file %@: %@", _fileUrl, parseError);
}

@end

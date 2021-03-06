////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DCHTTPResponseSerializer.m
//
//  Created by Dalton Cherry on 5/8/14.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

#import "DCHTTPResponseSerializer.h"

@implementation DCHTTPResponseSerializer

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)responseObjectFromResponse:(NSURLResponse*)response
                           data:(NSData*)data
                          error:(NSError *__autoreleasing *)error
{
    //this does nothing by default
    return data;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)copyWithZone:(NSZone*)zone
{
    DCHTTPResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    serializer.stringEncoding = self.stringEncoding;
    return serializer;
}
////////////////////////////////////////////////////////////////////////////////////////////////////

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DCJSONResponseSerializer

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)responseObjectFromResponse:(NSURLResponse*)response
                           data:(NSData*)data
                          error:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

@end
////////////////////////////////////////////////////////////////////////////////////////////////////

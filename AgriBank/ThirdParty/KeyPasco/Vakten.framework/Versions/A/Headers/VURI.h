#import <Foundation/Foundation.h>

/*!_
 * Despite the name this class implementsa a "URI reference" according to
 * RFC 3986. A URI reference is either a normal URI, meaning that it begins
 * with a scheme components such as "http:" or is a relative reference that
 * doesn't have a scheme component.
 */
@interface VURI : NSObject

@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *port;
@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong, readonly) NSURL *URL;

/*!
 Creates a VURI given a string.
 @see VURI#initWithString:
 @param string A NSString
 @return An URI object initialized. If the string was malformed or nil, returns nil
 */
+ (instancetype)URIWithString:(NSString *)string;

/*!
 Creates a VURI given a string.
 @param string A NSString
 @return An URI object initialized. If the string was malformed or nil, returns nil
 */
- (instancetype)initWithString:(NSString *)string;

/*!
 Creates a VURI given a URL.
 @param URL A NSURL
 @return An URI object initialized. If the URL was malformed or nil, returns nil
 */
- (instancetype)initWithURL:(NSURL *)URL;

/*!
 Adds a name-value pair to the query string. Does nothing if either name or
 value is nil.
 @param name The name for the value. 
 @param value The vakue to query
 */
- (void)addQueryName:(NSString *)name value:(NSString *)value;

/**
 Returns the value associated with a given name.
 @param name The name for which to return the corresponding value
 @return The value associated with name, or nil if no value is associated with name
 */
- (NSString *)valueForQueryName:(NSString *)name;

@end

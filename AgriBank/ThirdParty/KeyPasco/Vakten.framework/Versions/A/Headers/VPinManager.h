#import <Foundation/Foundation.h>

/*!
 PinManager is used to handle pin in a secure way. Instead of storing the pin as a string every new character of the pin
 should be inputed to PinManager as soon as possible.
 */
@interface VPinManager : NSObject

/*!
 A string with the correct amount of stars that can be used to indicate to the user that the input was registered.
 */
@property(strong, nonatomic, readonly) NSString *obfuscatedPin;

/*!
 The length of the pin.
 */
@property(nonatomic, readonly) NSUInteger length;

/*!
 @brief Appends a character to the pin.

 @discussion This methods appends the character to the pin and returns a BOOL if it was successful or not. If anything
 other than an char containing a decimal is given it will return false.

 @param character The char to add to pin. Only decimal chars are accepted.
 @return Result if the append was successful.
 */
- (BOOL)appendCharacter:(NSString *)character;

/*!
 @brief Removes the last appended character to the pin.
 */
- (void)removeLastInput;

/*!
 @brief Clears the pin.
 */
- (void)clear;

@end

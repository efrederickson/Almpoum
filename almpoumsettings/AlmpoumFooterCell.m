#import "AlmpoumFooterCell.h"

@interface PSTableCell (Almpoum)
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end

@implementation AlmpoumFooterCell
- (id)initWithSpecifier:(PSSpecifier *)specifier{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell" specifier:specifier];
    if (self) {
        UIImage *background = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/AlmpoumSettings.bundle"] pathForResource:@"almpoumFooter" ofType:@"png"]];
        _background = [[UIImageView alloc] initWithImage:background];
        [self addSubview:_background];
    }
    
    return self;
}

- (float)preferredHeightForWidth:(float)arg1{
    return 100.f /* image height */;
}
@end
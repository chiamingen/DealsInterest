@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
-(void) showLoginScreen:(BOOL)animated;
-(void) showHomeScreen:(BOOL)animated;
-(void) showOthersProfileScreen:(BOOL)animated otherUserID:(NSString *)otherUserID navController:(UINavigationController *)navController;
-(void) showItemScreen:(NSInteger)itemID itemName:(NSString *)itemName isEditable:(BOOL)isEditable navController:(UINavigationController *)navController;
-(void) showItemScreen2:(NSInteger)itemID itemName:(NSString *)itemName isEditable:(BOOL)isEditable navController:(UINavigationController *)navController;
-(void) updatePushToken;
-(void) showMainScreen;

@property UIViewController *tmpViewController;
@end
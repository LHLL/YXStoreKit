# YXStoreKit
Provides closure based API for StoreKit. Handles multi login support for clients that sell auto-renewable subscriptions via In-App Purchase.

Test coverage
![unit test coverage](https://github.com/LHLL/YXStoreKit/blob/master/Documents/Screen%20Shot%202020-01-18%20at%202.44.45%20PM.png)

Features:
1. Provides fake objects for integration testing without make real server calls.
2. Can be used with or without a backend server.
3. Closure based API.

Usage:
1. Use without a server:
  a. Implements [YXReceiptValidator] to hook up with your server and use YXLocalUserManager.
  b. Creates an instance of [YXStoreKit.swift] and put it in your App Delegate. (The key is to make sure you only have one instance of this class during the whole life cycle of your app.)
  c. Try to get a YXUserObject when app launches and user account switches if your app has account system such as login with Google.
  d. As soon as you get an user object, call [start] method in the YXStoreKit.swift.
2. Use with a server:
  a. Implements protocol [YXUserManager] and [YXReceiptValidator] to hook up with your server.
  b. Creates an instance of [YXStoreKit.swift] and put it in your App Delegate. (The key is to make sure you only have one instance of this class during the whole life cycle of your app.)
  c. Try to get a YXUserObject when app launches and user account switches if your app has account system such as login with Google.
  d. As soon as you get an user object, call [start] method in the YXStoreKit.swift.
  
Sample Code:
```
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private(set) var storeKit:YXStoreKit!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let userManager = YXLocalUserManager(userIdentifier: <Your user identifier>,
                                             productIdentifiers: <Your product identifiers>)
        if (storeKit == nil) {
          let productBuilder = YXProductRequestBuilderImpl()
          let productServiceYXProductServiceImpl(builder: builder)
          let validator = YourValidator()
          let refresherBuilder = YXReceiptRefreshRequestBuilderImpl()
          let refresher = YXReceiptRefresherImpl(requestBuilder:refresherBuilder)
          let receiptManager = YXReceiptManagerImpl(receiptValidator: validator,
                                                    receiptRefresher: refresher)
          let trasnactionManager = YXTransactionManagerImpl(receiptManager: receiptManager,
                                                            userManager: userManager)
          let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        }
        let queue = DispatchQueue.global()
        queue.async {
            userManager.user(callbackQueue: queue) {[weak self] (user, error) in
                guard error == nil else {
                    // Handles error here.
                    return
                }
                storeKit.start(callbackQueue: queue) { (errors) in
                    // Handles error here.
                }
            }
        }
        return true
    }
}

class ProductsViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global().async {
            self.appDelegate.storeKit.products(callbackQueue: .main){ [weak self] (products, invalids, error) in
              // Handles UI or error.
              // self.tableView.reload()
            }
        }
    } 
}

class PurchaseViewController:UIViewController {
    
    @IBAction func buy(_ sender: UIButton) {
       DispatchQueue.global().async {
            self.appDelegate.storeKit.purchase(product: self.product, 
                                               quantity:2, 
                                               callbackQueue: .main){ [weak self] (error) in
              // Handles UI or error.
              // self.showSucceedUI()
            }
        }
    }
}
```

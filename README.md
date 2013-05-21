CZDateFormatterCache
====================

Anyone who has profiled scroll performance of a UITableView whose cells render dates knows
how slow it is create `NSDateFormatter` instances. `CZDateFormatterCache` creates a global
cache of `NSDateFormatter` instances -- created the first time you use the cache -- that
can be shared by all of your UI code, as in:

    NSDate *date = ...;

    cell.detailTextLabel.text = [[CZDateFormatterCache mainThreadCache] localizedStringFromDate:date dateStyle:kCFDateFormatterShortStyle timeStyle:kCFDateFormatterShortStyle];

Since `NSDateFormatter` instances are *not* thread safe, you should only use the cache from the
"main" thread. In fact, `CZDateFormatterCache` asserts if you try to use the cache from another
thread.

Credits
-------

CZDateFormatterCache was created by [Peyman Oreizy](https://github.com/peymano) and [Brian Cooke](https://github.com/bricooke) in the development of [CareZone Mobile for iOS](https://itunes.apple.com/us/app/carezone-mobile/id552197945).

Contact
-------

Peyman Oreizy @peymano

Brian Cooke @bricooke

License
-------

CZDateFormatterCache is available under the Apache 2.0 license. See the LICENSE file for more info.

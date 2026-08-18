import UIKit

@MainActor
public protocol NestedPagingViewDelegate: AnyObject {
    func tableHeaderViewHeight(in pagingView: NestedPagingView) -> CGFloat
    func tableHeaderView(in pagingView: NestedPagingView) -> UIView
    func heightForPinSectionHeader(in pagingView: NestedPagingView) -> CGFloat
    func viewForPinSectionHeader(in pagingView: NestedPagingView) -> UIView
    func numberOfLists(in pagingView: NestedPagingView) -> Int
    func pagingView(_ pagingView: NestedPagingView, initListAt index: Int) -> NestedPagingListViewDelegate
}

/// A child page. Any `UIScrollView` subclass works — table, collection, or your own.
@MainActor
public protocol NestedPagingListViewDelegate: AnyObject {
    func listView() -> UIView
    func listScrollView() -> UIScrollView
    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void)
}

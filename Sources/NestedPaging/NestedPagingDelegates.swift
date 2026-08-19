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
///
/// For a page with no tabs, return a height from
/// `listPreferredContentHeight(forWidth:)` and use a plain `UIView`.
/// NestedPaging then sizes the cell to that height and lets the outer
/// table scroll the header and content together.
@MainActor
public protocol NestedPagingListViewDelegate: AnyObject {
    func listView() -> UIView
    func listScrollView() -> UIScrollView
    func listViewDidScrollCallback(_ callback: @escaping (UIScrollView) -> Void)
    func listPreferredContentHeight(forWidth width: CGFloat) -> CGFloat?
}

public extension NestedPagingListViewDelegate {
    func listPreferredContentHeight(forWidth width: CGFloat) -> CGFloat? { nil }
}

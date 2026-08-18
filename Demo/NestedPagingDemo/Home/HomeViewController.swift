import UIKit

final class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private enum Section: Int, CaseIterable {
        case basics
        case social

        var title: String {
            switch self {
            case .basics: "接入"
            case .social: "社交个人页"
            }
        }
    }

    private enum BasicRow: Int, CaseIterable {
        case profile
        case basic

        var title: String {
            switch self {
            case .profile: "个人主页"
            case .basic: "基础用法"
            }
        }

        var subtitle: String {
            switch self {
            case .profile: "封面吸顶、导航栏渐变、table + collection"
            case .basic: "最小接入：纯色 Header + 两个列表"
            }
        }
    }

    private enum SocialRow: Int, CaseIterable {
        case douyin
        case xiaohongshu
        case x
        case instagram

        var title: String {
            switch self {
            case .douyin: "抖音"
            case .xiaohongshu: "小红书"
            case .x: "X"
            case .instagram: "Instagram"
            }
        }

        var subtitle: String {
            switch self {
            case .douyin: "深色封面、三列竖视频、作品 / 喜欢 / 收藏"
            case .xiaohongshu: "双列笔记瀑布、笔记 / 收藏 / 赞过"
            case .x: "Banner + 时间线，媒体页是九宫格"
            case .instagram: "无封面、Highlights、图标 tab、三列宫格"
            }
        }
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NestedPaging"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .basics: BasicRow.allCases.count
        case .social: SocialRow.allCases.count
        case nil: 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        switch Section(rawValue: indexPath.section) {
        case .basics:
            let row = BasicRow.allCases[indexPath.row]
            content.text = row.title
            content.secondaryText = row.subtitle
        case .social:
            let row = SocialRow.allCases[indexPath.row]
            content.text = row.title
            content.secondaryText = row.subtitle
        case nil:
            break
        }
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section) {
        case .basics:
            switch BasicRow.allCases[indexPath.row] {
            case .profile:
                navigationController?.pushViewController(ProfileDemoViewController(), animated: true)
            case .basic:
                navigationController?.pushViewController(BasicDemoViewController(), animated: true)
            }
        case .social:
            switch SocialRow.allCases[indexPath.row] {
            case .douyin:
                navigationController?.pushViewController(DouyinDemoViewController(), animated: true)
            case .xiaohongshu:
                navigationController?.pushViewController(XiaohongshuDemoViewController(), animated: true)
            case .x:
                navigationController?.pushViewController(XDemoViewController(), animated: true)
            case .instagram:
                navigationController?.pushViewController(InstagramDemoViewController(), animated: true)
            }
        case nil:
            break
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        section == Section.social.rawValue
            ? "四种个人页都是同一套 NestedPaging：外层吸顶，内层接手，左右切 tab。"
            : nil
    }
}

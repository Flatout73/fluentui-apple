//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class CommandBarDemoController: DemoController {
    enum Command {
        case add
        case mention
        case calendar

        case textBold
        case textItalic
        case textUnderline
        case textStrikethrough

        case arrowUndo
        case arrowRedo

        case copy
        case delete

        case checklist
        case bulletList
        case numberList
        case link

        case keyboard

        case textStyle

        case disabledText

        var iconImage: UIImage? {
            switch self {
            case .add:
                return UIImage(named: "add24Regular")
            case .mention:
                return UIImage(named: "mention24Regular")
            case .calendar:
                return UIImage(named: "calendar24Regular")
            case .textBold:
                return UIImage(named: "textBold24Regular")
            case .textItalic:
                return UIImage(named: "textItalic24Regular")
            case .textUnderline:
                return UIImage(named: "textUnderline24Regular")
            case .textStrikethrough:
                return UIImage(named: "textStrikethrough24Regular")
            case .arrowUndo:
                return UIImage(named: "arrowUndo24Regular")
            case .arrowRedo:
                return UIImage(named: "arrowRedo24Filled")
            case .copy:
                return UIImage(named: "copy24Regular")
            case .delete:
                return UIImage(named: "delete24Regular")
            case .checklist:
                return UIImage(named: "textChecklistListLtr24Regular")
            case .bulletList:
                return UIImage(named: "textBulletList24Regular")
            case .numberList:
                return UIImage(named: "textNumberListLtr24Regular")
            case .link:
                return UIImage(named: "link24Regular")
            case .keyboard:
                return UIImage(named: "keyboardDock24Regular")
            case .textStyle, .disabledText:
                return nil
            }
        }

        var title: String? {
            switch self {
            case .textStyle:
                return TextStyle.body.textRepresentation
            case .disabledText:
                return "Search"
            default:
                return nil
            }
        }

        var titleFont: UIFont? {
            switch self {
            case .textStyle:
                return TextStyle.body.font
            case .disabledText:
                return .systemFont(ofSize: 15, weight: .regular)
            default:
                return nil
            }
        }

        var isPersistSelection: Bool {
            switch self {
            case .add, .mention, .calendar, .arrowUndo, .arrowRedo, .copy, .delete, .link, .keyboard, .textStyle, .disabledText:
                return false
            case .textBold, .textItalic, .textUnderline, .textStrikethrough, .checklist, .bulletList, .numberList:
                return true
            }
        }
    }

    enum TextStyle: String {
        case body
        case subhead
        case title

        var textRepresentation: String {
            rawValue.capitalized
        }

        var font: UIFont {
            switch self {
            case .body:
                return .systemFont(ofSize: 15, weight: .regular)
            case .subhead:
                return .systemFont(ofSize: 15, weight: .bold)
            case .title:
                return .systemFont(ofSize: 20, weight: .bold)
            }
        }

        static func next(for textRepresentation: String?) -> TextStyle {
            guard let rawValue = textRepresentation?.lowercased(), let textStyle = TextStyle(rawValue: rawValue) else {
                return .body
            }

            switch textStyle {
            case .body:
                return .title
            case .subhead:
                return .body
            case .title:
                return .subhead
            }
        }
    }

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = Colors.navigationBarBackground
        textField.placeholder = "Text Field"

        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        container.layoutMargins.right = 0
        container.layoutMargins.left = 0
        view.backgroundColor = Colors.surfaceSecondary

        let commandGroups: [[Command]] = [
            [
                .add,
                .mention,
                .calendar
            ],
            [
                .textStyle
            ],
            [
                .disabledText
            ],
            [
                .textBold,
                .textItalic,
                .textUnderline,
                .textStrikethrough
            ],
            [
                .arrowUndo,
                .arrowRedo
            ],
            [
                .delete
            ],
            [
                .checklist,
                .bulletList,
                .numberList,
                .link
            ]
        ]

        let itemGroups: [CommandBarItemGroup] = commandGroups.map { commandGroup in
            commandGroup.map { command in
                newItem(for: command)
            }
        }

        itemGroups[0][1].isEnabled = false
        itemGroups[2][0].isEnabled = false

        // Copy item
        let copyItem = itemGroups[4][0]
        copyItem.menu = UIMenu(children: [UIAction(title: "Copy Image", image: UIImage(named: "copy24Regular"), handler: { _ in }),
                                          UIAction(title: "Copy Text", image: UIImage(named: "text24Regular"), handler: { _ in })])
        copyItem.showsMenuAsPrimaryAction = true

        container.addArrangedSubview(createLabelWithText("Default"))

        let defaultCommandBar = CommandBar(itemGroups: itemGroups)
        container.addArrangedSubview(defaultCommandBar)

        container.addArrangedSubview(createLabelWithText("With Fixed Button"))

        let fixedButtonCommandBar = CommandBar(itemGroups: itemGroups, leadingItem: newItem(for: .copy), trailingItem: newItem(for: .keyboard))
        container.addArrangedSubview(fixedButtonCommandBar)

        container.addArrangedSubview(createLabelWithText("In Input Accessory View"))

        let textFieldContainer = UIView()
        textFieldContainer.backgroundColor = Colors.navigationBarBackground
        textFieldContainer.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: 16.0),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16.0),
            textFieldContainer.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16.0),
            textFieldContainer.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16.0)
        ])

        container.addArrangedSubview(textFieldContainer)

        let accessoryCommandBar = CommandBar(itemGroups: itemGroups, trailingItem: newItem(for: .keyboard))
        textField.inputAccessoryView = accessoryCommandBar
    }

    func createLabelWithText(_ text: String = "") -> Label {
        let label = Label(style: .subhead, colorStyle: .regular)
        label.text = text
        label.textAlignment = .center
        return label
    }

    func newItem(for command: Command, isEnabled: Bool = true, isSelected: Bool = false) -> CommandBarItem {
        CommandBarItem(
            iconImage: command.iconImage,
            title: command.title,
            titleFont: command.titleFont,
            isEnabled: isEnabled,
            isSelected: isSelected,
            itemTappedHandler: { [weak self] (_, item) in
                self?.handleCommandItemTapped(command: command, item: item)
            },
            accessibilityHint: "sample accessibility hint"
        )
    }

    func handleCommandItemTapped(command: Command, item: CommandBarItem) {
        if command.isPersistSelection {
            item.isSelected.toggle()
        }

        let isSelected = item.isSelected || !command.isPersistSelection

        switch command {
        case .keyboard:
            textField.resignFirstResponder()
        case .textStyle:
            let textStyle = TextStyle.next(for: item.title)
            item.title = textStyle.textRepresentation
            item.titleFont = textStyle.font
        default:
            let alert = UIAlertController(title: "Did \(isSelected ? "select" : "deselect") command \(command)", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
}

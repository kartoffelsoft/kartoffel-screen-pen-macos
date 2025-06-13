import AppKit

class ShortcutView: NSView {

    private let textField = {
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.isBezeled = false
        textField.isEditable = false
        textField.textColor = .labelColor
        return textField
    }()
    
    private let colorImageView: NSImageView = {
        let view = NSImageView(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        view.image = NSImage(systemSymbolName: "square.fill", accessibilityDescription: nil)
        view.image?.isTemplate = true
        return view
    }()
    
    private lazy var descriptionView = {
        let view = NSStackView(views: [textField, colorImageView])
        view.orientation = .horizontal
        return view
    }()
    
    private let symbolTextField = {
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.isBezeled = false
        textField.isEditable = false
        textField.textColor = .labelColor
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(_ data: ShortcutData) {
        symbolTextField.stringValue = data.keyEquivalentModifiers.symbolicDescription.isEmpty
            ? data.keyEquivalent
            : "\(data.keyEquivalentModifiers.symbolicDescription) \(data.keyEquivalent)"
        
        switch data.description {
        case let .text(text):
            textField.stringValue = text
            textField.isHidden = false
            colorImageView.isHidden = true
            break
            
        case let .color(color):
            colorImageView.contentTintColor = color
            textField.isHidden = true
            colorImageView.isHidden = false
            break
        }
    }

    private func setupConstraints() {
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        symbolTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(descriptionView)
        addSubview(symbolTextField)
        
        NSLayoutConstraint.activate([
            descriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            descriptionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),

            symbolTextField.leadingAnchor.constraint(equalTo: descriptionView.trailingAnchor, constant: 8),
            symbolTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            symbolTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        ])
    }
}

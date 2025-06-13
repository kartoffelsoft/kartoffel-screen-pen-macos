import AppKit

class ShortcutView: NSView {

    private let descriptionTextField = {
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.isBezeled = false
        textField.isEditable = false
        textField.textColor = .labelColor
        return textField
    }()
    
    private let symbolTextField = {
        let textField = NSTextField()
        textField.backgroundColor = .clear
        textField.isBezeled = false
        textField.isEditable = false
        textField.textColor = .secondaryLabelColor
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
        descriptionTextField.stringValue = data.description
        symbolTextField.stringValue = "\(data.keyEquivalentModifiers.symbolicDescription) \(data.keyEquivalent)"
    }

    private func setupConstraints() {
        descriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        symbolTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(descriptionTextField)
        addSubview(symbolTextField)
        
        NSLayoutConstraint.activate([
            descriptionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            descriptionTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            descriptionTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),

            symbolTextField.leadingAnchor.constraint(equalTo: descriptionTextField.trailingAnchor, constant: 8),
            symbolTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            symbolTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
        ])
    }
}

import AppKit
import Combine
import ComposableArchitecture

public class ColorPickerView: NSView {

    private let store: StoreOf<ColorPicker>
    private let viewStore: ViewStoreOf<ColorPicker>
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var stackView: NSStackView = {
        let view = NSStackView()
        view.orientation = .horizontal
        view.spacing = 3
        return view
    }()
    
    public init(store: StoreOf<ColorPicker>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        
        super.init(frame: NSMakeRect(0, 0, 230, 32))
        
        setupConstraints()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func setupBindings() {
        viewStore.publisher.colorButtons.sink { [weak self] buttons in
            guard let self = self else { return }
            
            stackView.arrangedSubviews.forEach { view in
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            for data in buttons {
                let button = NSButton(title: "", target: self, action: #selector(didClickButton))
                button.wantsLayer = true
                button.isBordered = false
                button.tag = data.id
                button.layer?.borderWidth = data.isSelected ? 3 : 1
                button.layer?.borderColor = data.isSelected ? .white : NSColor.gray.cgColor
                button.layer?.backgroundColor = data.color
                button.layer?.cornerRadius = 6
                button.setButtonType(.momentaryChange)
 
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 26),
                    button.heightAnchor.constraint(equalToConstant: 26),
                ])

                stackView.addArrangedSubview(button)
            }
        }
        .store(in: &self.cancellables)
    }
    
    @objc private func didClickButton(_ sender: NSButton) {
        viewStore.send(.selectButton(sender.tag))
    }
}

//
//  SettingsHeaderCell.swift
//  Verifier
//
//  Created by Emilio Apuzzo on 25/10/21.
//

import UIKit

class SettingsHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: AppLabel!
    @IBOutlet weak var titleTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var titleBottomAnchor: NSLayoutConstraint!
    
    var separatorView: UIView? = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    private func setup(){
        self.selectionStyle = .none
        titleLabel.uppercased = true
        titleLabel.bold = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillCell(title: String?, fontSize: CGFloat = 15, isSeparatorHidden: Bool = true){
        guard let title = title else {return}
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: fontSize)
        isSeparatorHidden ? removeSeparator() : addSeparatorView()
    }
    
    private func addSeparatorView(){
        guard let separatorView = separatorView else {return}
        titleTopAnchor.constant = 32
        titleBottomAnchor.constant = 32
        self.contentView.addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            separatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1)
        ])
    }

    private func removeSeparator(){
        guard let separatorView = separatorView else {return}
        titleBottomAnchor.constant = 0
        titleTopAnchor.constant = 40
        separatorView.removeConstraints(separatorView.constraints)
        separatorView.removeFromSuperview()
    }
    
}

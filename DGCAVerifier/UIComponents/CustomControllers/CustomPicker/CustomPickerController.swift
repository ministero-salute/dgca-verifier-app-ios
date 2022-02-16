//
//  CustomPicker.swift
//  Verifier
//
//  Created by Johnny Bueti on 16/02/22.
//

import UIKit

protocol CustomPickerCoordinator {
	func dismissCustomPicker(completion: (() -> Void)?)
}

class CustomPickerController: UIViewController {
	
	private weak var coordinator: Coordinator?
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	public init(coordinator: Coordinator) {
		super.init(nibName: "CustomPickerController", bundle: nil)
		
		self.coordinator = coordinator
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
//		self.collectionView.register(UINib(nibName: "ScanModeCell", bundle: nil), forCellWithReuseIdentifier: "scanModeCell")
		self.collectionView.register(ScanModeCell.self, forCellWithReuseIdentifier: "scanModeCell")
    }

}

extension CustomPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "scanModeCell", for: indexPath) as! ScanModeCell
		cell.backgroundColor = .black
		return cell
	}
}

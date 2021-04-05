

import UIKit

class SubfolderViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let fileManager = FileManager.default
    var files = [String]()
    
    private let subfolderTitle: String
    private let path: URL
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(SubfolderCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: SubfolderCollectionViewCell.self))
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        readData(path: path)
        setupLayout()
        
    }
    
    init(subfolderTitle: String, path: URL) {
        self.subfolderTitle = subfolderTitle
        self.path = path
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func createFolder() {
        
        var inputTextField: UITextField?
        
        let alertController = UIAlertController(title: "New folder", message: "Enter folder name", preferredStyle: .alert)
        alertController.addTextField { (textField ) in
            textField.placeholder = "Enter folder name"
            inputTextField = textField
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in

            if let folderName = inputTextField?.text {
                self?.saveFolder(folderName: folderName)
            }
            
            if let self = self {
                self.readData(path: self.path)
                self.collectionView.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveFolder(folderName: String) {
        let directoryURL = path.appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    @objc func addPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let tempImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageName = UUID().uuidString + ".jpeg"
        let imagePath = path.appendingPathComponent(imageName)
        
        if let jpegData = tempImage.jpegData(compressionQuality: 1.0) {
            try? jpegData.write(to: imagePath)
        }

        dismiss(animated: true, completion: nil)
        readData(path: path)
        collectionView.reloadData()
        
    }
    
    func readData(path: URL) {
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path)
            for item in items {
                if item != ".DS_Store" {
                    if !files.contains(item) {
                        files.append(item)
                    }
                }
            }
        } catch {
            print("Bad permission")
        }
        
    }
    
    private func setupNavigationBar() {
        navigationItem.title = subfolderTitle
        
        navigationController?.navigationBar.backgroundColor = .white
        
        let folderButtonImage = UIImage(systemName: "folder.badge.plus")
        let imageButtonImage = UIImage(systemName: "plus")
        
        let folderButton = UIBarButtonItem(image: folderButtonImage, style: .plain, target: self, action: #selector(createFolder))
        let imageButton = UIBarButtonItem(image: imageButtonImage, style: .plain, target: self, action: #selector(addPhoto))
        navigationItem.rightBarButtonItems = [imageButton, folderButton]
        
    }
    
    private func setupLayout() {
        view.addSubview(collectionView)
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

}

extension SubfolderViewController: UICollectionViewDelegateFlowLayout {
    
    private var baseInset: CGFloat { return 8 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (collectionView.frame.size.width - baseInset * 4) / 3
        
        return CGSize(width: width, height: width)
    }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return baseInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return baseInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: baseInset, left: baseInset, bottom: .zero, right: baseInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = files[indexPath.item]
        if !item.hasSuffix("jpeg") {
            let itemPath = path.appendingPathComponent(item)
            let vc = SubfolderViewController(subfolderTitle: item, path: itemPath)
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

extension SubfolderViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SubfolderCollectionViewCell.self), for: indexPath) as! SubfolderCollectionViewCell
        
        let image = files[indexPath.item]

        let imagePath = path.appendingPathComponent(image)
        if let folderImage = UIImage(systemName: "folder.fill") {
            cell.configure(with: UIImage(contentsOfFile: imagePath.path) ?? folderImage, name: image)
            
        }
        
        return cell
    }
}





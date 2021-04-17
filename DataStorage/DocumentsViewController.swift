

import UIKit

class DocumentsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var files = [String]()
    let fileManager = FileManager.default
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(DocumentsCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: DocumentsCollectionViewCell.self))
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setDefaultPreferences()
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readData()
        collectionView.reloadData()
    }
    
    private func setDefaultPreferences() {
        if !UserDefaults.standard.bool(forKey: Keys.isFirstLaunchBoolKey.rawValue) {
            
            UserDefaults.standard.setValue(true, forKey: Keys.isFirstLaunchBoolKey.rawValue)
            UserDefaults.standard.setValue(true, forKey: Keys.sortingBoolKey.rawValue)
            UserDefaults.standard.setValue(true, forKey: Keys.imageSizeShowingBoolKey.rawValue)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let dirPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirURL = dirPaths[0]
        return docsDirURL
    }
    
    @objc func createFolder() {
        
        var inputTextField: UITextField?
        
        let alertController = UIAlertController(title: "Создание новой папки", message: "Введите имя папки", preferredStyle: .alert)
        alertController.addTextField { (textField ) in
            textField.placeholder = "Введите имя папки"
            inputTextField = textField
        }

        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in

            if let folderName = inputTextField?.text {
                self?.saveFolder(folderName: folderName)
            }
            
            if let self = self {
                self.readData()
                self.collectionView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)

    }
    
    private func saveFolder(folderName: String) {
        let directoryURL = self.getDocumentsDirectory().appendingPathComponent(folderName)
        
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            print(directoryURL)
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
               
        if let jpegData = tempImage.jpegData(compressionQuality: 1.0) {
            let imageName = UUID().uuidString + ".jpeg"
            let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
            try? jpegData.write(to: imagePath)
        }

        readData()
        collectionView.reloadData()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func readData() {
        let path = getDocumentsDirectory()
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path.path)
            for item in items {
                if item != ".DS_Store" {
                    if !files.contains(item) {
                        files.append(item)
                    }
                }

            }
            checkingSortingPreference()
        } catch {
            print("Ошибка")
        }
        
    }
    
    private func checkingSortingPreference() {
        let boolValue = UserDefaults.standard.bool(forKey: Keys.sortingBoolKey.rawValue)
        if boolValue {
            files.sort(by: <)
        } else {
            files.sort(by: >)
        }
    }
    
    private func showImageSize(with file: String, path: URL) -> String {
        
        var value: String = ""
        if file.hasSuffix("jpeg") {

            let imageSize =  UIImage(contentsOfFile: path.path)?.jpegData(compressionQuality: 1)?.count
            
            let number = NSString(format: "%.2f", (Double(imageSize ?? 0) / 1024 / 1024)) as String
            value = number
        }
        return value
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Документы"
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        navigationItem.hidesBackButton = true
        
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

extension DocumentsViewController: UICollectionViewDelegateFlowLayout {
    
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
            let path = getDocumentsDirectory().appendingPathComponent(item)
            let vc = SubfolderViewController(subfolderTitle: item, path: path)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension DocumentsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DocumentsCollectionViewCell.self), for: indexPath) as! DocumentsCollectionViewCell
        
        let file = files[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(file)
        
        if let folderImage = UIImage(systemName: "folder.fill") {
            cell.configure(with: UIImage(contentsOfFile: path.path) ?? folderImage, name: file)
        }
        
        if UserDefaults.standard.bool(forKey: Keys.imageSizeShowingBoolKey.rawValue) {
            let value = showImageSize(with: file, path: path)
            
            if let image = UIImage(contentsOfFile: path.path) {
                cell.configure(with: image, name: "\(value) MB \(file)" )
            }
        }
        
        return cell
    }
}





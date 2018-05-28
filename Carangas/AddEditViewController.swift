//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!

    // MARK: - Properties
    var car: Car!
    var brands: [Brand] = []
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
        
        
        if car != nil {
            
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
            
            tfBrand.text = car.brand
        }
        
        loadbrands()
    }
    
    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].fipe_name
        cancel()
    }
    
    // MARK: - IBActions
    @IBAction func addEdit(_ sender: UIButton) {
        
        sender.isEnabled = false
        sender.backgroundColor = .gray
        loading.startAnimating()
        
        if car == nil {
            car = Car()
        }
        
        car.name = tfName.text!
        car.brand = tfBrand.text!
        car.price = Double(tfPrice.text!.isEmpty ? "0" : tfPrice.text!)!
        car.gasType = scGasType.selectedSegmentIndex
        
        
        if car._id == nil {
            REST.save(car: car) { (success) in
                self.goBack()
            }
        } else {
            REST.update(car: car) { (success) in
                self.goBack()
            }
        }
        
        sender.isEnabled = true
        sender.backgroundColor = UIColor(named: "main")
        loading.stopAnimating()
        
    }
    
    // MARK: - Methods
    func goBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func loadbrands() {
        REST.loadBrands { (brands) in
            self.brands = brands.sorted(by: {$0.fipe_name < $1.fipe_name})
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
                if self.car != nil, let brandIndex = self.brands.index(where: {$0.fipe_name == self.car.brand}) {
                    self.pickerView.selectRow(brandIndex, inComponent: 0, animated: false)
                }
            }
        }
    }
}

extension AddEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return brands[row].fipe_name
    }
}

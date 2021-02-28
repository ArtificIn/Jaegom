//
//  StoreVC.swift
//  proc
//
//  Created by 성다연 on 2019. 1. 21..
//  Copyright © 2019년 swuad-19. All rights reserved.
//

import UIKit
import Foundation

class StoreVC: UIViewController {
    @IBOutlet weak var storeListTV: UITableView!
    @IBOutlet weak var storeSearchBar: UISearchBar!
    @IBOutlet weak var editBtn: UIButton!
    
    private let viewModel = StoreViewModel()
    private let buttonBar = UIView()
    private var switchSegment = UISegmentedControl()
    private var (selectSegmentNumber, selectIndex) = (0,0)
    private var searchArray : [Int : [Store]] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDelegate()
        setUpSubViews()
        setUpSegmentBar()
        setUpSearchArray()
        setUpButtonLayoutSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storeListTV.reloadData()
    }
}


extension StoreVC : UISearchBarDelegate, UpdateDelegate {
    private func setUpDelegate(){
        storeListTV.delegate = self
        storeListTV.dataSource = self
        storeSearchBar.delegate = self
    }
    
    private func setUpSubViews(){
        view.addSubview(buttonBar)
        view.addSubview(switchSegment)
        
        storeListTV.separatorStyle = .none
        switchSegment.addTarget(self, action: #selector(StoreVC.segmentControlValueChanged(_:)), for: UIControl.Event.valueChanged)
        editBtn.addTarget(self, action: #selector(editBtnClicked), for: .touchUpInside)
    }

    private func setUpSearchArray(){
        viewModel.returnStockTotalCount()
        
        searchArray.updateValue(viewModel.returnStockUntilDate(fromDays: -1, toDays: 0), forKey: 0)
        searchArray.updateValue(viewModel.returnStockUntilDate(fromDays: 0, toDays: 1), forKey: 1)
        searchArray.updateValue(viewModel.returnStockUntilDate(fromDays: 2, toDays: nil), forKey: 2)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch searchText.isEmpty {
        case true :
            searchArray[0] = viewModel.returnChartModel(index: 0)
            searchArray[1] = viewModel.returnChartModel(index: 1)
            searchArray[2] = viewModel.returnChartModel(index: 2)
        case false :
            searchArray[0] = viewModel.returnChartModel(index: 0).filter { $0.name.range(of: searchText) != nil }
            searchArray[1] = viewModel.returnChartModel(index: 1).filter { $0.name.range(of: searchText) != nil }
            searchArray[2] = viewModel.returnChartModel(index: 2).filter { $0.name.range(of: searchText) != nil }
        }
        
        storeListTV.reloadData()
    }

    private func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        storeSearchBar.text = ""
        storeSearchBar.resignFirstResponder()
        storeSearchBar.showsCancelButton = false
        storeListTV.reloadData()
    }
        
    @objc private func editBtnClicked() {
        switch storeListTV.isEditing {
        case true:
            editBtn.setTitle("Edit", for: .normal)
            storeListTV.setEditing(false, animated: true)
        case false:
            editBtn.setTitle("Done", for: .normal)
            storeListTV.setEditing(true, animated: true)
        }
    }
    
    func didUpDate() {
        storeListTV.reloadData()
    }
}


// 테이블 뷰
extension StoreVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let array = searchArray[selectSegmentNumber] else { return 1}
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let array = searchArray[selectSegmentNumber] else { return UITableViewCell() }
        let store = array[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreChartCell") as! storeChartCell

        cell.bindViewModel(store: store)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let array = searchArray[selectSegmentNumber] {
            selectIndex = viewModel.findStockAsStock(data: array[indexPath.row])
            nextVC()
        }
    }
    
    // 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var array = searchArray[selectSegmentNumber] else { return }
            array.remove(at: indexPath.row)
            viewModel.removeStock(data: viewModel.findStockAsStock(data: array[indexPath.row]))
            storeListTV.deleteRows(at: [indexPath], with: .automatic)
            viewModel.saveData()
            didUpDate()
        }
    }
}



// 세그먼트
extension StoreVC {
    private func setUpSegmentBar(){
        switchSegment.insertSegment(withTitle: "폐기 물품", at: 0, animated: true)
        switchSegment.insertSegment(withTitle: "당일 마감", at: 1, animated: true)
        switchSegment.insertSegment(withTitle: "양호 물품", at: 2, animated: true)
        switchSegment.selectedSegmentIndex = selectSegmentNumber
        switchSegment.translatesAutoresizingMaskIntoConstraints = false
        
        switchSegment.topAnchor.constraint(equalTo: view.topAnchor, constant: 104).isActive = true
        switchSegment.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        switchSegment.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        switchSegment.backgroundColor = .clear
        switchSegment.tintColor = .clear
        switchSegment.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DiwanMishafi", size: 16)!,
            NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
        switchSegment.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "DiwanMishafi", size : 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.26, green: 0.43, blue: 0.85, alpha: 1.0)], for: .selected)
    }
    
    @objc private func segmentControlValueChanged(_ sender: UISegmentedControl){
        UIView.animate(withDuration: 0.3){
            self.buttonBar.frame.origin.x = (self.switchSegment.frame.width / CGFloat(self.switchSegment.numberOfSegments)) * CGFloat(self.switchSegment.selectedSegmentIndex)
        }
        if switchSegment.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.selectSegmentNumber = 0
            })
        }
        else if switchSegment.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.selectSegmentNumber = 1
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.selectSegmentNumber = 2
            })
        }
        storeListTV.reloadData()
    }
    

    private func setUpButtonLayoutSetting(){
        buttonBar.backgroundColor = UIColor(red: 0.26, green: 0.43, blue: 0.85, alpha: 1.0)
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.topAnchor.constraint(equalTo: switchSegment.bottomAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        buttonBar.leftAnchor.constraint(equalTo: switchSegment.leftAnchor).isActive = true
        buttonBar.widthAnchor.constraint(equalTo: switchSegment.widthAnchor, multiplier: 1 / CGFloat(switchSegment.numberOfSegments)).isActive = true
    }
    
    private func nextVC(){
        let vc : StorePopupVC = storyboard?.instantiateViewController(withIdentifier: "storePopupVC") as! StorePopupVC
        vc.position = selectIndex
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true)
    }
}

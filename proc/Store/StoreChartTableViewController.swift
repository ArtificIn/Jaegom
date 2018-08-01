import UIKit
import Foundation

// search 바 포함
class StoreChartTableViewController: UITableViewController, UISearchBarDelegate {
    
    // 재고 기본

    @IBOutlet weak var location_table: UITableView!
    @IBOutlet weak var searchbar : UISearchBar!
    

    @IBOutlet weak var labelName:UILabel!
    @IBOutlet weak var labelSaveStyle:UILabel!
    @IBOutlet weak var ChartImage:UIImageView!
    @IBOutlet weak var labelUpDate:UILabel!
    @IBOutlet weak var labelDownDate:UILabel!
    @IBOutlet weak var labelMany:UILabel!
    @IBOutlet weak var labelManyType:UILabel!
    @IBOutlet weak var labelTotalMany:UILabel!
    @IBOutlet weak var Call:UILabel!
    
    // 재고 상세
    var infoDateAdd:String = HomeDateModel.dateInfo()
    var dataFilePath: String?
    
    
    // 유통기간 배열들을 담은 빅배열
    //var arrayBig:[Store] = []

    var location_name_array = StoreDatabase //[String]() // 원본(위치정보)를 가지는 배열
    var searchfilterData0:[Store] = [] // 필터링된 결과를 저장할 배열
    var searchfilterData1:[Store] = []
    var searchfilterData2:[Store] = []
    var searchfilterData3:[Store] = []
    
    // 재고 목록 4가지 확보 필요.
    var array00ToTrash:[Store] = []
    var array01Today:[Store] = []
    var array02D3:[Store] = []
    var array03D7:[Store] = []
    
    func updateArraysFromModel() {
        array00ToTrash = StoreDatabase.storesUntilDate(fromDays: 0, toDays: 1)
        array01Today = StoreDatabase.storesUntilDate(fromDays: 1, toDays: 3)
        array02D3 = StoreDatabase.storesUntilDate(fromDays: 3, toDays: 7)
        array03D7 = StoreDatabase.storesUntilDate(fromDays: 7, toDays: nil)
        
    }

    override func viewDidLoad() {

        // search bar
        location_table.dataSource = self
        location_table.delegate = self
        searchbar.placeholder = "재고 이름을 검색하세요" // hint 등록
        
        location_table.tableHeaderView = searchbar
        location_table.estimatedSectionHeaderHeight = 50
        searchbar.delegate = self // searchbar 이벤트 처리
        self.tableView.reloadData()
        super.viewDidLoad()
        
        //        // 아카이브 코드
        //        let fileManager = FileManager.default
        //        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, userDomainMask, true)
        //        let docsDir = dirPath[0] as NSString
        //        dataFilePath = docsDir.appendingPathComponent("data.archive")
        //
        //        if fileManager.fileExists(atPath: dataFilePath!){
        //            let user = NSKeyedUnarchiver.unarchiveObject(withFile: dataFilePath!) as! Store
        //            labelName.text = user.name
        //            labelSaveStyle.text = user.saveStyle.rawValue
        //            // 이미지 자리
        //            labelUpDate.text = user.UpDate
        //            labelDownDate.text = user.DownDate
        //            labelMany.text = String(user.many)
        //            labelManyType.text = user.manytype
        //            labelTotalMany.text = String(user.TotalMany)
        //            Call.text = user.Call
        //        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        updateArraysFromModel()
        
        searchfilterData0 = array00ToTrash
        searchfilterData1 = array01Today
        searchfilterData2 = array02D3
        searchfilterData3 = array03D7
        
        self.tableView.reloadData()

    }
    
    // searchbar 관련 메소드
    func searchBar(_ searchbar: UISearchBar, textDidChange searchText:String){
        
        searchfilterData0 = searchText.isEmpty ? array00ToTrash : array00ToTrash.filter{ $0.name.range(of: searchText) != nil}
        searchfilterData1 = searchText.isEmpty ? array01Today : array01Today.filter{ $0.name.range(of: searchText) != nil}
        searchfilterData2 = searchText.isEmpty ? array02D3 : array02D3.filter{ $0.name.range(of: searchText) != nil}
        searchfilterData3 = searchText.isEmpty ? array03D7 : array03D7.filter{ $0.name.range(of: searchText) != nil}
        
        print("searchFilterData0 = \(searchfilterData0)")
        print("searchFilterData1 = \(searchfilterData1)")
        print("searchFilterData2 = \(searchfilterData2)")
        print("searchFilterData3 = \(searchfilterData3)")
        location_table.reloadData() // 필터링한 데이터를 테이블뷰로 설정
    }

    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchbar.showsCancelButton = true // 취소 버튼
        print("work")
    }
    
    // 취소버튼 클릭 시 키보드 닫히고 검색어 초기화
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchbar.showsCancelButton = false
        searchbar.text = ""
        searchbar.resignFirstResponder()
    }
  
    //table section 설정
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        switch section {
        case 0 :
            return "폐기 물품  -  \(searchfilterData0.count) 개"
        case 1 :
            return "당일 마감  -  \(searchfilterData1.count) 개"
        case 2 :
            return "3일 이상  -  \(searchfilterData2.count) 개"
        default:
            return "7일 이상  -  \(searchfilterData3.count) 개 "
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return searchfilterData.count
        
        var rValue = 0
        
        switch section {
        case 0:
            rValue =  self.searchfilterData0.count
        case 1:
            rValue =  self.searchfilterData1.count
        case 2:
            rValue =  self.searchfilterData2.count
        default:
            rValue =  self.searchfilterData3.count
        }
        return rValue
    }
    
// 전화걸기 함수
    @IBAction func phoenCallBtn(_ sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.tableView.indexPath(for: cell)
        
        
        if location_name_array.arrayList[(indexPath?.row)!].Call != nil {
            var temp = location_name_array.arrayList[(indexPath?.row)!].Call!
            print("temp = \(temp)")
            
            if let phoneCallURL = URL(string: "tel://\(temp)") {
                
                let application:UIApplication = UIApplication.shared
                
                if (application.canOpenURL(phoneCallURL)) {
                    
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                    
                }
                
            }
            
        }
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var arrayStore:[Store]!
        
        if indexPath.section == 0 {
            arrayStore =  searchfilterData0
        }
        else if indexPath.section == 1 {
            arrayStore = searchfilterData1
        }
        else if indexPath.section == 2 {
            arrayStore =  searchfilterData2
        }
        else if indexPath.section == 3 {
            arrayStore =  searchfilterData3
        }
        
        let store = arrayStore[indexPath.row]
        
        let proccell:StoreChartCell_More = tableView.dequeueReusableCell(withIdentifier: "Cell2IngredientBig") as! StoreChartCell_More

        // cell
        proccell.labelName.text = store.name
        proccell.labelSaveStyle.text = store.saveStyle.rawValue
        proccell.labelUpDate.text =  store.UpDate
        proccell.labelDownDate.text = store.DownDate
        proccell.labelMany.text = String(store.many)
        proccell.labelManyType.text = String(store.manytype)
        proccell.labelTotalMany.text = String(store.TotalMany)
        //        proccell.Call.text = store.Call
        
        if let image2 = store.Image {
            proccell.ChartImage.image = UIImage(named: image2)
        }
        
        return proccell

        
/*
        let info = searchfilterData[indexPath.row]
        let proccell:StoreChartCell_More = tableView.dequeueReusableCell(withIdentifier: "Cell2IngredientBig") as! StoreChartCell_More
        
        // cell
        proccell.labelName.text = info.name
        proccell.labelSaveStyle.text = info.saveStyle.rawValue
        proccell.labelUpDate.text =  info.UpDate
        proccell.labelDownDate.text = info.DownDate
        
        proccell.labelMany.text = String(info.many)
        proccell.labelManyType.text = String(info.manytype)
        proccell.labelTotalMany.text = String(info.TotalMany)
        //        proccell.Call.text = info.Call
        
        if let image2 = info.Image {
            proccell.ChartImage.image = UIImage(named: image2)
        }
        
        return proccell
 */
    }
    
    
    // 재고 삭제 코드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 {
            
            let store = searchfilterData0[indexPath.row]
            let indexofA = location_name_array.arrayList.index(of: store)
            
            print("removing data0 = \(searchfilterData0)")
            searchfilterData0.remove(at: indexPath.row)
            location_name_array.arrayList.remove(at: indexofA!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
        else if indexPath.section == 1 {
            let store = searchfilterData1[indexPath.row]
            let indexofA = location_name_array.arrayList.index(of: store)
            
            print("removing data1 = \(searchfilterData1)")
            searchfilterData1.remove(at: indexPath.row)
            location_name_array.arrayList.remove(at: indexofA!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
        else if indexPath.section == 2 {

            let store = searchfilterData2[indexPath.row]
            let indexofA = location_name_array.arrayList.index(of: store)
            
            print("removing data2 = \(searchfilterData2)")
            searchfilterData2.remove(at: indexPath.row)
            location_name_array.arrayList.remove(at: indexofA!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
        else if indexPath.section == 3 {
            
            let store = searchfilterData3[indexPath.row]
            let indexofA = location_name_array.arrayList.index(of: store)
            
            print("removing data3 = \(searchfilterData3)")
            searchfilterData3.remove(at: indexPath.row)
            location_name_array.arrayList.remove(at: indexofA!)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
        }
    
        print("after remove localdata = \(location_name_array.arrayList)")
       self.tableView.reloadData()

    }

    
}



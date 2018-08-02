import UIKit
import Foundation


class HomeStoreTableViewController : UITableViewController {
    
    // 스케줄 데이터, 재고 데이터 가져오기
    var homeCallStore = StoreDatabase
    
    // 부족한 수량 목록
    var homeStoreFilterByMany: [Store] = []
   
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // return homeCallStore.arrayList.count
        return homeStoreFilterByMany.count
    }
    
    override func viewDidLoad() {
        showLowStoresAtHome()
        self.tableView.reloadData()
         super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("homeStoreFilterByMany = \(homeStoreFilterByMany) \n")
        self.tableView.reloadData()
    }
    
    /**
     부족한 수량을 보여주기
     */
    func showLowStoresAtHome() {
       
        homeStoreFilterByMany = homeCallStore.showLessManyItem()
        print("show : \(homeCallStore.arrayList)")
    }
    
    
    // UITableViewController 의 요소와 정의한 데이터들 일치시키기
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //let HomeStoreInfo = self.homeCallStore.arrayList[indexPath.row]
        let HomeStoreInfo = self.homeStoreFilterByMany[indexPath.row]
        let HomeStorecell: HomeStoreChartCell = tableView.dequeueReusableCell(withIdentifier: "HStoreCell") as! HomeStoreChartCell
        let storeManyDegree:String = " " + HomeStoreInfo.manytype
        
        HomeStorecell.HomeStoreName.text = HomeStoreInfo.name
        HomeStorecell.HomeStoreSaveStyle.text = HomeStoreInfo.saveStyle.rawValue
        HomeStorecell.HomeStoreMany.text = String(HomeStoreInfo.many) + " / \(HomeStoreInfo.TotalMany)" + storeManyDegree 
        //HomeStorecell.HomeStoreManytype.text = HomeStoreInfo.manytype

        
        return HomeStorecell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let cell = sender as! UITableViewCell
//        let indexPath:IndexPath! = self.tableView.indexPath(for: cell)
//
//        homeCallStore.selectedIndex = indexPath.row
//        
//        let segueHome = segue.destination as! HomeStoreTableViewController
//        segueHome.homeCallStore.arrayList = self.homeCallStore
//    }
}

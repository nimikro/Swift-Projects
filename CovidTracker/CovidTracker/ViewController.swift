//
//  ViewController.swift
//  CovidTracker
//
//  Created by Nikolaos Mikrogeorgiou on 14/11/21.
//

import UIKit
import Charts

// Data of Covid cases
class ViewController: UIViewController, UITableViewDataSource {
    
    /* Bsic Rundown:
     - Call APIs
     - ViewModels
     - View: Table
     - Filter / User pick state
     - Update UI
     */
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.formatterBehavior = .default
        formatter.groupingSeparator = ","
        formatter.locale = .current
        return formatter
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var dayData: [DayData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.createGraph()
            }
        }
    }
    
    private var scope: APICaller.DataScope = .national
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Covid Cases"
        configureTable()
        createFilterButton()
        fetchData()
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func createGraph() {
        let headerView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5)
        )
        headerView.clipsToBounds = true
        let set = dayData.prefix(30)
        var entries: [BarChartDataEntry] = []
        for index in 0..<set.count{
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count)))
        }
        
        let dataSet = BarChartDataSet(entries: entries)

        //Chart color templates
        dataSet.colors = ChartColorTemplates.joyful()
        
        let data: BarChartData = BarChartData(dataSet: dataSet)
        
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width,
                                               height: view.frame.size.width/1.5))
        chart.data = data
        
        headerView.addSubview(chart)
        tableView.tableHeaderView = headerView
    }
    
    private func fetchData() {
        APICaller.shared.getCovidData(for: scope) { [weak self] result in
            switch result {
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                print(error)
            }
        }
    }

    private func createFilterButton() {
        let buttonTitle: String = {
            switch scope {
            case .national: return "National"
            case .state(let state): return state.name
            }
        }()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: buttonTitle,
            style: .done,
            target: self,
            action: #selector(didTapFilter)
        )
    }
    
    @objc private func didTapFilter() {
        let vc = FilterViewController()
        vc.completion = { [weak self] state in
            self?.scope = .state(state)
            self?.fetchData()
            self?.createFilterButton()
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    
    //MARK: - Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dayData[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = createText(with: data)
        return cell
    }
    
    private func createText(with data: DayData) -> String? {
        let dayString = DateFormatter.prettyFormatter.string(from: data.date)
        let total = Self.numberFormatter.string(from: NSNumber(value: data.count))
        return "\(dayString): \(total ?? "\(data.count)")"
    }
    
}


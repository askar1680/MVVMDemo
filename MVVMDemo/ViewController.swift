//
//  ViewController.swift
//  MVVMDemo
//
//  Created by Аскар on 1/20/19.
//  Copyright © 2019 askar.ulubayev168. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController{
    
    let tableView = UITableView()
    let searchBar = UISearchBar()
    let activityIndicator = UIActivityIndicatorView()
    
    private let disposeBag = DisposeBag()
    private let viewModel = ViewModel(with: Model())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylize()
        setViewContraints()
        bind()
    }
    
    func stylize() {
        view.backgroundColor = .white
        
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        view.addSubview(tableView)
        
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        navigationItem.titleView = searchBar
    }
    
    func setViewContraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func bind() {
        // Observe search result and update UI
        viewModel.repositories.asDriver()
            .drive(self.tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
                cell.textLabel?.text = element.fullName
                cell.detailTextLabel?.text = "\(element.stargazersCount)"
            }
            .disposed(by: disposeBag)
        
        // Observe loading status and update UI
        viewModel.isLoading.asDriver()
            .drive(onNext: { isLoading in
                self.activityIndicator.isHidden = !isLoading
                if isLoading {
                    self.activityIndicator.startAnimating()
                } else {
                    self.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // Observe user input action and trigger searching
        searchBar.rx.text.orEmpty.asDriver()
            .skip(1)
            .debounce(0.3)
            .distinctUntilChanged()
            .drive(onNext: { keyword in
                self.viewModel.fetchGithubSearchResult(with: keyword)
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = viewModel.repositories.value[indexPath.row]
        let alert = UIAlertController(
            title: "Tapped",
            message: repository.fullName,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}


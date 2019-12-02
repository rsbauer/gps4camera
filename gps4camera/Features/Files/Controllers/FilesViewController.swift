//
//  FilesViewController.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import CoreData
import MapKit
import ReactiveKit
import Swinject
import UIKit

class FilesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: FilesViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    private weak var container: Container?
    
    private enum Constants {
        static let reuseId = "defaultCell"
        static let deleteActionTitle = "Delete"
        static let shareActionTitle = "Share"
    }
    
    public init(container: Container) {
        self.container = container
        let dataStore = container.resolve(DataStoreProviderType.self)
        viewModel = FilesViewModel(dataStore: dataStore)
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel = FilesViewModel(dataStore: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = FilesViewModel(dataStore: nil)
        super.init(coder: coder)
    }
    
    deinit {
        viewModel.shutdown()
        
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Files"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseId)
        tableView.delegate = self
        
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.populateList()
        tableView.reloadData()
    }
    
    private func setupObservers() {
        viewModel.items.bind(to: tableView) { (items, indexPath, tableView) -> UITableViewCell in
            let item = items[indexPath.item]
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseId) ?? UITableViewCell()

            cell.textLabel?.text = item.title
            
            return cell
        }.dispose(in: disposeBag)
        
        tableView.reactive.dataSource.feed(
            property: Property(true),
            to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)),
            map: { (value: Bool, _: UITableView, indexPath: IndexPath) -> Bool in
                return value
        }).dispose(in: disposeBag)
        
        tableView.reactive.commitItemForRowAt.observeNext { [weak self] index in
            guard let strongSelf = self else {
                return
            }
            
            print("Delete button requesting deletion confirmation at \(index.row)")
            strongSelf.viewModel.removeItem(at: index.row)
        }.dispose(in: disposeBag)
    }
    
}

extension ReactiveExtensions where Base: UITableView {
    
    /// - Note: Uses the table view's `dataSource` protocol proxy to observe
    /// calls made to `UITableViewDataSource.tableView(_:commit:forRowAt:)` method.
    var commitItemForRowAt: SafeSignal<IndexPath> {
        return dataSource.signal(for: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:))) { (subject: PassthroughSubject<IndexPath, Never>, _: UITableView, editingStyle: Int, indexPath: IndexPath) in
            subject.send(indexPath)
        }
    }
}

extension FilesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        guard let containerExists = container,
            let track = item.track else {
            return
        }
        
        let controller = FileDetailsViewController(container: containerExists, track: track)
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: Constants.deleteActionTitle) { [weak self] (contextualAction, view, boolValue) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.viewModel.removeItem(at: indexPath.row)
        }

        let share = UIContextualAction(style: .normal, title: Constants.shareActionTitle) { [weak self] (contextualAction, view, boolValue) in
            guard let strongSelf = self else {
                return
            }
            
            let item = strongSelf.viewModel.items[indexPath.row]
            guard let track = item.track else {
                return
            }

            ShareManager.share(track: track, viewController: strongSelf)
        }
        
        share.backgroundColor = .systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete, share])
        return swipeActions
    }
}

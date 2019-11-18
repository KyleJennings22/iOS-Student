//
//  ViewController.swift
//  Post
//
//  Copyright © 2018 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - OUTLETS
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - VARIABLES
    let postController = PostController()
    var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        self.tableView.delegate = self
        self.tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        getPosts()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - TABLE VIEW FUNCTIONS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.username
        return cell
    }
    
    @objc func refreshControlPulled() {
        getPosts()
    }
    
    // MARK: - CUSTOM FUNCTIONS
    func getPosts() {
        postController.fetchPosts { (result) in
            switch result {
            case .success:
                self.reloadTableView()
            case .failure:
                print("fail")
            }
        }
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}// end of class




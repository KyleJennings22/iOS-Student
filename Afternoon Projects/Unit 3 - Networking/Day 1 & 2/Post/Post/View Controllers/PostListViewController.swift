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
    }
    
    // MARK: - ACTIONS
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
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
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: "Please enter a new post", preferredStyle: .alert)
        alertController.addTextField { (messageTextField) in
            messageTextField.layer.borderWidth = 1
            messageTextField.placeholder = "Enter message"
        }
        alertController.addTextField { (usernameTextField) in
            usernameTextField.layer.borderWidth = 1
            usernameTextField.placeholder = "Enter username"
        }
        let submit = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let username = alertController.textFields?[1].text, let text = alertController.textFields?[0].text, !username.isEmpty, !text.isEmpty else {return}
            self.postController.addNewPostWith(username: username, text: text) { (results) in
                switch results {
                case .success(_):
                    print("success")
                    self.tableView.reloadData()
                case .failure(_):
                    print("fail")
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(submit)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true)
    }
}// end of class

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) { (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(_):
                        self.tableView.reloadData()
                    case .failure(_):
                        print()
                    }
                }
            }
        }
    }
}


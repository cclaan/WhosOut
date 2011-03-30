//
//  FavoriteUsersController.h
//  MoreSquare
//
//  Created by Chris Laan on 3/27/11.
//  Copyright 2011 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import "FSUserCell.h"

@interface FavoriteUsersController : UIViewController <UITableViewDelegate , UITableViewDataSource > {
	
	IBOutlet UITableView * tableView;
	
	
}

@end

//
//  ViewController.m
//  DataBaseDemo
//
//  Created by 张帅 on 13-5-20.
//  Copyright (c) 2013年 SHX. All rights reserved.
//

#import "ViewController.h"
#import "WMChatData.h"

@interface ViewController (){
    WMChatData *chatData;
}

@end
/*
    库名：song
    表名：S1
    字段：name,age,score,为方便都用了text
 */

@implementation ViewController

-(IBAction)click0:(id)sender
{
    chatData = [[WMChatData alloc]initWithDBName:@"song"];
    [chatData readDataBase];
}
-(IBAction)click1:(id)sender
{
    chatData = [[WMChatData alloc]initWithDBName:@"song"];
    [chatData readDataBase];
}
-(IBAction)click2:(id)sender
{
    [chatData createTable:@"S1" withArguments:@"name text, age text,score text"];
}
-(IBAction)click3:(id)sender
{
    [chatData insertTable:@"INSERT INTO S1 (name,age,score) VALUES (?,?,?)",@"songhx",@"23",@"78"];
}
-(IBAction)click4:(id)sender
{
    static int i = 23;
    [chatData updateTable:@"UPDATE S1 SET age = ? WHERE age = ? ",[NSString stringWithFormat:@"%d",i+1],[NSString stringWithFormat:@"%d",i]];
    i++;
}
-(IBAction)click5:(id)sender
{
   // NSMutableArray *arr = [chatData queryTable:@"SELECT * FROM S1 WHERE Age = ?",@"25"];
    NSMutableArray *arr = [chatData queryArguments:[NSArray arrayWithObjects:@"name",@"age", nil] withTable:@"SELECT * FROM S1 WHERE Age = ?",@"25"];
    NSLog(@"arr------%@",arr);
}
-(IBAction)click6:(id)sender
{
    [chatData updateTable:@"DELETE FROM S1 WHERE age = ?",@"25"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

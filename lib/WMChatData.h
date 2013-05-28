//
//  WMChatData.h
//  wb_malake
//
//  Created by songhx on 13-4-27.
//  Copyright (c) 2013年 axs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
//http://blog.csdn.net/iunion/article/details/7206570

@interface WMChatData : NSObject
{
    FMDatabase *_chatDB;
    NSString   *_DBName;
}
@property (nonatomic,strong)FMDatabase *chatDB;
@property (nonatomic,strong)NSString   *DBName;

-(id)initWithDBName:(NSString *)dbName;
//从NSBundle导入数据库到Documents
+(void)importDB:(NSString *)dbNAme;
//打开数据库
-(void)readDataBase;
//判断是否存在表
- (BOOL)isTableOK:(NSString *)tableName;  
//创建表
-(BOOL)createTable:(NSString *)tableName withArguments:(NSString *)arguments;
// 获得表的数据条数
- (BOOL) getTableItemCount:(NSString *)tableName;
// 删除表-彻底删除表
- (BOOL) deleteTable:(NSString *)tableName;
// 清除表-清数据
- (BOOL) eraseTable:(NSString *)tableName;
// 插入数据
- (BOOL)insertTable:(NSString*)sql,...;
// 修改数据
- (BOOL)updateTable:(NSString*)sql, ...;
//获取所有表名
-(NSArray *)getTableName:(NSString *)tableName;
//查询数据
-(void)queryTable:(NSString *)sql,...;
-(NSMutableArray *)queryArguments:(NSArray *)arguments  withTable:(NSString *)sql,...;

@end

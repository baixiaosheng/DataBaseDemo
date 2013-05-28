//
//  WMChatData.m
//  wb_malake
//
//  Created by songhx on 13-4-27.
//  Copyright (c) 2013年 axs. All rights reserved.
//

#import "WMChatData.h"


@implementation WMChatData
@synthesize chatDB = _chatDB;
@synthesize DBName = _DBName;
/**
    创建或者得到数据库
 */
-(id)initWithDBName:(NSString *)dbName
{
    self = [super init];
    if(nil != self){
        self.DBName = [self getPath:dbName];
    }
    return self;
}
/**
    获得数据库路径,内部使用
 */
-(NSString *)getPath:(NSString *)dbName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docPath stringByAppendingPathComponent:dbName];
}
/**
 导入外部数据库
 */
+(void)importDB:(NSString *)dbName
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success) {
        // The writable database does not exist, so copy the default to the appropriate location.
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    //  return writableDBPath;
}
/**
    打开数据库
 */
-(void)readDataBase
{
    _chatDB = [[FMDatabase alloc]initWithPath:_DBName];
    
    if (![_chatDB open])
    {
        [_chatDB close];
        NSAssert1(0, @"Failed to open database file with message '%@'.", [_chatDB lastErrorMessage]);
    }
    [_chatDB setShouldCacheStatements:YES];
}
/**
    判断表是否存在
 */
- (BOOL) isTableOK:(NSString *)tableName
{
    FMResultSet *rs = [_chatDB executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        DLog(@"isTableOK %d", count);
        
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}
/**
    创建表
 */
-(BOOL)createTable:(NSString *)tableName withArguments:(NSString *)arguments
{
    NSLog(@"arguments---%@",arguments);
    NSString *sqlstr = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", tableName, arguments];/** [DB executeUpdate:@"create table user (name text, pass text)"] */
    if (![_chatDB executeUpdate:sqlstr])
    {
        DLog(@"Create db error!");
        return NO;
    }
    
    return YES;
}
/**
    获取表的数据条数
 */
- (BOOL) getTableItemCount:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"SELECT count(*) as 'count' FROM %@", tableName];
    FMResultSet *rs = [_chatDB executeQuery:sqlstr];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        DLog(@"TableItemCount %d", count);
        
        return count;
    }
    return 0;
}
/**
    删除表
 */
- (BOOL) deleteTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![_chatDB executeUpdate:sqlstr])
    {
        DLog(@"Delete table error!");
        return NO;
    }
    
    return YES;
}
/**
    清空表
 */
- (BOOL) eraseTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    if (![_chatDB executeUpdate:sqlstr])
    {
        DLog(@"Erase table error!");
        return NO;
    }
    
    return YES;
}
/**
    获得所有表
 */
-(NSArray *)getTableName:(NSString *)tableName
{
    FMResultSet *rs = [_chatDB executeQuery:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"];
    NSMutableArray *tableNames = [[NSMutableArray alloc]initWithCapacity:0];
    while ([rs next])
    {
        NSString *name = [rs stringForColumn:@"name"];
        [tableNames addObject:name];
    }
    return tableNames;
}
/**
    插入数据
 */
- (BOOL)insertTable:(NSString*)sql,...
{
    va_list args;
    va_start(args, sql);
    
    BOOL result = [_chatDB executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:nil orVAList:args];
    /**     
     [chatData insertTable:@"INSERT INTO tableName (Name,Age,Score) VALUES (?,?,?)",@"songhx",@"23",@"78"];
     */
    
    va_end(args);
    return result;
}
/**
    修改数据
 */
- (BOOL)updateTable:(NSString*)sql, ...
{
    va_list args;
    va_start(args, sql);
    
    BOOL result = [_chatDB executeUpdate:sql error:nil withArgumentsInArray:nil orDictionary:nil orVAList:args];
    /**
        修改 [chatData updateTable:@"UPDATE tableName SET age = ? WHERE age = ? ",@"23",@"24"];
        删除  [chatData deleteTable:@"DELETE FROM S1 WHERE age = ?",@"25"];
     */
    va_end(args);
    return result;
}

/**
    查询数据
 */
/**
 查询数据 arguments:需要用到的数据库字段名
    NSMutableArray *arr = [chatData queryArguments:[NSArray arrayWithObjects:@"name",@"age", nil] withTable:@"SELECT * FROM S1 WHERE Age = ?",@"25"];
 模糊查询：@"select * from myTable where company like '%%%%%@%%%%';",searchString
 */
-(NSMutableArray *)queryArguments:(NSArray *)arguments  withTable:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    FMResultSet *rs = [_chatDB executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:0];
    while ([rs next])
    {
        NSMutableDictionary *theDic = [[NSMutableDictionary alloc]initWithCapacity:0];
        for(NSString *str in arguments){
            NSString *tmpStr = [rs stringForColumn:str];
            [theDic setObject:tmpStr forKey:str];
        }
        [dataArray addObject:theDic];
    }
    [rs close];
    va_end(args);
    return dataArray;
}
//查询数据,无返回,测试
-(void)queryTable:(NSString *)sql,...
{
    va_list args;
    va_start(args, sql);
    FMResultSet *rs = [_chatDB executeQuery:sql withArgumentsInArray:nil orDictionary:nil orVAList:args];
    NSMutableArray *dataArray = [[NSMutableArray alloc]initWithCapacity:0];
    while ([rs next])
    {

        NSString *name = [rs stringForColumn:@"name"];
        NSString *score = [rs stringForColumn:@"score"];
        NSString *age = [rs stringForColumn:@"age"];
        NSDictionary *theDic = [[NSDictionary alloc]initWithObjectsAndKeys:name,@"name",score,@"score",age,@"age" ,nil];
        [dataArray addObject:theDic];
    }
     [rs close];
      va_end(args);
    DLog(@"%@",dataArray);
}

- (void)dealloc {
    [_chatDB close];
    [_chatDB release];
    [_DBName release];
    [super dealloc];
}


@end

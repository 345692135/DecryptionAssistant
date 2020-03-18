//
//  FileLog.m
//  LogComponent
//
//  Created by nie on 12-7-24.
//  Copyright (c) 2012年 wondersoft. All rights reserved.
//

#import "FileLog.h"

@implementation FileLog

static FileLog* fileLogInstance = nil;
static bool binit = NO;

+ (FileLog*)getTypeFileInstance
{
    @synchronized(self){
        if (!fileLogInstance) {
            
            fileLogInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
    return fileLogInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    
    @synchronized(self){
        if (fileLogInstance == nil) {
            fileLogInstance = [super allocWithZone:zone];
        }
    }
    return fileLogInstance;      //  assingment and return first allocation
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
    //  Do Nothing
}

-(id)copyWithZone:(NSZone*)zone
{
    return  self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        if (binit == NO) {
            [self setlogPrintLevel:INFO];
            binit = YES;
        }
        
    }
    return self;
}

- (void)setlogPrintLevel:(LogLevel)Level
{
    logPrintLevel = Level;
}

- (FILE*)logFileOpen
{
    FILE *fp;           //log file's handls
    
    //  step 1  get path of Documents
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *logPath=[NSString stringWithFormat:@"%@/%@",documentsDirectory,@"logFile.txt"];
    
    //  step 2  create log file at Documents path
    
    fp=fopen([logPath UTF8String], "ab+");
    nSize=ftell(fp);
    if (nSize>FILE_CONTENTS_MAX_VAULE) {    //  when the size of file exeed 10M, empty file
        fclose(fp);
        fp=fopen([logPath UTF8String], "wb+");
    }
    
    if (fp==NULL) {
        NSLog(@" Can not open file %@",@"logFile.txt");
        return nil;
    }
    return fp;
    
}

- (void)writeLog:(LogLevel)Level logText:(NSString *)Log, ...
{
    
    FILE* fp = NULL;
    const char* szlog = NULL;
    va_list logList;
    NSString* strLog = NULL,*str_Level = NULL;
    
    @synchronized(self)
    {
        if (Level<=logPrintLevel) 
        {
            fp=[self logFileOpen]; 
            if(fp!=NULL)
            {
                //step 1 get param format log string
                
                if ([Log length]!=0) {
                    va_start(logList, Log);
                    strLog=[[NSString alloc]initWithFormat:Log arguments:logList];
                    va_end(logList);
                }
                
                if (Level == INFO) {
                    str_Level = @"INFO";
                }else if (Level == WARNNING) {
                    str_Level = @"WARN";
                }else if(Level == ERROR){
                    str_Level = @"ERRO";
                }
                NSString *str = [NSString stringWithFormat:@"%@ Level: [%@] Info: %@\r\n",[NSDate date],str_Level,strLog];
                
                //step 2 get write log string
                
                szlog=[str UTF8String];
                fwrite(szlog, strlen(szlog), 1, fp);
                fflush(fp);
                [strLog release];
                fclose(fp);
            }//if(fp!=NULL)
        }//if (Level<=logPrintLevel) do nothing 
    }// @synchronized(self)
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
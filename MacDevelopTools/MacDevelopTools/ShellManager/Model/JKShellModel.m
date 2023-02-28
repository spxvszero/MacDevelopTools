//
//  JKShellModel.m
//  MacDevelopTools
//
//  Created by jacky Huang on 2023/2/26.
//  Copyright © 2023 JK. All rights reserved.
//

#import "JKShellModel.h"
#include <util.h>
#import <objc/runtime.h>

@interface JKShellModel ()

@property (nonatomic, strong) NSPipe *inputPipe;

@property (nonatomic, assign) int master_fd;
@property (nonatomic, assign) int slave_fd;
@property (nonatomic, assign) int pid;

@property (nonatomic, strong) NSMutableString *displayStr;

@end

@implementation JKShellModel

+ (BOOL)supportsSecureCoding
{
    return true;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
}

- (void)dealloc
{
    [self closeShell];
}

+ (instancetype)modelWithName:(NSString *)name
{
    JKShellModel *m = [[JKShellModel alloc] init];
    m.name = name;
    return m;
}

- (void)writeString:(NSString *)str
{
    if (self.master_fd <= 0) {
        return;
    }
    // 获取输入管道的文件句柄
    NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:_master_fd];
    //        NSFileHandle *fileHandle = [self.inputPipe fileHandleForWriting];
    // 将输入文本写入输入管道
    NSData *inputData = [str dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:inputData];
}


- (void)startShell
{
    //    self.cmdQueue = dispatch_queue_create("com.example.taskQueue", DISPATCH_QUEUE_SERIAL);
    __weak typeof(self) weakSelf = self;
    //    dispatch_async(self.cmdQueue, ^{
    // 创建一个新的伪终端
    Ivar masterFdIvar = class_getInstanceVariable([self class], "_master_fd");
    int *masterFdPtr = (int *)((__bridge void *)weakSelf + ivar_getOffset(masterFdIvar));
    Ivar slaveFdIvar = class_getInstanceVariable([self class], "_slave_fd");
    int *slaveFdPtr = (int *)((__bridge void *)weakSelf + ivar_getOffset(slaveFdIvar));
    //    struct termios attr;
    //    tcgetattr(_slave_fd, &attr);
    //    attr.c_lflag &= ~ECHO;
    //    tcsetattr(_slave_fd, TCSANOW, &attr);
    
    pid_t pid;
    switch (pid = forkpty(masterFdPtr, NULL, NULL, NULL)) {
        case -1:
        {
            NSLog(@"Failed to forkpty: %s", strerror(errno));
            NSLog(@"Run In MainProcess. ");
            char slave_name[255];
            
            int res = openpty(masterFdPtr, slaveFdPtr, slave_name, NULL, NULL);
            if (res == -1) {
                NSLog(@"Failed to open pseudo-terminal");
                return;
            }else{
                NSLog(@"master -- %d",weakSelf.master_fd);
                NSLog(@"slave -- %d",weakSelf.slave_fd);
            }
            
            
            NSTask *task = [[NSTask alloc] init];
            //    [task setLaunchPath:@"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal"];
            [task setLaunchPath:@"/bin/zsh"];
            //    [task setArguments:@[@"-c", @"echo Hello World"]];
            
            //    NSPipe *pipe = [NSPipe pipe];
            //            NSPipe *inputPipe = [NSPipe pipe];
            //            self.inputPipe = inputPipe;
            
            // 将伪终端设为标准输入、输出和错误
            NSFileHandle *fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.slave_fd];
            //    task.standardInput = [[NSFileHandle alloc] initWithFileDescriptor:self.slave_fd];
            //    [task setStandardInput:inputPipe];
            task.standardInput = fileHandle;
            task.standardOutput = fileHandle;
            task.standardError = fileHandle;
            //    [task setStandardOutput:pipe];
            //    [task setStandardInput:inputPipe];
            //    NSFileHandle *file = [pipe fileHandleForReading];
            //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:file];
            //    [file readInBackgroundAndNotify];
            
            // 将伪终端从文件句柄中读取输入并显示在文本视图中
            NSFileHandle *mfileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.master_fd];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:mfileHandle];
            [mfileHandle readInBackgroundAndNotify];
            //    [fileHandle setReadabilityHandler:^(NSFileHandle *fh) {
            //        NSData *data = fh.availableData;
            //        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //           [self.textView insertText:string replacementRange:NSMakeRange(0, 0)];
            //        });
            //    }];
            
            
            [task launch];
        }
            break;
        case 0:
        {
            // In child process, execute ssh command.
            const char* cmd = "/bin/zsh";
            const char* args[] = { cmd, NULL };
            execvp(cmd, (char* const*)args);
            _exit(127);
        }
            break;
        default:
        {
            //close slave handler, or will cause dead loop.
            if (weakSelf.slave_fd > 0) {
                close(weakSelf.slave_fd);
                _slave_fd = -1;
            }
            // In parent process, read output from child.
            weakSelf.slave_fd = weakSelf.master_fd;
            
            if (login_tty(pid) < 0) {
                NSLog(@"Try Login Failed. Some device may could not work fine.");
            }
            self.pid = pid;
            
            NSFileHandle *mfileHandle = [[NSFileHandle alloc] initWithFileDescriptor:weakSelf.master_fd];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(dataReady:) name:NSFileHandleReadCompletionNotification object:mfileHandle];
            [mfileHandle readInBackgroundAndNotify];
        }
            break;
    }
    
    
    
    //    });
}

- (void)closeShell
{
    if (_master_fd > 0) {
        close(_master_fd);
        _master_fd = -1;
    }
    if (_slave_fd > 0) {
        close(_slave_fd);
        _slave_fd = -1;
    }
    if (self.pid > 0) {
        kill(self.pid, SIGKILL);
        self.pid = 0;
    }
}

- (BOOL)isRunning
{
    return self.master_fd > 0;
}

- (void)dataReady:(NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length]) {
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (string) {
                [self.displayStr appendString:string];
                [self updateStorageStrToTxtView];
            }
            //            [self updateStrForStorage:string];
        });
        NSLog(@"output -- %@",string);
        [[notification object] readInBackgroundAndNotify];
    } else {
        NSLog(@"finish cmd");
        //        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:[notification object]];
    }
}

- (void)updateStorageStrToTxtView
{
    if (self.UpdateStringBlock) {
        self.UpdateStringBlock(self.displayStr);
    }
}

- (NSMutableString *)displayStr
{
    if (!_displayStr) {
        _displayStr = [[NSMutableString alloc] init];
    }
    return _displayStr;
}


@end

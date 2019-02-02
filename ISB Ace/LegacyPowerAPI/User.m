//
//  User.m
//  PSAPI
//
//  Created by Kolatat Thangkasemvathana on 17/9/14.
//  Copyright (c) 2014 ISB Software Development Club. All rights reserved.
//
#import "PSAPI.h"

@implementation PSUser
BOOL demoMode = NO;
-(id)init:(PSCore *)core{
    _core=core;
    demoMode = NO;
    [self refresh];
    return self;
}
-(id)initInDemo:(PSCore *)core{
    _core = core;
    demoMode = YES;
    [self refresh];
    return self;
}
-(NSString*)fetchTranscript{
    return [_core request:@"guardian/studentdata.xml?ac=download"];
};
-(NSString*)fetchSchedule{
    if(!demoMode){
        //return [_core request:@"guardian/studentsched.html"];
        NSString *fullHTML = [_core request:@"guardian/myschedule.html"];
        NSArray *schedMatches = [Utils regexExtract:fullHTML regexPatternWithCaptureGroup:@"<table\\b[^>]*>(.*?)</table>"];//<table\b[^>]*>(.*?)</table>
        if(schedMatches) {
            return schedMatches[0][0];
        }
        return @"Schedule Coudn't be fetched";
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"demotable" ofType:@"html"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        //NSArray *HTMLS = [Utils regexExtract:content regexPatternWithCaptureGroup:@"~~~~~(.*)~~~~~"];
        //NSLog(@"content: %@", HTMLS[1];
        return content;
    }
}

-(NSArray*)createCourses{
    NSMutableArray* terms = [NSMutableArray arrayWithArray:[Utils regexExtract:_homeContents
                                                  regexPatternWithCaptureGroup:@"<tr class=\"center th2\">(.*?)</tr>"]];
    terms = [NSMutableArray arrayWithArray:[Utils regexExtract:terms[0][0]
                                  regexPatternWithCaptureGroup:@"<th rowspan=\"2\">(.*?)</th>"]];
    
    [terms removeObjectAtIndex:0];
    [terms removeObjectAtIndex:0];
    [terms removeLastObject];
    [terms removeLastObject];
    
    NSMutableArray* classes = [NSMutableArray arrayWithArray:[Utils regexExtract:_homeContents
                                                    regexPatternWithCaptureGroup:@"<tr class=\"center\" bgcolor=\"(.*?)\">(.*?)</tr>"]];
    //here
    NSMutableArray* allClasses = [NSMutableArray array];
    for(NSArray* class in classes){
        if([[Utils regexExtract:class[2]
   regexPatternWithCaptureGroup:@"<td align=\"left\">(.*?)(&nbsp;|&bbsp;)<br>(.*?)<a href=\"mailto:(.*?)\">(.*?)</a>(.*?)</td>"] count]==1){
            [allClasses addObject:[[PSCourse alloc] init:_core courseHTML:class[2]]];
        }
    }
    return allClasses;
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"coursehtmls" ofType:@"html"];
    //NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}
-(NSString*)getSchoolName{
    if(!demoMode){
        NSString* name = [Utils regexExtract:_homeContents
                regexPatternWithCaptureGroup:@"<div id=\"print-school\">(.*?)<br>"][0][1];
        return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else{
        return @"International School Bangkok";
    }
}
-(NSString*)getUserName{
    if(!demoMode){
        NSString* username = [Utils regexExtract:_homeContents
                    regexPatternWithCaptureGroup:@"<li id=\"userName\" .*?<span>(.*?)<span>"][0][1];
        return [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        return @"Rick Bedi";
    }
}
-(NSNumber*)getGPA{
    if(!demoMode){
        @try{
            NSString* strGPA = [Utils regexExtract:_homeContents regexPatternWithCaptureGroup:@"<td align=\"center\">Current.*?GPA \\((.*?)\\): ([^ ]*?)</td>"][0][2];
            NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            return [nf numberFromString:strGPA];
        }@catch(NSException *e){
            return @-5.000;
        }
    }else{
        return @4.800;
    }
}
-(void) refresh {
    if(!demoMode){
        NSString* result = [_core request:@"guardian/home.html"];
        if([result rangeOfString:@"Grades and Attendance"].location==NSNotFound){
            NSArray* error = [Utils regexExtract:result regexPatternWithCaptureGroup:@"<div class=\"feedback-alert\">(.*?)</div>"];
            NSString* errorString;
            if([error count]>0) errorString=error[0][1];
            else errorString=@"No error provided.";
            NSMutableDictionary* errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:errorString forKey:NSLocalizedDescriptionKey];
            _core.error=[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:NSNotFound userInfo:errorDetails];
            NSLog(@"%@",_core.error);
            return;
        }
        _homeContents=result;
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coursehtmls" ofType:@"html"];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _homeContents = content;
    }
    _courses=[self createCourses];
}
@end

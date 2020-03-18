//
//  ConvertTool.m
//  Mobile Connection
//
//  Created by cao zhuwei on 08-5-28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ConvertTool.h"

typedef unsigned char byte;
typedef unsigned char ascii;
typedef unsigned char hex;
typedef unsigned int hexunichar;


static ascii uchar_to_ascii(unsigned char uch)
{
	ascii asc = 0;
	if(uch >= '0' && uch <= '9')		asc = uch - '0';
	else if(uch >= 'a' && uch <= 'f')	asc = uch - 'a' + 10;
	else if(uch >= 'A' && uch <= 'F')	asc = uch - 'A' + 10;
	return asc;
}

static unsigned char hex_to_uchar(hex he)
{
	unsigned char ch = '0';
	if(he <= 9)						ch = he + '0';
	else if(he >= 10 && he <= 15)	ch = he + 'A' - 10;
	return ch;
}

static byte doubleuchar_to_byte(unsigned char firstuch,unsigned char secondcuch)
{
	byte bt = 0;
	ascii firstasc	= uchar_to_ascii(firstuch);
	ascii secondasc	= uchar_to_ascii(secondcuch);
	bt = firstasc;
	bt = bt << 4;
	bt = bt  + secondasc;
	return bt;
}

static unichar hexunichar_to_unichar(hexunichar hexstr)
{
	unichar unich = 0;
	unsigned char *pstr = (unsigned char*)&hexstr;
	
	unsigned char firstch = *pstr;
	unsigned char secondch = *(++pstr);
	byte bt = doubleuchar_to_byte(firstch,secondch);
	firstch = *(++pstr);
	secondch = *(++pstr);
	unich = bt;
	unich = unich << 8;
	unich = unich + doubleuchar_to_byte(firstch,secondch);
	
	return unich;
	/*
	 unichar unich = 0;
	 unsigned char *pstr = (unsigned char*)&hexstr;
	 unsigned char ch = *pstr;
	 while(ch != 0)
	 {
	 unsigned char firstch = ch;
	 unsigned char secondch = *(++pstr);
	 byte bt = doubleuchar_to_byte(firstch,secondch);
	 
	 firstch = *(++pstr);
	 secondch = *(++pstr);
	 unich = bt;
	 unich = unich << 8;
	 unich = unich + doubleuchar_to_byte(firstch,secondch);
	 
	 pstr ++;
	 ch = *pstr;
	 
	 }
	 return unich;
	 
	 */
}

static void hexstr_to_unichar(const char *sz_src,unichar *sz_target)
{
	
	int len = strlen(sz_src)/4;
	unsigned int *plsrc = (unsigned int*)sz_src;
	unichar *uni_target = sz_target;
	unsigned int lsrc = *plsrc;
	
	int i;
	for(i = 0;i < len;i ++)
	{
		*uni_target = hexunichar_to_unichar(lsrc);

		printf("unichar:%x\n",*uni_target);

		uni_target ++;
		plsrc ++;
		lsrc = *plsrc;
	}

}

static void unichar_to_hexstr(unichar *unichar_src,unsigned char *hexstr_target)
{
	unichar *unich = unichar_src;
	
	unsigned char *lstr = hexstr_target;
	
	unichar ch = *unich;
	while(ch != 0)
	{
		unsigned char chr = 0 ;
		
		chr = ch >> 12;
		*lstr = hex_to_uchar(chr);
		lstr ++;
		
		chr = (ch >> 8) & 0xf;
		*lstr = hex_to_uchar(chr);
		lstr ++;
		
		chr = (ch >> 4) & 0xf;
		*lstr = hex_to_uchar(chr);
		lstr ++;
		
		chr = ch & 0xf;
		*lstr = hex_to_uchar(chr);
		lstr ++;
		
		unich ++;
		ch = *unich;
	}
}


static int unicharLen(unichar *unistr)
{
	unichar *unch = unistr;
	int len = 0;
	unichar ch = *unch;
	while(ch != 0)
	{
		unch ++;
		len ++;
		ch = *unch;
	}
	return len;
}



@implementation ConvertTool
+ (BOOL)verifyString:(NSString *)strString
{
	if(strString == nil || [[strString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) return NO;
	return YES;
}

+ (BOOL)isPhoneNumber:(NSString *)strNumber
{
	if(strNumber == nil || [[strNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) return NO;
	int charCount = [strNumber length];

	if(charCount >20 )
		return NO;
	
	int i;
	for(i = 0;i < charCount;i ++)
	{
		char ch = [strNumber characterAtIndex:i];
		if((ch < 48 || ch > 57) && ch != 43 && ch != 42 && ch != 35 && ch != 80)  //+43 *42 #35 P80
			return NO;
	}
	return YES;
}

+ (NSString *)convertHexStringToString:(NSString *)strHexString
{
	if(![ConvertTool verifyString:strHexString]) return @"";

	const char *sz_src = [strHexString UTF8String];
	
	
	int len = [strHexString length]/4;
	
	unichar *target = (unichar *)malloc((len+1)*sizeof(unichar));
	memset(target,0,(len+1)*sizeof(unichar));
	
	hexstr_to_unichar(sz_src,target);
	
	NSString *strName =[NSString stringWithCharacters:target length:(len+1)];
	free(target);
	return strName;
}

+ (NSString *)convertStringToHexString:(NSString *)strString
{
	if(![ConvertTool verifyString:strString]) return @"";
	
	int len = [strString length];
	
	unichar *unistr = (unichar *)malloc((len+1)*sizeof(unichar));
	memset(unistr,0,(len+1)*sizeof(unichar));
	[strString getCharacters:unistr];
	
	unsigned char *pstr = (unsigned char *)malloc((len+1)*sizeof(unichar)*2);
	memset(pstr,0,(len+1)*sizeof(unichar)*2);
	
	unichar_to_hexstr(unistr,pstr);
	NSString *strHexString = [NSString stringWithCString:(char *)pstr];
	//NSString *strHexString = [NSString stringWithCString:(char *)pstr encoding:NSUTF16StringEncoding];
	free(unistr);
	free(pstr);
	return strHexString;
}


//convert wchar string -> NSString
//+ (NSString*)wcStringtoNstring: (const wchar_t*)wcString
//{
//	int len = wcslen(wcString);
//	NSString *nsString;
//	
//	unichar *uniString = (unichar*)malloc((len+1) * sizeof(unichar));
//	
//	memset(uniString, 0, (len+1) * sizeof(unichar));
//	
//	wchars2unichars(uniString, wcString);
//	
//	nsString = [NSString stringWithCharacters:uniString length:len];
//	
//	free(uniString);
//	
//	return nsString;
//}


+ (unichar *)NstringtoUnistr:(NSString *)nsString
{
	if(nsString == nil) 
		return nil;
 	
	NSString* intString = [NSString stringWithString:nsString];

	int len = [nsString length];
	unichar *uniString = (unichar*)malloc((len+1) * sizeof(unichar));
	memset(uniString, 0, (len+1) * sizeof(unichar));
	[nsString getCharacters:uniString];
	 
	//convert full chinese char to half char
	NSUInteger index=0;
	for(index = 0; index <  [intString length] ; index++)
	{ 
		unichar tmpUnichar = [intString characterAtIndex:index];
		
		int H = (tmpUnichar & 0XFF00) >> 8;
		int L = (tmpUnichar & 0x00FF);
		
		UInt8 theStringChar[2];
		theStringChar[1] = H;
		theStringChar[0] = L;
		
		long value = H*256 + L ;
		if(tmpUnichar > 65280 && tmpUnichar < 65375)
		{	
			theStringChar[0] = (char)(tmpUnichar - 65248);
			theStringChar[1] = 0 ;
		}
		else if(value == 12288)
		{
			theStringChar[0] = 32 ;
			theStringChar[1] = 0 ;
		}
		
		tmpUnichar = ((theStringChar[1] << 8) & 0xFF00) + theStringChar[0] ;
		
		switch (tmpUnichar)
		{
				case 0x22ef: // ... key
					tmpUnichar =  0x2026;
					break;
				case 0x0009: // table key
					tmpUnichar =  0x20;
				break;
			default:
				break;


		}
		
			
		uniString[index] = tmpUnichar;
 	 }
	
	
	return uniString;
}

+ (unichar *)contentStringToUnistr:(NSString *)nsString
{
	if(nsString == nil) 
		return nil;
	
	int len = [nsString length]+2;
	unichar *uniString = (unichar*)malloc((len+1) * sizeof(unichar));
	memset(uniString, 0, (len+1) * sizeof(unichar));
	[nsString getCharacters:uniString];
	
	return uniString;
}

//+ (NSString*) UnistrtoNstring: (unichar *)unistr
//{
//	unsigned int len = sms_unistrlen(unistr);
//	
//	NSString *nsString = [NSString stringWithCharacters:unistr length:len];
//	
//	return nsString;
//}


+ (NSString*) filterDisPhoneString:(NSString *)strNumber 
{
	NSMutableString *strFilteredString = [NSMutableString string];
	int len = [strNumber length];
	int i;
	for(i = 0;i < len;i ++)
	{
		unichar ch = [strNumber characterAtIndex:i];
		if((ch < 48 || ch > 57) && ch != '+' && ch != '*' && ch != '#' && ch != 'p'  && ch != 'P')
		{
			continue;
		}
		[strFilteredString appendFormat:@"%c",ch];
	}
	
	
	return strFilteredString;
}


+ (NSString *)changeISO88591StringToUnicodeString:(NSString *)iso88591String
{
    
    NSMutableString *srcString = [[[NSMutableString alloc]initWithString:iso88591String]autorelease];
    
    [srcString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [srcString length])];
    [srcString replaceOccurrencesOfString:@"&#x" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [srcString length])];
    
    NSMutableString *desString = [[[NSMutableString alloc]init] autorelease];
    
    NSArray *arr = [srcString componentsSeparatedByString:@";"];
    
//    for(int i=0;i<[arr count]-1;i++){
//        
//        NSString *v = [arr objectAtIndex:i];
//        char *c = malloc(3);
//        int value = [StringUtil changeHexStringToDecimal:v];
//        c[1] = value  &0x00FF;
//        c[0] = value >>8 &0x00FF;
//        c[2] = '\0';
//        [desString appendString:[NSString stringWithCString:c encoding:NSUnicodeStringEncoding]];
//        free(c);
//    }
//    
    return desString;
}

+(NSString *) utf8ToUnicode:(NSString *)string

{
    
    NSUInteger length = [string length];
    
    NSMutableString *s = [NSMutableString stringWithCapacity:0];
    
    for (int i = 0;i < length; i++)
        
    {
        
        unichar _char = [string characterAtIndex:i];
        
        //判断是否为英文和数字
        
        if (_char <= '9' && _char >='0')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
            
        }
        
        else if(_char >='a' && _char <= 'z')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
            
            
            
        }
        
        else if(_char >='A' && _char <= 'Z')
            
        {
            
            [s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
            
            
            
        }
        
        else
            
        {
            
            [s appendFormat:@"\\u%x",[string characterAtIndex:i]];
            
        }
        
    }
    
    return s;
    
}

+ (NSString*) replaceUnicode:(NSString*)aUnicodeString

{
    
    NSString *tempStr1 = [aUnicodeString stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                           
                                                          mutabilityOption:NSPropertyListImmutable
                           
                                                                    format:NULL
                           
                                                          errorDescription:NULL];
    
    
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
}
@end

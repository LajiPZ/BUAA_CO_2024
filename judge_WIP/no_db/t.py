import re  
import os
import difflib
  
# 定义正则表达式模式  
pattern = re.compile(r'@[0123456789abcdefx]{8}: ((\$ [1-9][0-9]{0,1} <= [0123456789abcdefx]{8})|(\*[0123456789abcdefx]{8} <= [0123456789abcdefx]{8}))')  
  
# 打开并读取文件内容  
with open('isim_out.temp', 'r') as file:  
    lines = file.readlines()  
# 过滤并输出符合条件的行  
with open('isim_out.txt', 'w') as file1:   
    for line_num, line in enumerate(lines, start=1):  
        if pattern.match(line.strip()):  
                print(f"{line.strip()}",file=file1)  
  
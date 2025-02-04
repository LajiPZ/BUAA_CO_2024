def append_file_with_newline(source_file, destination_file):
    # 尝试打开源文件并读取内容
    try:
        with open(source_file, 'r', encoding='utf-8') as src:
            source_content = src.read()
    except FileNotFoundError:
        print(f"Error: {source_file} not found.")
        return
 
    # 检查源文件内容是否以换行符结尾
    if not source_content.endswith('\n'):
        source_content += '\n'  # 如果不是，则添加一个换行符
 
    # 尝试打开目标文件并追加内容
    try:
        with open(destination_file, 'a', encoding='utf-8') as dest:
            # 由于我们已经确保了source_content以换行符结尾，这里不需要再添加
            dest.write(source_content)
    except FileNotFoundError:
        # 如果目标文件不存在，'a' 模式会自动创建它
        print(f"Warning: {destination_file} not found, creating a new one.")
        with open(destination_file, 'a', encoding='utf-8') as dest:
            dest.write(source_content)
 
# 调用函数，将source.txt的内容（新开一行）追加到code.txt的末尾
append_file_with_newline('code_ktext.txt', 'code.txt')
 
print("Content appended with newline successfully.")
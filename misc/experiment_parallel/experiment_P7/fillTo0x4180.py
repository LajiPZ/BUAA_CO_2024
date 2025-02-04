def generate_padded_text(fill_content, needed_lines):
    # Create a list of lines filled with the specified content
    lines = [fill_content] * needed_lines
    return '\n'.join(lines)

# 尝试打开code.txt文件并读取内容，同时计算行数
with open('code_text.txt', 'r') as file:
    code_content = file.readlines()
    code_lines_count = len(code_content)

# 设置填充内容和目标总行数
fill_content = "00000000"
target_total_lines = 1120

# 计算需要填充的行数
needed_padding_lines = target_total_lines - code_lines_count

# 如果需要填充的行数为正数，则生成填充文本
if needed_padding_lines > 0:
    padded_text = generate_padded_text(fill_content, needed_padding_lines)
else:
    padded_text = ""  # 不需要填充，填充文本为空

# 将code.txt的内容和填充文本结合写入padded_text.txt文件
with open('code.txt', 'w') as file:
    file.writelines(code_content)  # 写入code.txt的内容
    file.write(padded_text)  # 追加填充文本（如果有的话）
    file.write('\n')

print(f"Generated text (including content from code_text.txt) has been written to 'code.txt' with a total of {target_total_lines} lines.")
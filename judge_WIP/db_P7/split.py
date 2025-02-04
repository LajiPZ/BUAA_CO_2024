def split_document(input_file, output_file1, output_file2, delimiter=".ktext"):
    """
    将文档根据指定的分隔符（默认为 .ktext）分割成两个文档。

    :param input_file: 输入文件的路径
    :param output_file1: 第一个输出文件的路径
    :param output_file2: 第二个输出文件的路径
    :param delimiter: 用于分割文档的分隔符
    """
    try:
        with open(input_file, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        
        # 找到分隔符所在的行索引
        delimiter_index = None
        for i, line in enumerate(lines):
            if delimiter in line:
                delimiter_index = i
                break
        
        if delimiter_index is None:
            raise ValueError(f"Delimiter '{delimiter}' not found in the input file.")
        
        # 分割文档内容
        part1 = lines[:delimiter_index + 1]  # 包含分隔符行
        part2 = lines[delimiter_index + 1:]  # 不包含分隔符行
        
        # 写入到两个新文件中
        with open(output_file1, 'w', encoding='utf-8') as file1:
            file1.writelines(part1)
        
        with open(output_file2, 'w', encoding='utf-8') as file2:
            file2.writelines(part2)
        
        print(f"Document split successfully. Part 1 saved to {output_file1}, Part 2 saved to {output_file2}.")
    
    except FileNotFoundError:
        print(f"The input file '{input_file}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# 示例使用
input_path = '.\\mars\\testCode.asm'  # 替换为你的输入文件路径
output_path1 = '.\\mars\\text.asm'  # 替换为你希望保存的第一个输出文件路径
output_path2 = '.\\mars\\ktext.asm'  # 替换为你希望保存的第二个输出文件路径

split_document(input_path, output_path1, output_path2)
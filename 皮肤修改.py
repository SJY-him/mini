import re
import os
def find_and_modify_skin_number(file_path, new_number):
    try:
        # 读取二进制文件
        with open(file_path, 'rb') as f:
            data = f.read()
        pattern = rb'skin_(\d+)'
        match = re.search(pattern, data)
        if not match:
            print("未找到任何关于皮肤的内容")
            return False
        old_skin_str = match.group(0).decode('ascii')
        old_number = match.group(1).decode('ascii')
        start_pos, end_pos = match.span(0)  # 匹配的起止位置
        # 构造新的字符串
        new_skin_str = f"skin_{new_number}".encode('ascii')
        # 修改二进制数据
        modified_data = data[:start_pos] + new_skin_str + data[end_pos:]
        with open(file_path, 'wb') as f:
            f.write(modified_data)
        print(f"修改成功！旧值：{old_skin_str} → 新值：skin_{new_number}")
        return True
    except Exception as e:
        print(f"发生错误：{e}")
        return False
if __name__ == "__main__":
    file_path = "C:\\Users\\86138\\AppData\\Roaming\\miniworddata110\\data\\w24764845752922\\wglobal.fb"  # 文件路径
    new_number = 482 # 装扮ID后三位
    find_and_modify_skin_number(file_path, new_number)
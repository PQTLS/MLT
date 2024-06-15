import os
import csv

# 读取输入的数据文件
with open('s_server_output.csv', 'r') as input_file:
    data = input_file.readlines()

data_dict = {}

# 遍历数据，提取每组数据并操作
# for i in range(0, len(data), 4):
i = 0
while i < len(data):
    while len(data[i].strip()) != 16:
        i=i+1
    timestamp =data[i].strip()
    folder_path = data[i + 1].strip()
    ke_alg = data[i + 2].strip()
    # 构造键值
    key = ke_alg
    i=i+4
    # 创建键值对应的列表
    if key not in data_dict:
        data_dict[key] = []
    # 将数据添加到相应的列表中
    data_dict[key].append((timestamp))

# 将数据写入文件
for ke_alg, data_list in data_dict.items():
    # 构造文件名
    filename = os.path.join(folder_path, f"{ke_alg}_earlydata_server.csv")
    # 将数据写入文件
    with open(filename, 'a', newline='') as output_csv:
        csv_writer = csv.writer(output_csv)
        timestamps = [ke_alg]
        for timestamp in data_list:
            timestamps.append(timestamp)
        csv_writer.writerow(timestamps)





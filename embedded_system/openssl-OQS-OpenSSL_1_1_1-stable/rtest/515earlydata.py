import csv
import os
folder_path = "newdata/earlydata515/20240516011253"

# 获取文件夹下的所有文件
file_list = os.listdir(folder_path)
sorted_file_list = sorted(file_list)
#print(sorted_file_list)
# 遍历文件列表，两两处理
for i in range(0,len(sorted_file_list),2):
    File1 = os.path.join(folder_path, sorted_file_list[i])
    File2 = os.path.join(folder_path, sorted_file_list[i+1])   
    # 这里可以根据需要编写处理文件的代码
    print("处理文件对：", File1, File2)

    # 读取第一个文件
    data1 = []
    with open(File1, newline='') as file1:
        reader = csv.reader(file1)
        for row in reader:
            data1.append([row[0]] + [float(val) for val in row[1:]])

    # 读取第二个文件
    data2 = []
    with open(File2, newline='') as file2:
        reader = csv.reader(file2)
        for row in reader:
            data2.append([row[0]] + [float(val) for val in row[1:]])

    # 计算差值

    result = []
    for row1, row2 in zip(data1, data2):
        result_row = [row1[0]] + [round((row2[i] - row1[i])* 0.001,5) for i in range(1, len(row1))]
        result.append(result_row)

    result_file_path = File1[:-11]+'.csv' # 删除文件名的最后四个字符
        #result_file_path = os.path.join(folder_path, result_file)
    # 如果目标文件不存在，则创建新文件并写入数据
    with open(result_file_path, 'w', newline='') as result_file:
        writer = csv.writer(result_file)
        for row in result:
            writer.writerow(row)

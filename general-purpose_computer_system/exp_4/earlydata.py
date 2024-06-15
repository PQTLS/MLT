import csv
import os
Folder_path = ["data/0","data/3","data/5"]

for folder_path in Folder_path:

    file_list = os.listdir(folder_path)
    sorted_file_list = sorted(file_list)

    for i in range(0,len(sorted_file_list),2):
        File1 = os.path.join(folder_path, sorted_file_list[i])
        File2 = os.path.join(folder_path, sorted_file_list[i+1])   

        print("Process files", File1, File2)


        data1 = []
        with open(File1, newline='') as file1:
            reader = csv.reader(file1)
            for row in reader:
                data1.append([row[0]] + [float(val) for val in row[1:]])

        data2 = []
        with open(File2, newline='') as file2:
            reader = csv.reader(file2)
            for row in reader:
                data2.append([row[0]] + [float(val) for val in row[1:]])

        result = []
        for row1, row2 in zip(data1, data2):
            result_row = [row1[0]] + [round((row2[i] - row1[i])* 0.001,5) for i in range(1, len(row1))]
            result.append(result_row)

        result_file_path = File1[:-11]+'.csv'
        with open(result_file_path, 'w', newline='') as result_file:
            writer = csv.writer(result_file)
            for row in result:
                writer.writerow(row)


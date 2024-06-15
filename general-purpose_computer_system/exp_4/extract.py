import os
import csv

with open('s_server_output.csv', 'r') as input_file:
    data = input_file.readlines()

alg_dict = {}

i = 0
while i < len(data):
    while len(data[i].strip()) != 16:
        i=i+1
    timestamp =data[i].strip()
    folder_path = data[i + 1].strip()
    ke_alg = data[i + 2].strip()
    alg = ke_alg
    loss = data[i + 3].strip()
    i=i+5

    if alg not in alg_dict:
        alg_dict[alg] = {}
    if loss not in alg_dict[alg]:
        alg_dict[alg][loss] = []
    alg_dict[alg][loss].append((timestamp))

for alg, alg_list in alg_dict.items():
    for loss, data_list in alg_list.items():
        filename = os.path.join(folder_path,str(loss),f"{alg}_earlydata_server.csv")
        print(filename)
        with open(filename, 'a', newline='') as output_csv:
            csv_writer = csv.writer(output_csv)
            timestamps = [alg]
            for timestamp in data_list:
                timestamps.append(timestamp)
            csv_writer.writerow(timestamps)





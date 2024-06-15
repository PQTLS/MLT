# import subprocess

# # 执行命令并将输出保存到文件
# command = 'sudo ip netns exec server_namespace apps/openssl s_server -nocert -psk 123456 -early_data'

# with open('output.txt', 'w') as output_file:
#     process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, text=True)
#     print("Process started")

#     try:
#         # 持续读取子进程的输出并写入文件，直到进程结束或收到中断信号
#         while True:
#             line = process.stdout.readline()
#             if line:
#                 output_file.write(line)
#                 print(line, end='')  # 打印到控制台
#             else:
#                 if process.poll() is not None:
#                     break
#                 else:
#                     print("No output from subprocess yet")

#     except KeyboardInterrupt:
#         print("KeyboardInterrupt received, terminating process")
#         process.terminate()  # 发送终止信号给子进程
#         process.wait()       # 等待子进程终止

#     print("Process finished")

# print("Output saved to output.txt")

# import subprocess

# # 执行命令并将输出保存到文件
# command = 'sudo ip netns exec server_namespace apps/openssl s_server -nocert -psk 123456 -early_data'

# with open('output.txt', 'w') as output_file:
#     process = subprocess.Popen(command, shell = True,stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
#     print("Process started")
#     try:
#         # 持续读取子进程的输出并写入文件，直到进程结束
#         while True:
#             # 读取标准输出
#             line = process.stdout.readline()
#             if line:
#                 output_file.write(line)
#                 print(line, end='')  # 打印到控制台
#             else: 
#                 if process.poll() is not None:
#                     break
#                 else:
#                     print("No output from subprocess yet")
#     except KeyboardInterrupt:
#         print("KeyboardInterrupt received, terminating process")
#         process.terminate()  # 发送终止信号给子进程
#         process.wait()       # 等待子进程终止

#     print("Process finished")

# print("Output saved to output.txt")
# import subprocess

# def run_s_server(namespace):
#     command = f"sudo ip netns exec {namespace} apps/openssl s_server -nocert -psk 123456 -early_data"
#     process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    
#     with open('s_server_output.txt', 'w') as output_file:
#         for line in iter(process.stdout.readline, b''):
#             output_file.write(line.decode())
#             print(line.decode(), end='')  # 如果你想在终端中查看输出，可以取消注释这一行

# if __name__ == "__main__":
#     namespace = "server_namespace"  # 更换为你的命名空间名称
#     run_s_server(namespace)
import subprocess


command = "sudo ip netns exec server_namespace ../apps/openssl s_server -nocert -psk 123456 -early_data"
process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)

with open('s_server_output.csv', 'w') as output_file:
    early_data_started = False  # 标记是否开始了 Early data
    for line in iter(process.stdout.readline, b''):
        line_str = line.decode(errors='ignore').strip()
        if early_data_started:
            if line_str == "End of early data":
                early_data_started = False
            else:
                output_file.write(line_str + '\n')
        elif line_str.startswith("Early data received:"):
            early_data_started = True



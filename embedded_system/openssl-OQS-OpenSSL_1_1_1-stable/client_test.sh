#!/bin/bash

# 客户端命名空间名称
CLIENT_NAMESPACE="client"
SERVER_NAMESPACE="server"
# 服务器地址和端口
SERVER_HOST="192.168.1.1"
SERVER_PORT="4433"
# 待测试的算法列表
ALGORITHMS=("nttru" "nttruref" "kyber768" "sntrup761")

# 设置网络延迟和丢包率的参数
# 使用for循环迭代创建元组中的元素
for ((i=0; i<=5; i+=5)); do
    DELAYS+=("$i""ms")
done
# 使用for循环迭代创建元组中的元素
for i in {0..4}; do
    loss_rate=$(bc <<< "scale=1; $i * 0.1")
    formatted_loss_rate=$(printf "%.1f%%" $loss_rate)
    LOSS_RATES+=("$formatted_loss_rate")
done
# 总结果文件
TOTAL_RESULTS_FILE="total_results_client.txt"
TOTAL_RESULTS="total_results_bidui.txt"

# 清空或创建总结果文件
> "$TOTAL_RESULTS_FILE"
> "$TOTAL_RESULTS"
# 循环进行实验

#printf "%-10s%-15s" "Algorithms" "Delay"
#for loss_rate in "${LOSS_RATES[@]}"; do
#    printf "%-10s" "$loss_rate"
#done
#printf "\n"
tableTitle="Algorithms\t\tDelay\t\t"
for loss_rate in "${LOSS_RATES[@]}"; do
    tableTitle+="\t\t\t"
done
tableTitle+="Loss Rate\n"

tableTitle+="\t\t\t\t\t\t\t\t\t\t\t"
for loss_rate in "${LOSS_RATES[@]}"; do
    tableTitle+="$loss_rate\t\t\t\t\t\t"
done


echo -e "$tableTitle" >> "$TOTAL_RESULTS_FILE" 

for algorithm in "${ALGORITHMS[@]}"; do

    for delay in "${DELAYS[@]}"; do
        # 初始化表格
        table="$algorithm\t\t\t$delay\t\t\t\t\t\t\t" &&
        for loss_rate in "${LOSS_RATES[@]}"; do

            echo "Testing Algorithm: $algorithm, Delay: $delay, Loss Rate: $loss_rate" &&
         
            # 使用 netem 设置网络延迟和丢包率
            sudo ip netns exec "$CLIENT_NAMESPACE" tc qdisc add dev veth1 root netem delay "$delay" loss "$loss_rate" &&
            # 等待5秒 
            #sleep 5   
            echo "3"
            # 运行 openssl s_time 进行测试，将结果附加到总结果文件
            result=$(sudo ip netns exec "$CLIENT_NAMESPACE" apps/openssl s_time -connect "$SERVER_HOST:$SERVER_PORT" -new -curves "$algorithm" 2>&1)
            # 等待5秒 
            #sleep 5 
            echo "4"
            # 记录到总结果文件
            echo -e "Algorithm: $algorithm\tDelay: $delay\tLoss Rate: $loss_rate\n$result\n" >> "$TOTAL_RESULTS" &&
           
            # 从结果中提取连接速度数据
            #connection_speeds=$(grep -oP "\K\d+\.\d+ connections in" <<< "$result" | cut -d' ' -f1) &&
            connection_speeds=$(echo "$result" | grep -oP "^\d+" | head -1)
            modified_speeds=$(echo -e "$connection_speeds" | sed ':a;N;$!ba;s/\n/\t\t/g') &&
            
            table+="$modified_speeds\t\t\t\t\t\t" &&
            # 移除 netem 设置
           
            sudo ip netns exec "$CLIENT_NAMESPACE" tc qdisc del dev veth1 root &&
            echo "9"
            #sudo ip netns exec server tc qdisc show dev veth0 &&
            #sudo ip netns exec client tc qdisc show dev veth1
        done
            # 追加表格数据到总结果文件
            echo -e "$table\n" >> "$TOTAL_RESULTS_FILE";
    done
done

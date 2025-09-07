#!/bin/bash
# install_welcome.sh
# 一键安装彩虹欢迎脚本

TARGET="/usr/local/bin/welcome.sh"
BASHRC="$HOME/.bashrc"

echo "正在安装彩虹欢迎脚本到 $TARGET ..."

# 创建 welcome.sh 文件
sudo tee "$TARGET" > /dev/null << 'EOF'
#!/bin/bash
# /usr/local/bin/welcome.sh
# 平滑彩虹渐变欢迎脚本（RGB渐变）

clear

# 彩虹渐变函数
rainbow_color() {
    local i=$1
    local length=$2
    local hue=$(awk -v i="$i" -v len="$length" 'BEGIN{print (i/len)*360}')
    local c=$(awk -v h="$hue" 'BEGIN{
        h=h/60; x=1-((h%2)-1); if(x<0)x=-x; r=0; g=0; b=0;
        if(h<1){r=1; g=x; b=0}
        else if(h<2){r=x; g=1; b=0}
        else if(h<3){r=0; g=1; b=x}
        else if(h<4){r=0; g=x; b=1}
        else if(h<5){r=x; g=0; b=1}
        else{r=1; g=0; b=x}
        printf("%d;%d;%d", int(r*255), int(g*255), int(b*255))
    }')
    echo "$c"
}

print_gradient_line() {
    local line="$1"
    local length=${#line}
    for ((i=0;i<length;i++)); do
        rgb=$(rainbow_color $i $length)
        char="${line:$i:1}"
        echo -ne "\e[38;2;${rgb}m${char}\e[0m"
    done
    echo ""
}

read -r -d '' ASCII_ART << "ART"
 ░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░▒▓███████▓▒░░▒▓███████▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░      ░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░      ░▒▓█▓▒░
░▒▓████████▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░          ░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░     ░▒▓█▓▒░░▒▓█▓▒░  ░▒▓█▓▒░          ░▒▓█▓▒░▒▓█▓▒░             ░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓██████▓▒░   ░▒▓█▓▒░   ░▒▓███████▓▒░░▒▓████████▓▒░▒▓███████▓▒░

ART

while IFS= read -r line; do
    print_gradient_line "$line"
done <<< "$ASCII_ART"

echo ""
echo -e "\e[36m================= System Status =================\e[0m"

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
echo -e "CPU Usage: \e[38;2;255;255;0m$CPU%\e[0m"

MEM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
echo -e "Memory Usage: \e[38;2;0;255;0m$MEM\e[0m"

DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2 " used (" $5 ")"}')
echo -e "Disk Usage: \e[38;2;0;150;255m$DISK\e[0m"

UPTIME=$(uptime -p)
echo -e "Uptime: \e[38;2;255;0;255m$UPTIME\e[0m"

echo -e "\e[36m=================================================\e[0m"
EOF

# 赋予执行权限
sudo chmod +x "$TARGET"

# 检查 bashrc 是否已添加调用
if ! grep -Fxq "$TARGET" "$BASHRC"; then
    echo "$TARGET" >> "$BASHRC"
    echo "已将 welcome.sh 添加到 $BASHRC，登录时会自动显示。"
else
    echo "welcome.sh 已经存在于 $BASHRC，无需重复添加。"
fi

echo "安装完成！请重新登录终端以查看效果。"

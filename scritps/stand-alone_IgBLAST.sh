#! /bin/bash

# 下载安装文件
wget https://ftp.ncbi.nih.gov/blast/executables/igblast/release/LATEST/ncbi-igblast-1.22.0-x64-linux.tar.gz

# 解压文件
tar -xzvf ncbi-igblast-1.22.0-x64-linux.tar.gz

# 进入文件夹
cd ncbi-igblast-1.22.0

# 创建文件夹
mkdir myseq
mkdir database
mkdir result
mkdir ref_seq

echo "succeed in installing stand-alone IgBLAST program in Linux os"

# 构建human germline参考数据库
cd ../
chmod +x human_gl_db_install.sh
./human_gl_db_install.sh

# 构建mouse germline参考数据库
cd ../
chmod +x mouse_gl_db_install.sh
./mouse_gl_db_install.sh


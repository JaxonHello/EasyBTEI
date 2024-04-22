#! /bin/bash

## 下载mouse参考序列
cd ref_seq
mkdir mouse
cd mouse

# 从网站上下载mouse IMGT VDJ参考序列
wget -r -np -nH --cut-dirs=10 --accept '*.fasta'  https://www.imgt.org/download/V-QUEST/IMGT_V-QUEST_reference_directory/Mus_musculus/IG/


# 在文件名前面加mouse前缀
for file in *.fasta; do
    mv "$file" "mouse_$file"
done

# 将Heavy, Kappa, Lambda的V,(D),J序列合并起来
cat *V*.fasta > mouse_V.fasta
cat *D*.fasta > mouse_D.fasta
cat *J*.fasta > mouse_J.fasta

# 下载C区序列
# 1. 从github上下载
# wget https://github.com/JaxonHello/EasyBTEI/blob/main/resource/IMGT_mouse_gl_C.fasta
# 2. 如果github无法下载，请下载到本地文件夹并进行以下处理
# 确保在本地的序列位置在与igblast同级别的source文件夹
mv ../../../source/IMGT_mouse_gl_C.fasta mouse_C.fasta

# 处理mouse_C.fasta的序列名称，只留下IGHG*01这样的类型
awk -F '|' '/^>/ {sub(/^>.*/, ">"$2)} 1' mouse_C.fasta > tmp && mv tmp mouse_C.fasta

# 处理mouse_C.fasta中的重复序列，使其变成IGHG1*01-1这样的形式
awk '/^>/ {
    if ($0 in seen) {
        seen[$0]++;
    } else {
        seen[$0] = 1;
    }
    print $0 "-" seen[$0];
    next;
} 
{print}' mouse_C.fasta > tmp && mv tmp mouse_C.fasta

## 构建mouse数据库
cd ../../database
mkdir mouse
cd ../

# 移动并处理germline seq
bin/edit_imgt_file.pl ref_seq/mouse/mouse_V.fasta > database/mouse/mouse_V.fasta
bin/edit_imgt_file.pl ref_seq/mouse/mouse_D.fasta > database/mouse/mouse_D.fasta
bin/edit_imgt_file.pl ref_seq/mouse/mouse_J.fasta > database/mouse/mouse_J.fasta
bin/edit_imgt_file.pl ref_seq/mouse/mouse_C.fasta > database/mouse/mouse_C.fasta

# 扩展为数据库格式
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_V.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_D.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_J.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_C.fasta

echo "succeed in installing mouse germline VDJC database in IgBLAST!!"

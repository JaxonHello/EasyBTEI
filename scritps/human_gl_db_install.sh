#! /bin/bash


####################################
## 下载human参考序列
cd ref_seq
mkdir human
cd human

# 从网站上下载human IMGT VDJ参考序列
wget -r -np -nH --cut-dirs=10 --accept '*.fasta'  https://www.imgt.org/download/V-QUEST/IMGT_V-QUEST_reference_directory/Homo_sapiens/IG/

# 在文件名前面加human前缀
for file in *.fasta; do
    mv "$file" "human_$file"
done

# 将Heavy, Kappa, Lambda的V,(D),J序列合并起来
cat *V*.fasta > human_V.fasta
cat *D*.fasta > human_D.fasta
cat *J*.fasta > human_J.fasta

# 下载C区序列
# 1. 从github上下载
# wget https://github.com/JaxonHello/EasyBTEI/blob/main/resource/IMGT_human_gl_C.fasta
# 2. 如果github无法下载，请下载到本地文件夹并进行以下处理
# 确保在本地的序列位置在与igblast同级别的source文件夹
mv ../../../source/IMGT_human_gl_C.fasta human_C.fasta

# 处理mouse_C.fasta的序列名称，只留下IGHG*01这样的类型
awk -F '|' '/^>/ {sub(/^>.*/, ">"$2)} 1' human_C.fasta > tmp && mv tmp human_C.fasta

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
{print}' human_C.fasta > tmp && mv tmp human_C.fasta

## 构建human数据库
cd ../../database
mkdir human
cd ../

# 移动并处理germline seq
bin/edit_imgt_file.pl ref_seq/human/human_V.fasta > database/human/human_V.fasta
bin/edit_imgt_file.pl ref_seq/human/human_D.fasta > database/human/human_D.fasta
bin/edit_imgt_file.pl ref_seq/human/human_J.fasta > database/human/human_J.fasta
bin/edit_imgt_file.pl ref_seq/human/human_C.fasta > database/human/human_C.fasta

# 扩展为数据库格式
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_V.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_D.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_J.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_C.fasta

echo "succeed in installing human germline VDJC database in IgBLAST!!"

#! /bin/bash

cd ncbi-igblast-1.22.0
cd ref_seq
mkdir human
cd human

# 从网站上下载human IMGT VDJ reference fasta file
wget -r -np -nH --cut-dirs=10 --accept '*.fasta'  https://www.imgt.org/download/V-QUEST/IMGT_V-QUEST_reference_directory/Homo_sapiens/IG/

# 在文件名前加human前缀
for file in *.fasta; do
    mv "$file" "human_$file"
done

# 将Heavy, Kappa, Lambda的V, J合并起来
cat *V*.fasta > human_V.fasta
cat *D*.fasta > human_D.fasta
cat *J*.fasta > human_J.fasta

# 由于C区数据库无法下载，请参考获得完整的C区germline reference seq
# https://www.imgt.org/genedb/fastaC.action
# 从github下载已经我们自己构建好的C区fasta文件(由于长城防火墙的存在会导致下载失败)
wget https://github.com/JaxonHello/EasyBTEI/blob/main/resource/IMGT_human_gl_C.fasta
mv IMGT_human_gl_C.fasta human_C.fasta && rm IMGT_human_gl_C.fasta

# 处理human_C.fasta的序列名称
awk -F '|' '/^>/ {sub(/^>.*/, ">"$2)} 1' human_C.fasta > tmp && mv tmp human_C.fasta

# 处理human_C.fasta的重复序列，给重复序列命名
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


# 开始构建数据库

# 将germline序列移动到database/human文件夹
# 在database下创建human dir
cd ../../database
mkdir human
# 回到igblast dir 
cd ../

# 移动并预处理germline seq
bin/edit_imgt_file.pl ref_seq/human/human_V.fasta > database/human/human_V.fasta
bin/edit_imgt_file.pl ref_seq/human/human_D.fasta > database/human/human_D.fasta
bin/edit_imgt_file.pl ref_seq/human/human_J.fasta > database/human/human_J.fasta
bin/edit_imgt_file.pl ref_seq/human/human_C.fasta > database/human/human_C.fasta

# 转换为数据库格式
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_V.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_D.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_J.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/human/human_C.fasta

# 成功构建human germline VDJC数据库
echo "succeed in installing human germline VDJC database in IgBLAST!!"

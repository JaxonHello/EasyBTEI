#! /bin/bash

cd ncbi-igblast-1.22.0
cd ref_seq
mkdir mouse
cd mouse

# 从网站上下载mouse IMGT VDJ reference fasta file
wget -r -np -nH --cut-dirs=10 --accept '*.fasta'  https://www.imgt.org/download/V-QUEST/IMGT_V-QUEST_reference_directory/Mus_musculus/IG/

# 在文件名前加mouse前缀
for file in *.fasta; do
    mv "$file" "mouse_$file"
done

# 将Heavy, Kappa, Lambda的V, J合并起来
cat *V*.fasta > mouse_V.fasta
cat *D*.fasta > mouse_D.fasta
cat *J*.fasta > mouse_J.fasta

# 由于C区数据库无法下载，请参考获得完整的C区germline reference seq
# https://www.imgt.org/genedb/fastaC.action
# 从github下载已经我们自己构建好的C区fasta文件(由于长城防火墙的存在会导致下载失败)
wget https://github.com/JaxonHello/EasyBTEI/blob/main/resource/IMGT_mouse_gl_C.fasta
mv IMGT_mouse_gl_C.fasta mouse_C.fasta && rm IMGT_mouse_gl_C.fasta

# 处理mouse_C.fasta的序列名称
awk -F '|' '/^>/ {sub(/^>.*/, ">"$2)} 1' mouse_C.fasta > tmp && mv tmp mouse_C.fasta

# 处理mouse_C.fasta的重复序列，给重复序列命名
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


# 开始构建数据库

# 将germline序列移动到database/mouse文件夹
# 在database下创建mouse dir
cd ../../database
mkdir mouse
# 回到igblast dir 
cd ../

# 移动并预处理germline seq
bin/edit_imgt_file.pl fasta/mouse/mouse_V.fasta > database/mouse/mouse_V.fasta
bin/edit_imgt_file.pl fasta/mouse/mouse_D.fasta > database/mouse/mouse_D.fasta
bin/edit_imgt_file.pl fasta/mouse/mouse_J.fasta > database/mouse/mouse_J.fasta
bin/edit_imgt_file.pl fasta/mouse/mouse_C.fasta > database/mouse/mouse_C.fasta

# 转换为数据库格式
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_V.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_D.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_J.fasta
bin/makeblastdb -parse_seqids -dbtype nucl -in database/mouse/mouse_C.fasta

# 成功构建mouse germline VDJC数据库
echo "succeed in installing mouse germline VDJC database in IgBLAST!!"
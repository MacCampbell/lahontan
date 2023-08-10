#!/bin/bash -l

#reads in a file of sample names to do read counts on files   

list=$1

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
        string="sed -n ${x}p ${list}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')   
        set -- $var
        c1=$1
        

       echo "#!/bin/bash -l
       samtools index ${c1}.sort.flt.bam
       reads=\$(samtools view -c ${c1}.sort.bam)
       rmdup=\$(samtools view -c ${c1}.sort.flt.bam)
       depth=\$(samtools depth -a ${c1}.sort.flt.bam | awk '{sum+="\$3"} END {print sum/NR}' )
       echo \"${c1},\${reads},\${rmdup},\${depth}\"  > ${c1}.stats" > ${c1}.sh
       sbatch -p med -t 6:00:00 --mem=8G ${c3}.sh

       x=$(( $x + 1 ))

done



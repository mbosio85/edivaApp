PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ 
set -e

#### INPUT variables
export TMPFOLDER='/tmp/'$1
export USERNAME=$2
export INFILE=$3
export HOMEDIR=$(pwd)
export BASENAME=$(basename $INFILE)


mkdir -p $TMPFOLDER
cp   $HOMEDIR/$INFILE     $TMPFOLDER/input.vcf

export HOMEDIR=$(pwd)
cd $TMPFOLDER 
 export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail 
  python $HOMEDIR/edivatools-code/Annotate/annotate.py --input input.vcf -s complete -f  # > $HOMEDIR/userspace/$2/.job.log 2>&1

  Rscript $HOMEDIR/edivatools-code/Prioritize/wrapper_call.R $HOMEDIR/edivatools-code/Prioritize/ediva_score.rds input.sorted.annotated.csv ranked.csv   # >> $HOMEDIR/userspace/$2/.job.log 2>&1

echo $(pwd)
cd $HOMEDIR
echo $(pwd)


OUTNAME=${BASENAME%.vcf*}
cp $TMPFOLDER/ranked.csv $HOMEDIR/userspace/$USERNAME/$OUTNAME.ranked.csv
rm -r $TMPFOLDER/



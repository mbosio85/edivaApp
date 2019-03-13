set -e
#usage:
# template_prioritize.sh $TMPDIR $USERNAME  $INHERITANCE $TRIO $INFILE $HPO $EXCLUSIONLIST

# ts template_prioritize XXX123DDQ$ guest all hpo.txt
#export NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
export TMPFOLDER='/tmp/'$1
export USERNAME=$2
export INHERITANCE=$3
export TRIO=$4
export INFILE=$5
export HPO='hpo.txt'
#export EXCLUSIONLIST=$6

export HOMEDIR=$(pwd)
export BASENAME=$(basename $INFILE)
#echo $BASENAMEi
if [[ ! -z "$6" ]] ; then

   export EXCLUSIONLIST="--geneexclusion "$HOMEDIR/$6
   export EXCLUSIONLIST="--geneexclusion "$6

fi
echo $TMPFOLDER
echo $USERNAME
echo $INHERITANCE
echo $TRIO
echo $HPO
echo $EXCLUSIONLIST

# standard imports
PATH=$PATH:/home/rrahman/soft/tabix-0.2.6/:/home/rrahman/soft/ts-0.7.5/ 
#export TS_ONFINISH=/var/www/html/ediva/current/ts_outmail 

#make tmpdir and copy stuff
mkdir -p $TMPFOLDER/
cp   $HOMEDIR/$INFILE     $TMPFOLDER/input.csv
cp   $HOMEDIR/userspace/$USERNAME/family.txt  $TMPFOLDER/family.txt
#cp   $HPO    $TMPFOLDER/hpo.txt
mv $HOMEDIR/userspace/$USERNAME/.hpo_tmp.txt $TMPFOLDER/$HPO
touch $TMPFOLDER/$HPO

cd $TMPFOLDER
# run prioritization inheritances:

  # compound - only for trio and single sample
    if ( [ "$INHERITANCE" == 'compound' ] && [ "$TRIO" != 'family' ] )  || ( [ "$INHERITANCE" == 'all' ] && [ "$TRIO" != 'family' ] ) ; then
        python $HOMEDIR/edivatools-code/Prioritize/familySNP_gene_score.py \
            --infile input.csv \
            --outfile unfiltered.compound.csv \
            --filteredoutfile filtered.compound.csv \
            --family family.txt \
            --inheritance compound \
            --familytype $TRIO \
            --HPO_list $HPO \
            $EXCLUSIONLIST  \
       >> .job.log 2>&1

         zip -ur prioritization_analysis.zip filtered.compound.csv unfiltered.compound.csv

    fi



# Dominant denovo
    if  [ "$INHERITANCE" == 'dominant_denovo' ] || [ "$INHERITANCE" == 'all' ] || [ "$INHERITANCE" == 'dominant' ] ; then
        echo $INHERITANCE
        if [ "$TRIO" == 'Single_sample' ] ; then
	   OUTCSV='unfiltered.dominant.csv'
	   OUTCSVF='filtered.dominant.csv'
	   MYTRIO='family'
	else
	   OUTCSV='unfiltered.dominant_denovo.csv'
	   OUTCSVF='filtered.dominant_denovo.csv'
           MYTRIO=$TRIO
	       
	fi
        python $HOMEDIR/edivatools-code/Prioritize/familySNP_gene_score.py \
            --infile input.csv \
            --outfile $OUTCSV \
            --filteredoutfile $OUTCSVF \
            --family family.txt \
            --inheritance dominant_denovo \
            --familytype $MYTRIO \
            --HPO_list $HPO \
            $EXCLUSIONLIST  \
            >> .job.log 2>&1
        
        zip -ur prioritization_analysis.zip $OUTCSV $OUTCSVF
    fi

# Dominant inherited
    if ( [ "$INHERITANCE" == 'dominant_inherited' ] && [ "$TRIO" != 'Single_sample' ] )  || ( [ "$INHERITANCE" == 'all' ] && [ "$TRIO" != 'Single_sample' ] ) ; then
        python $HOMEDIR/edivatools-code/Prioritize/familySNP_gene_score.py \
            --infile input.csv \
            --outfile unfiltered.dominant_inherited.csv \
            --filteredoutfile filtered.dominant_inherited.csv \
            --family family.txt \
            --inheritance dominant_inherited \
            --familytype $TRIO \
            --HPO_list $HPO \
            $EXCLUSIONLIST  \
            >> .job.log 2>&1
        
        zip -ur prioritization_analysis.zip filtered.dominant_inherited.csv unfiltered.dominant_inherited.csv
    fi
    
 # Recessive
    if [ "$INHERITANCE" == 'recessive' ] || [ "$INHERITANCE" == 'all' ] ; then
        if [ "$TRIO" == 'Single_sample' ] ; then
	    MYTRIO='family'
        else
            MYTRIO=$TRIO
	fi
        python $HOMEDIR/edivatools-code/Prioritize/familySNP_gene_score.py \
            --infile input.csv \
            --outfile unfiltered.recessive.csv \
            --filteredoutfile filtered.recessive.csv \
            --family family.txt \
            --inheritance recessive \
            --familytype $MYTRIO \
	    --HPO_list $HPO \
            $EXCLUSIONLIST  \
            >> .job.log 2>&1
        
        zip -ur prioritization_analysis.zip filtered.recessive.csv  unfiltered.recessive.csv 
    fi
    
  # Xlinked
    if ( [ "$INHERITANCE" == 'Xlinked' ] && [ "$TRIO" != 'Single_sample' ] ) || ( [ "$INHERITANCE" == 'all' ] && [ "$TRIO" != 'Single_sample' ] ) ; then
        python $HOMEDIR/edivatools-code/Prioritize/familySNP_gene_score.py \
            --infile input.csv \
            --outfile unfiltered.Xlinked.csv \
            --filteredoutfile filtered.Xlinked.csv \
            --family family.txt \
            --inheritance Xlinked \
            --familytype $TRIO \
            --HPO_list $HPO \
            $EXCLUSIONLIST  \
           >> .job.log 2>&1
        
         zip -ur prioritization_analysis.zip filtered.Xlinked.csv unfiltered.Xlinked.csv 
    fi      
    
    

# package the results
   zip -ur prioritization_analysis.zip variant_prioritization_report.xlsx .job.log
# copy the results in the output folder
   cd $HOMEDIR
   #echo $(pwd)
   OUTNAME=${BASENAME%.sorted.annotated.ranked.csv*} 
   cp $TMPFOLDER/prioritization_analysis.zip $HOMEDIR/userspace/$USERNAME/$OUTNAME.$INHERITANCE.prioritization.zip
# clean up tmpdir
   rm -r $TMPFOLDER/
  


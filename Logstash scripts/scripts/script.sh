#!/bin/bash

export accounts=`cat /etc/scripts/accounts.config`

for account in $accounts; do

  cd /mnt/CloudTrail/$account/files
  export filelist=`ls *.json.gz`

  for file in $filelist; do
    export filecheck=`echo $file | awk -F. '{print $1}'`
    if [ `ls $filecheck* | wc -l` -le 1 ]; then
      export file_no_gz=`ls $file | awk -F\. '{print $1"."$2}'`
      gzip -cd $file > $file_no_gz
      if [[ -s $file_no_gz ]] ; then
        cat $file_no_gz | sed -e '$s/\}$//' -e 's/{"Records"://g' -e 's/{"_return":true}/"user"/g' | jq -c '.[]' | sed -e 's/{"responseElements":"<responseOmitted>"/{"responseElements":{}/g' -e 's/{"responseElements":null/{"responseElements":{}/g' -e 's/{"responseElements":"user"/{"responseElements":{}/g' >> /mnt/CloudTrail/$account/logs/$account.log
      else
        rm -f $file_no_gz $file
      fi
    fi
  done
done

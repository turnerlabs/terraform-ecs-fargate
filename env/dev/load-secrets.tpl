#!/bin/bash
set -e

kv_to_json () {
   echo -n '{'

   WC=$(grep -v -e "^\s*$" hidden.env | wc -l)
   count=1
   while IFS='' read -r line; do
     printf '"%s":"%s"' $(echo $line | sed 's/=/ /')
     (( count++ ))
     if [ $count -le $WC ]; then
      echo -n ","
     fi
   done < <(grep -v -e "^\s*$" hidden.env)

   echo '}'
}

AWS_PROFILE=${aws_profile}
AWS_DEFAULT_REGION=${region}
NAME=${secret}
export AWS_PROFILE  AWS_DEFAULT_REGION

if [ -e "./hidden.env" ]; then

   FIND=$(aws secretsmanager describe-secret --secret-id $NAME)

   if [[ $FIND =~ "can't find the specified secret" ]]; then
     aws secretsmanager create-secret \
        --name $NAME \
        --description "$NAME" \
        --secret-string $(kv_to_json)
   elif [[ $FIND =~ "arn:aws:secretsmanager:" ]]; then
     aws secretsmanager update-secret \
        --secret-id $NAME \
        --secret-string $(kv_to_json)
   else
      echo "I couldn't tell if the secret was there."
   fi
else
  echo "No hidden.env."
fi

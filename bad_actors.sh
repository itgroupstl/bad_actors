#!/bin/bash

path="/var/log/nginx"
access_logs=$(find $path -name "access*")

threshold=20
codes=("301" "302" "400" "401" "500")



# Initialize spinner (a couple to choose from)
spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠻⠽'
#spinner='⠋⠹⠦⠏'
#spinner='⠋⠙⠚⠞⠖⠦⠴⠲⠳⠓'
#spinner='⠄⠆⠇⠋⠙⠸⠰⠠⠰⠸⠙⠋⠇⠆'
#spinner='⠋⠙⠚⠒⠂⠂⠒⠲⠴⠦⠖⠒⠐⠐⠒⠓⠋'
delay=0.1

# Define spinner function
spinner() {
  while true
  do
    for i in `seq 0 9`
    do
      printf "\r$1${spinner:$i:1}"
      sleep $delay
    done
  done
}

position_ip=1
#Declare an array
declare -a bad_actors

#Declare an associative array
declare -A ip_codes_count


  # Set message
  msg="Analyzing log files ...... \xF0\x9F\x94\x8E  "

  # Start spinner
  spinner "$msg" &

  # Save spinner PID
  spinner_pid=$!


for log_file in $access_logs; do
  echo "---$log_file------------------"

  if [[ "$log_file" =~ \.tar\.gz$ ]]; then
    tar -xzf $log_file
    log_file=${log_file%.tar.gz}
  fi


  if [[ "$log_file" =~ \.gz$ ]]; then
    gunzip -c $log_file > $log_file.unzipped
    log_file=$log_file.unzipped
  fi



    #Read each line from the access log
    while read line; do

        ip=$(echo $line | awk -v pos_ip="$position_ip" '{print $pos_ip}')
        http_code=$(echo $line | grep -oE ' [2-5]{1}[0-9]{2} ')
      
      #Check if the array element for the IP address exists
      if [[ -z "${ip_codes_count[$ip]}" ]]; then
        #If not, create the array element and set it to the HTTP code
        ip_codes_count[$ip]=$http_code
      else
        #If it does exist, add the HTTP code to the array element
        ip_codes_count[$ip]="${ip_codes_count[$ip]} $http_code"
      fi
    done < $log_file

    #Loop through each array element
    for ip in "${!ip_codes_count[@]}"; do
      #Loop through each HTTP code associated with the IP address
      for code in $(echo ${ip_codes_count[$ip]} | tr ' ' '\n' | sort | uniq); do
        #Extract the count for each HTTP code
        count=$(echo ${ip_codes_count[$ip]} | tr ' ' '\n' | grep -c $code)
        #Print out the IP address and the HTTP code with the count
        #echo "IP: $ip HTTP code: $code Count: $count"


        if [[ " ${codes[@]} " =~ " ${code} " ]] && [[ "$count" -ge "$threshold" ]]; then
          bad_actors+=("$ip ($count)")
        fi

      done
    done
done

  # Remove backup file
  rm "$path"/*.unzipped

  # Stop spinner
  kill $spinner_pid

  printf "\n Analyzation Complete \xF0\x9F\x9A\x80 \n"




if [[ ${#bad_actors[@]} -gt 0 ]]; then
  printf "Bad actors: \xF0\x9F\x98\xA1 \n"
  printf '%s\n' "${bad_actors[@]}"
fi





#!/bin/bash
# Making sure we recieve all parameters
arr_of_params=($@)
error=0
help_message="Usage: calculatePayment.sh <vaild_file_name> [More_Files] ... <money>"
regex_numbers="^[0-9]+([.][0-9]+)?$"
# checking if the parameters are populated using condition with -z 
if [[ ${#arr_of_params[@]}<2 ]] ; then
    empty_params=${#arr_of_params[@]}
    >&2 echo "Number of parameters received : $empty_params"
    error=1

#if we dont exit we can continue with the compution 
elif  [[ ! ${arr_of_params[${#arr_of_params[@]}-1]} =~ $regex_numbers ]] ; then
    >&2 echo "Not a valid number : ${arr_of_params[${#arr_of_params[@]}-1]}"
    error=1

else 
    for((i=0; i<$((${#arr_of_params[@]}-1)) ; i++)) ; do
       if [[ ! -f ${arr_of_params[i]} ]] ; then
          >&2 echo "File does not exist : ${arr_of_params[i]}"
          error=1
        fi
    done
fi
if  [[ $error -eq 1 ]] ; then
    >&2 echo "$help_message"

elif [[ $error -eq 0 ]] ; then 
    sum=0
    for((i=0; i<$((${#arr_of_params[@]}-1)) ; i++)) ; do
        sum=$((sum + $( cat ${arr_of_params[i]} | grep -Eo '[0-9]+(\.[0-9]+)?' )))
        # we are using piping to first read the file and then look for the numbers with grep -E for regex and o for only matching numbers that mathc, int or maybe also float. 
        # the (.)? is for the option that we may have point and numbers(float)
    done
    printf "Total purchase price : %.2f\n" "$sum"
    if [[ ${arr_of_params[${#arr_of_params[@]}-1]} -lt $sum ]] ; then
        printf "You need to add %.2f shekel to pay the bill\n" "$(($sum - ${arr_of_params[${#arr_of_params[@]}-1]}))"
    elif [[ ${arr_of_params[${#arr_of_params[@]}-1]} -gt $sum ]] ; then
        printf "Your change is %.2f shekel\n" "$((${arr_of_params[${#arr_of_params[@]}-1]} - $sum))"
    elif [[ ${arr_of_params[${#arr_of_params[@]}-1]} -eq $sum ]] ; then
        echo "Exact payment"
    fi
fi






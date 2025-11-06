#!/bin/bash
# Making sure we recieve all parameters
arr_of_params=($@)
error=0
help_message="Usage: calculatePayment.sh <vaild_file_name> [More_Files] ... <money>"
regex_numbers="^[0-9]+([.][0-9]+)?$"
# checking if the parameters are populated using condition with -z 
if [[ ${#arr_of_params[@]} -lt 2 ]] ; then
    empty_params=${#arr_of_params[@]}
    >&2 echo "Number of parameters received : $empty_params"
    error=1

#if we dont exit we can continue with the compution 
elif  [[ ! ${arr_of_params[${#arr_of_params[@]}-1]} =~ $regex_numbers ]] ; then
    >&2 echo "Not a valid number : ${arr_of_params[${#arr_of_params[@]}-1]}"
    error=1

else 
    for ((i=0; i<$((${#arr_of_params[@]}-1)) ; i++)) ; do
       if [[ ! -f ${arr_of_params[i]} ]] ; then
          >&2 echo "File does not exist : ${arr_of_params[i]}"
          error=1
        fi
    done
fi
if  [[ $error -eq 1 ]] ; then
    echo "$help_message"

elif [[ $error -eq 0 ]] ; then 
    sum=0
    for ((i=0; i<$((${#arr_of_params[@]}-1)) ; i++)) ; do
        curr=$(cat ${arr_of_params[i]} | grep -Eo '[0-9]+(\.[0-9]+)?'|tr '\n' '+'|head -c -1 )
        if [[ -z $curr ]] ; then 
            curr=0
        fi
        sum=$(echo "$sum + $curr" | bc )
        # we are using piping to first read the file and then look for the numbers with grep -E for regex and o for only matching numbers that mathc, int or maybe also float. 
        # the (.)? is for the option that we may have point and numbers(float)
        # head -c counts the chars we want (including all) and chosess the wanted, by length of the string so head -c -1 chosess all except the last +
    done
    printf "Total purchase price : %.2f\n" "$sum"
    #change_maybe -> he owes money if positive else we owe change
    change_maybe=$(echo "$sum - ${arr_of_params[${#arr_of_params[@]}-1]}" | bc)
    #change_for_sure is to print also decimal without arithmetical errors :)
    change_for_sure=$(echo "${arr_of_params[${#arr_of_params[@]}-1]} - $sum" | bc)

    owe_money=$(echo "$change_maybe > 0" | bc)
    #returns like true/false (1/0) for >0 or not |bc is for computing rational numbers
    # we will use only the true becasue false also mentioning equal to 0
    owe_chagne=$(echo "$change_maybe < 0" | bc)
    #now we get 1 if it is less and not equal to 0 so we are safe and tackling the 0 issue from owe_money
    if [[ $owe_money -eq 1 ]] ; then
        printf "You need to add %.2f shekel to pay the bill\n" "$change_maybe"
    elif [[ $owe_chagne -eq 1 ]] ; then
        printf "Your change is %.2f shekel\n" "$change_for_sure"
    else 
        echo "Exact payment"
    fi
fi

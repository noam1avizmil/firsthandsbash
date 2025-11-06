!#bin/bash
# Making sure we recieve all parameters

# checking if the parameters are populated using condition with -z 
if (( [-z $1 || -z $2])); do
    empty_params = 0;
    for((i = 0; i < 2; i++)); do
        if( [ -z ${!i} ]); do
        empty_params = $((empty_params + 1))
        fi
    done
    >&2 echo "Number of parameters received : [$empty_params]"
fi
#if we dont exit we can continue with the compution 
else if (( [$2 < 0])); do
    >&2 echo "Not a valid number : [$2]"
fi
else if (( [$1 ]))

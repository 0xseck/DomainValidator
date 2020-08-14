#!/usr/bin/env bash


usage(){
    
    echo -e "\nUSAGE:"
    echo -e "\t-t [num]\tthreads\t\tThread number"
    echo -e "\t-v      \tverbose\t\tPrint error messages"
    echo -e "\t-r      \tsave records\twrite valid records to validrecords.txt file"
    echo -e "\t-h      \thelp\t\tThis page"
    exit 1
}



validate_domain(){

    
    if [[ -z $verbose ]]
    then
        if [[ -z  $records ]]
        then
            resp="$(dig +noall +answer `echo $1 | awk '{print $1}'` 2>>.validate_err.log)" 
        else
            resp="$(dig +noall +answer `echo $1 | awk '{print $1}'` 2>>.validate_err.log |  awk '{print $1" " $4" "$5}' | tee -a validrecords.txt)"
        fi
    else
        if [[ -z $records ]]
        then
            resp="$(dig +noall +answer `echo $1 | awk '{print $1}'`)"
        else
            resp="$(dig +noall +answer `echo $1 | awk '{print $1}'` | awk '{print $1" "$4" "$5}' | tee -a validrecords.txt)"
        fi
    fi
    if [ ! -z "$resp" ]
    then
        echo "$1"
    fi

}

while getopts ":t:vr" opt
do
    case ${opt} in
	   t )
        thread=$OPTARG
      ;;
   \? )
        usage 
   ;;
    : )
        echo "Invalid option: $OPTARG requires an argument" 1>&2;usage; 
      ;;
    v )
        verbose=1
      ;;
    h )
        usage
      ;;
    r )
        records=1
      ;;
    esac
done
shift $((OPTIND -1))

if [[ ! -z $thread  ]] &&  [[ ! $thread =~ ^[0-9]+$ ]] ; then
   echo "Invalid option: Thread is not a number" >&2; usage
fi

if [[ -z $thread ]];then thread=50;fi # default is 50
readarray -t subdomains <<< ${1-$(</dev/stdin)}

if [[ ! -z $1  ]]
then
    readarray -t subdomains <<< `cat "$1"`
fi


process_control=1

for subdomain in "${subdomains[@]}"
do
    validate_domain "$subdomain" &
    last=$!
    if [[ $((prc%thread)) = "0"  ]]
    then
        wait $last
        process_control=1
    fi
    ((process_control++))
done

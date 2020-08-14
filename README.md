# DomainValidator

DomainValidator is a basic bash script that's helpful when validating massdns results.

## Usage
```
        -t [num]        threads         Thread number
        -v              verbose         Print error messages
        -r              save records    write valid records to validrecords.txt file
        -h              help            This page
```
It takes domain list from pipe, or you can specify file name

    cat massdns_out.txt | ./validate.sh -t 200 -v -r 
    ./validate.sh -t 200 -v -r massdns_out.txt

    Domains doesn't have to be in massdns' format. You can just pass domain names too.

    echo google.com | ./validate.sh

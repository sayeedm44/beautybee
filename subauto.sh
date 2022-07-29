#!/usr/bin/bash
echo "
            ___.                  __          
  ________ _\_ |__ _____   __ ___/  |_  ____  
 /  ___/  |  \ __ \\__  \ |  |  \   __\/  _ \
 \___ \|  |  / \_\ \/ __ \|  |  /|  | (  <_> )
/____  >____/|___  (____  /____/ |__|  \____/ v1.1 
     \/          \/     \/                    

"

help(){
  echo "
Usage: ./subauto.sh [options] -d domain.com
Options:
    -h            Display this help message.
   

 Target:
    -d            Specify the domain to scan.
Example:
    ./subauto.sh -d hackerone.com

"
}

POSITIONAL=()

if [[ "$*" != *"-d"* ]]
then
	help
  exit
fi

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    help
    exit
    ;;
    -d|--domain)
    d="$2"
    shift
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "starting subauto $d"

echo "Starting our subdomain enumeration force..."

echo "Amass passive..."
amass enum -passive -d $d -o $d_amass_passive.txt

echo "Amass brute..."
amass enum -brute -d $d -o s$d_amass_brute.txt

echo "Starting sublist3r..."
sublist3r -d $d -o $d_sublist3r.txt

echo "Starting subfinder..."
subfinder -d $d -all -t 100 -o $d_subfinder.txt

echo "Starting assetfinder..."
assetfinder $d --subs-only | dnsgen - | tee -a $d_assetfinder.txt

echo "Starting findomain..."
findomain -t $d -u $d_findomain.txt

echo "Starting crt.sh..."
crt.sh $d >> $d_crtsh.txt

echo "Starting gauplus..."
gauplus -t 5 -random-agent -subs $d |  unfurl -u domains | anew $d_gauplus.txt

echo "Starting waybackurls..."
waybackurls $d |  unfurl -u domains | tee -a $d_waybackurls.txt

echo "Starting github-subdomains..."
github-subdomains -d $d -t /home/sayeed/tokens.txt -o $d_github_subdomains.txt

echo "Starting crobat ..."
crobat -s $d >> $d_crobat.txt

echo "Starting ctfr ..."
ctfr.py -d $d -o $d_ctfr.txt

echo "Finished successfully."

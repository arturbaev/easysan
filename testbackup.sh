#!/usr/bin/env bash

#structure:
#FN_*

#Utils:
#apt install -y xlsx2csv #convert xlsx-csv
#apt install -y cifs-utils #connect to cifs
#apt install -y sshpass #util for using password in ssh sessions
#apt install poppler-utils #util for convert pdf to txt # pdftotext filname.pdf - | less

#ssh-key login instraction:
#ssh-keygen -t rsa -b 4096 -f %USERPROFILE%/.ssh/ubuntu_rsa #windows
#scp %USERPROFILE%/.ssh/ubuntu_rsa.pub abaev@192.168.0.101:~/key.pub #windows
#scp C:/Users/artur.baev/Desktop/devops/share/prepscript abaev@192.168.0.122:~/prepscript #optional
#ssh abaev@192.168.0.122 windows
#cat key.pub > ~/.ssh/authorized_keys #linux
#chmod -R go= ~/.ssh #linux
#rm key.pub #linux
#exit #inux
#ssh -i %USERPROFILE%/.ssh/ubuntu_rsa abaev@192.168.0.122 #windows


#Files paths
pwwns_xlsx="$HOME/scripts/SAN/zoning/cifsshare/pwwns.xlsx"
pwwns_csv="$HOME/scripts/SAN/zoning/tmp/pwwns.csv"
brocade_txt="$HOME/scripts/SAN/zoning/cifsshare/brocade.txt"
cisco_txt="$HOME/scripts/SAN/zoning/cifsshare/cisco.txt"


#Main menu
FN_MENU(){
while true; do
#clear
    echo "===== MAIN MENU ====="
    echo "1) Brocade"
    echo "2) Cisco"
    echo "3) Huawei"
    echo "q) Quit"
    read option
        if [ 1 = "$option" ]; then
        clear
        FN_BROCADE
        elif [ 2 = "$option" ]; then
        clear
        FN_CISCO
        elif [ 3 = "$option" ]; then
        clear
        FN_HUAWEI
        elif [ q = "$option" ]; then
        break
        else
        echo "Wrong opt"
        fi
done
}

#Brocade menu
FN_BROCADE(){
while true; do
    echo "===== BROCADE MENU ====="
    echo "1) Reload the pwwns.xlsx"
    echo "2) Show peerzone commands"
    echo "3) Show standart zone commands"
    echo "h) Show foscommandref"
    echo "b) Back to main menu"
    echo "q) Quit"
        read option
        if [ 1 = "$option" ]; then
        FN_RELOAD
        #clear
        elif [ 2 = "$option" ]; then
        FN_SH_BROCADE_PEER
        elif [ 3 = "$option" ]; then
        FN_SH_BROCADE_STANDART
        elif [ h = "$option" ]; then
        less $HOME/scripts/SAN/zoning/cifsshare/foscommandref.txt
        clear
        elif [ b = "$option" ]; then
        break
        elif [ q = "$option" ]; then
        exit
        else
        echo "Wrong opt"
        fi
done
}

#Cisco menu
FN_CISCO(){
while true; do
    echo "===== CISCO MENU ====="
    echo "1) Reload the pwwns.xlsx"
    echo "2) Show zone commands"
    echo "3) Test"
    echo "b) Back to main menu"
    echo "q) Quit"
        read option
        if [ 1 = "$option" ]; then
        FN_RELOAD
        clear
        elif [ 2 = "$option" ]; then
        FN_SH_CISCO
        elif [ 3 = "$option" ]; then
        echo "test"
        clear
        elif [ b = "$option" ]; then
        break
        elif [ q = "$option" ]; then
        exit
        else
        echo "Wrong opt"
        fi
done
}

#Huawei menu
FN_HUAWEI(){
while true; do
    echo "===== HUAWEI MENU ====="
    echo "1) Reload the pwwns.xlsx"
    echo "2) Show config commands"
    echo "h) Show multipathing guide"
    echo "b) Back to main menu"
    echo "q) Quit"
        read option
        if [ 1 = "$option" ]; then
        FN_RELOAD
        elif [ 2 = "$option" ]; then
        FN_SH_HUAWEI
        elif [ 3 = "$option" ]; then
        echo "3"
        elif [ b = "$option" ]; then
        break
        elif [ q = "$option" ]; then
        exit
        else
        echo "Wrong opt"
        fi
done
}


#leftmenu in excel
FN_LEFT_MENU(){
#isname
isname=$(sed -n '2p' $pwwns_csv | cut -d ',' -f2)
#storagename
storagename=$(sed -n '3p' $pwwns_csv | cut -d ',' -f2)
srsb=$(sed -n '4p' $pwwns_csv | cut -d ',' -f2)
#zonename
zonenamefile=$(sed -n '5p' $pwwns_csv | cut -d ',' -f2)
if ! [ -z $zonenamefile ]; then
zonename=$zonenamefile
else
zonename="DS_$storagename"__"$isname"
fi
#cfgname
cfgnamefile=$(sed -n '6p' $pwwns_csv | cut -d ',' -f2)
if ! [ -z $cfgnamefile ]; then
cfgname=$cfgnamefile
else
cfgname="main_config"
fi
#zoneset
zonesetfile=$(sed -n '7p' $pwwns_csv | cut -d ',' -f2)
if ! [ -z $vsanfile ]; then
zoneset=$zonesetfile
else
zoneset="MAIN"
fi
#vsan
vsanfile=$(sed -n '8p' $pwwns_csv | cut -d ',' -f2)
if ! [ -z $vsanfile ]; then
vsan=$vsanfile
else
vsan="3"
fi


# echo "isname is : $isname"
# echo "storage name is $storagename"
# echo "srsb is $srsb"
# echo "zonename is $zonename"
# echo "cfgname is $cfgname"
# echo "zoneset is $zoneset"
# echo "vsan is $vsan"
}


#to clear arrys:
FN_CLEAR_ARR(){

port_s0p1=()
port_s0p2=()
port_s1p1=()
port_s1p2=()

suf_s0p1=()
suf_s0p2=()
suf_s1p1=()
suf_s1p2=()


init_s1p1=()
init_s1p2=()

brocadestandartzonea=()
brocadestandartzonea=()

}

#Reload parametrs from the file and transfer to variables
FN_RELOAD(){
FN_CLEAR_ARR
xlsx2csv -i "$pwwns_xlsx" > "$pwwns_csv"

#leftmenu module
FN_LEFT_MENU
#Type=array
servername=($(cat $pwwns_csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 3 ))
ip=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*0-9,.,\n' | cut -d ',' -f 4 ))
init_s0p1=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 5 | sed 's/../&:/g;s/:$//'))
init_s0p2=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 6 | sed 's/../&:/g;s/:$//'))
targeta=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 9 | sed 's/../&:/g;s/:$//'))
targetb=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 10 | sed 's/../&:/g;s/:$//'))
alitargeta=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9 ))
alitargetb=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10 ))

#create temp vars for array
list=$(cat $pwwns_csv | tail -n +2)
for list in $(cat $pwwns_csv | tail -n +2); do
t_init_s1p1=$(echo $list | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 7 | sed 's/../&:/g;s/:$//')
t_init_s1p2=$(echo $list | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 8 | sed 's/../&:/g;s/:$//')
t_port_s0p1=$(echo $list |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 11)
t_port_s0p2=$(echo $list |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 12)
t_port_s1p1=$(echo $list |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 13)
t_port_s1p2=$(echo $list |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 14)
#Create init s1p* arrays from temp vars
     if ! [ -z "$t_init_s1p1" ]; then
         init_s1p1+=("$t_init_s1p1")
     else
         init_s1p1+=("null")
     fi
     if ! [ -z "$t_init_s1p2" ]; then
         init_s1p2+=("$t_init_s1p2")
     else
         init_s1p2+=("null")
     fi
#Create port suffix arrays:
     if ! [ -z "$t_port_s0p1" ]; then
         port_s0p1+=("$t_port_s0p1")
     else
         port_s0p1+=("null")
     fi
     if ! [ -z "$t_port_s0p2" ]; then
        port_s0p2+=("$t_port_s0p2")
    else
        port_s0p2+=("null")
    fi
    if ! [ -z "$t_port_s1p1" ]; then
        port_s1p1+=("$t_port_s1p1")
    else
        port_s1p1+=("null")
    fi
    if ! [ -z "$t_port_s1p2" ]; then
        port_s1p2+=("$t_port_s1p2")
    else
        port_s1p2+=("null")
    fi
done



#create suffix s*p* arrays.
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null != "${port_s0p1[$a]}" ]; then
    temp_suf="${port_s0p1[$a]}"
    elif [ null != "${init_s1p1[$a]}" ]; then
    temp_suf=s0p1
    else
    temp_suf=p1
    fi
    suf_s0p1+=($temp_suf)
#Checking s0p2
    if [ null != "${port_s0p2[$a]}" ]; then
    temp_suf="${port_s0p2[$a]}"
    elif [ null != "${init_s1p2[$a]}" ]; then
    temp_suf=s0p2
    else
    temp_suf=p2
    fi
    suf_s0p2+=($temp_suf)
#Checking s1p1
    if [ null != "${port_s1p1[$a]}" ]; then
    temp_suf="${port_s1p1[$a]}"
    elif [ null != "${init_s1p1[$a]}" ]; then
    temp_suf=s1p1
    else
    temp_suf=p1
    fi
    suf_s1p1+=($temp_suf)
#Checking s1p2
    if [ null != "${port_s1p2[$a]}" ]; then
    temp_suf="${port_s1p2[$a]}"
    elif [ null != "${init_s1p2[$a]}" ]; then
    temp_suf=s1p2
    else
    temp_suf=p2
    fi
    suf_s1p2+=($temp_suf)
done

#echo "s0p1: ${suf_s0p1[*]}"
#echo "s0p2: ${suf_s0p2[*]}"
#echo "s0p3  ${suf_s1p1[*]}"
#echo "s0p4  ${suf_s1p2[*]}"



#brocade vars for peerzone format
brocade_peerzone_targeta=$(echo "${targeta[*]}" | tr ' ' ';')
brocade_peerzone_targetb=$(echo "${targetb[*]}" | tr ' ' ';')
brocade_peerzone_inita=$(echo "${init_s0p1[*]}" "${init_s1p1[*]}" | sed 's/null //g' | sed 's/ null//g' | tr ' ' ';' )
brocade_peerzone_initb=$(echo "${init_s0p2[*]}" "${init_s1p2[*]}" | sed 's/null //g' | sed 's/ null//g' | tr ' ' ';' )
}



#Show perrzone commands
FN_SH_BROCADE_PEER(){

#ZONE FAB A
#alicreate
echo "============= Brocade peerzone Fabric A =================" | tee $brocade_txt
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${init_s0p1[$a]}\"" | tee -a $brocade_txt
    else
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${init_s0p1[$a]}\"" | tee -a $brocade_txt
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s1p1[$a]}\", \"${init_s1p1[$a]}\"" | tee -a $brocade_txt
    fi
done
echo "" | tee -a $brocade_txt

#zonecreate --peerzone
echo "zonecreate --peerzone $zonename -principal \"$brocade_peerzone_targeta\" -members \"$brocade_peerzone_inita\""| tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#zoneadd --peerzone
echo "zoneadd --peerzone $zonename -members \"$brocade_peerzone_inita\"" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#cfgadd, cfgsave, cfgenable
echo "cfgadd \"$cfgname\", \"$zonename\"" | tee -a $brocade_txt
echo "cfgsave" | tee -a $brocade_txt
echo "cfgenable $cfgname" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#ZONE FAB B
#alicreate
echo "============= Brocade peerzone Fabric B =================" | tee -a $brocade_txt
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p2[$a]}" ]; then
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${init_s0p2[$a]}\"" | tee -a $brocade_txt
    else
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${init_s0p2[$a]}\"" | tee -a $brocade_txt
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s1p2[$a]}\", \"${init_s1p2[$a]}\"" | tee -a $brocade_txt
    fi
done
echo "" | tee -a $brocade_txt

#zonecreate --peerzone
echo "zonecreate --peerzone $zonename -principal \"$brocade_peerzone_targetb\" -members \"$brocade_peerzone_initb\""| tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#zoneadd --peerzone
echo "zoneadd --peerzone $zonename -members \"$brocade_peerzone_initb\"" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#cfgadd, cfgsave, cfgenable
echo "cfgadd \"$cfgname\", \"$zonename\"" | tee -a $brocade_txt
echo "cfgsave" | tee -a $brocade_txt
echo "cfgenable $cfgname" | tee -a $brocade_txt
echo ""
}




FN_SH_BROCADE_STANDART(){
echo "================= Brocade standart zone Fabric A =================" | tee $brocade_txt
echo "" | tee -a $brocade_txt
#Zone create A
a=-1
for i in $(echo ${servername[*]}); do
    b=-1
    ((a=a+1))
    echo ""
    if [ null = "${init_s1p1[$a]}" ]; then
        for i in $(echo ${targeta[*]}); do
             ((b=b+1))
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${targeta[$b]}; ${init_s0p1[$a]}\"" | tee -a $brocade_txt
            brocadestandartzonea+=($(echo $zonename"__"${servername[$a]}"_"${suf_s0p1[$a]}))
        done
    else
        for i in $(echo ${targeta[*]}); do
             ((b=b+1))
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${targeta[$b]}; ${init_s0p1[$a]}\"" | tee -a $brocade_txt
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s1p1[$a]}\", \"${targeta[$b]}; ${init_s1p1[$a]}\"" | tee -a $brocade_txt
             brocadestandartzonea+=($(echo $zonename"__"${servername[$a]}"_"${suf_s0p1[$a]}))
             brocadestandartzonea+=($(echo $zonename"__"${servername[$a]}"_"${suf_s1p1[$a]}))
        done
    fi
done

#format brocadestandartzonea output
brocade_standart_zone_a=$(echo ${brocadestandartzonea[*]} | tr ' ' ';' | sed 's/;/; / g' )

echo "" | tee -a $brocade_txt
#cfgadd, cfgsave, cfgenable
echo "cfgadd \"$cfgname\", \"$brocade_standart_zone_a\"" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "cfgsave" | tee -a $brocade_txt
echo "cfgenable $cfgname" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt

#Zone create B
echo "================= Brocade standart zone Fabric B =================" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
a=-1
for i in $(echo ${servername[*]}); do
    b=-1
    ((a=a+1))
    echo ""
    if [ null = "${init_s1p2[$a]}" ]; then
        for i in $(echo ${targetb[*]}); do
             ((b=b+1))
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${targetb[$b]}; ${init_s0p2[$a]}\"" | tee -a $brocade_txt
            brocadestandartzoneb+=($(echo $zonename"__"${servername[$a]}"_"${suf_s0p2[$a]}))
        done
    else
        for i in $(echo ${targeta[*]}); do
             ((b=b+1))
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${targetb[$b]}; ${init_s0p2[$a]}\"" | tee -a $brocade_txt
             echo "zonecrate \"$zonename"__"${servername[$a]}"_"${suf_s1p2[$a]}\", \"${targetb[$b]}; ${init_s1p2[$a]}\"" | tee -a $brocade_txt
             brocadestandartzoneb+=($(echo $zonename"__"${servername[$a]}"_"${suf_s0p2[$a]}))
             brocadestandartzoneb+=($(echo $zonename"__"${servername[$a]}"_"${suf_s1p2[$a]}))
        done
    fi
done

#format brocadestandartzonea output
brocade_standart_zone_b=$(echo ${brocadestandartzoneb[*]} | tr ' ' ';' | sed 's/;/; / g' )

echo "" | tee -a $brocade_txt
#cfgadd, cfgsave, cfgenable
echo "cfgadd \"$cfgname\", \"$brocade_standart_zone_b\"" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "cfgsave" | tee -a $brocade_txt
echo "cfgenable $cfgname" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
}


#Show cisco zone commands
FN_SH_CISCO(){
#ZONE FAB A
echo "========= Cisco Fabric A =========" | tee $cisco_txt
echo "conf t" | tee -a $cisco_txt
echo "device-alias database" | tee -a $cisco_txt
#create device-alias A, init
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} pwwn ${init_s0p1[$a]}" | tee -a $cisco_txt
    else
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} pwwn ${init_s0p1[$a]}" | tee -a $cisco_txt
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s1p1[$a]} pwwn ${init_s1p1[$a]}" | tee -a $cisco_txt
    fi
done
echo "device-alias commit" | tee -a $cisco_txt
echo "zone name $zonename vsan $vsan" | tee -a $cisco_txt
#member device-alias A, target
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [[ ${alitargeta[$a]} == *_* ]]; then
    echo "member device-alias ${alitargeta[$a]} target" | tee -a $cisco_txt
    fi
done
#member device-alias A, init
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} init" | tee -a $cisco_txt
    else
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} init" | tee -a $cisco_txt
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s1p1[$a]} init" | tee -a $cisco_txt
    fi
done
#end of configuration A
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "zoneset name $zoneset vsan $vsan" | tee -a $cisco_txt
echo "member $zonename" | tee -a $cisco_txt
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "zoneset activate name $zoneset vsan $vsan" | tee -a $cisco_txt
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "end" | tee -a $cisco_txt
echo "copy run start fabric" | tee -a $cisco_txt
echo "" | tee -a $cisco_txt

#ZONE FAB B
echo "========= Cisco Fabric B =========" | tee -a $cisco_txt
echo "conf t" | tee -a $cisco_txt
echo "device-alias database" | tee -a $cisco_txt
#create device-alias B, initb
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p2[$a]}" ]; then
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p2[$a]} pwwn ${init_s0p2[$a]}" | tee -a $cisco_txt
    else
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p2[$a]} pwwn ${init_s0p2[$a]}" | tee -a $cisco_txt
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s1p2[$a]} pwwn ${init_s1p2[$a]}" | tee -a $cisco_txt
    fi
done
echo "device-alias commit" | tee -a $cisco_txt
echo "zone name $zonename vsan $vsan" | tee -a $cisco_txt

#member device-alias B, target
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [[ ${alitargetb[$a]} == *_* ]]; then
    echo "member device-alias ${alitargetb[$a]} target" | tee -a $cisco_txt
    fi
done

#member device-alias B, init
a="-1"
for i in $(echo ${servername[*]}); do
((a=a+1))
    if [ null = "${init_s1p2[$a]}" ]; then
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p2[$a]} init" | tee -a $cisco_txt
    else
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p2[$a]} init" | tee -a $cisco_txt
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s1p2[$a]} init" | tee -a $cisco_txt
    fi
done

#end of configuration B
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "zoneset name $zoneset vsan $vsan" | tee -a $cisco_txt
echo "member $zonename" | tee -a $cisco_txt
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "zoneset activate name $zoneset vsan $vsan" | tee -a $cisco_txt
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "end" | tee -a $cisco_txt
echo "copy run start fabric" | tee -a $cisco_txt
echo "" | tee -a $cisco_txt
}





FN_SH_HUAWEI(){
operating_system=VMware_ESX
host_id=100
echo "test"
a=-1
for i in $(echo ${servername[*]}); do
((a=a+1))
((host_id=host_id+1))
echo "create host name=${servername[$a]} operating_system=$operating_system host_id=$host_id ip=${ip[$a]}"

done
#create host name=sks06ccp121002 operating_system=VMware_ESX host_id=32 ip=10.29.241.153
#add host initiator host_id=32 initiator_type=FC wwn=2100000e1e22b460 alias=SR_sks06ccp121002_p1
#change initiator initiator_type=FC wwn=2100000e1e22b460 multipath_type=third-party failover_mode=special_mode special_mode_type=mode1 path_type=optimized
}



FN_RELOAD
FN_MENU

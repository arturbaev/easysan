#!/usr/bin/env bash
pwwns_xlsx="$HOME/scripts/SAN/zoning/cifsshare/pwwns.xlsx"
pwwns_csv="$HOME/scripts/SAN/zoning/tmp/pwwns.csv"
brocade_txt="$HOME/scripts/SAN/zoning/cifsshare/brocade.txt"
cisco_txt="$HOME/scripts/SAN/zoning/cifsshare/cisco.txt"

fn_menu(){
while true; do
    echo "===MAIN MENU==="
    echo "1) Brocade"
    echo "2) Cisco"
    echo "3) Huawei"
    echo "0) Quit"
    read option
        if [ 1 = "$option" ]; then
        fn_brocade
        elif [ 2 = "$option" ]; then
        fn_cisco
        elif [ 2 = "$option" ]; then
        echo "3"
        elif [ 0 = "$option" ]; then
        break
        else
        echo "Wrong opt"
        fi
done
}

fn_brocade(){
while [ 9 != $option ]; do
    echo "===BROCADE MENU==="
    echo "1) Reload the pwwns.xlsx"
    echo "2) Show zone commands"
    echo "3) Connect to the switch"
    echo "9) Back to main menu"
    echo "0) Quit"
        read option
        if [ 1 = "$option" ]; then
        fn_reload
        elif [ 2 = "$option" ]; then
        fn_sh_brocade
        elif [ 3 = "$option" ]; then
        echo "2"
        elif [ 0 = "$option" ]; then
        exit
        else
        echo "Wrong opt"
        fi
done
}

fn_cisco(){
while [ 0 != $option ]; do
    echo "===CISCO MENU==="
    echo "1) Reload the pwwns.xlsx"
    echo "2) Show zone commands"
    echo "3) Connect to the switch"
    echo "9) Back to main menu"
    echo "0) Quit"
        read option
        if [ 1 = "$option" ]; then
        fn_reload
        elif [ 2 = "$option" ]; then
        fn_sh_cisco
        elif [ 3 = "$option" ]; then
        fn_test_cisco
        elif [ 0 = "$option" ]; then
        exit
        else
        echo "Wrong opt"
        fi
done
}



fn_test_cisco(){

echo "Yes"
#
#IS_name
#storage name
#SR or SB
#cfgname
#vsan
#zoneset

}

fn_reload(){
xlsx2csv -i "$pwwns_xlsx" > "$pwwns_csv"
#Arrays vars:
servername=($(cat $pwwns_csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 1 ))
ip=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 2 | sed 's/../&:/g;s/:$//')
init_s0p1=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 3 | sed 's/../&:/g;s/:$//'))
init_s0p2=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 4 | sed 's/../&:/g;s/:$//'))
targeta=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 7 | sed 's/../&:/g;s/:$//'))
targetb=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 8 | sed 's/../&:/g;s/:$//'))
alitargeta=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 7 ))
alitargetb=($(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 8 ))

#create init arrays
a="-1"
list=($(cat $pwwns_csv | tail -n +2))
for i in ${list[*]}; do
((a=a+1))
t_init_s1p1=$(echo "${list[a]}" | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 5 | sed 's/../&:/g;s/:$//')
t_init_s1p2=$(echo "${list[a]}" | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 6 | sed 's/../&:/g;s/:$//')
t_port_s0p1=$(echo "${list[a]}" |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 15)
t_port_s0p2=$(echo "${list[a]}" |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 16)
t_port_s1p1=$(echo "${list[a]}" |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 17)
t_port_s1p2=$(echo "${list[a]}" |  tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 18)
#Create init pwwns arrays
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

a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
#Checking s0p1
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

#Constant vars:
isname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9)
arrayname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10)
srsb=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 11)


###Optional vars:
#cfgname
cfgnamefile=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 12)
if ! [ -z $cfgnamefile ]; then
cfgname=$cfgnamefile
else
cfgname="main_config"
fi
#zonename
zonenamefile=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 13)
if ! [ -z $zonenamefile ]; then
zonename=$zonenamefile
else
zonename="DS_$arrayname"__"$isname"
fi
#vsan
vsanfile=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 14)
if ! [ -z $vsanfile ]; then
vsan=$vsanfile
else
vsan="3"
fi
}

fn_sh_brocade(){
echo "========= Brocade create aliases A =========" | tee $brocade_txt
a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${init_s0p1[$a]}\"" | tee -a $brocade_txt
    else
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p1[$a]}\", \"${init_s0p1[$a]}\"" | tee -a $brocade_txt
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s1p1[$a]}\", \"${init_s1p1[$a]}\"" | tee -a $brocade_txt
    fi
done
echo "" | tee -a $brocade_txt
echo "========= Brocade create aliases B =========" | tee -a $brocade_txt
a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
    if [ null = "${init_s1p2[$a]}" ]; then
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${init_s0p2[$a]}\"" | tee -a $brocade_txt
    else
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s0p2[$a]}\", \"${init_s0p2[$a]}\"" | tee -a $brocade_txt
    echo "alicreate \"$srsb"_"${servername[$a]}"_"${suf_s1p2[$a]}\", \"${init_s1p2[$a]}\"" | tee -a $brocade_txt
    fi
done
echo "" | tee -a $brocade_txt
echo "=============== Create peerzone in Fabric A ===============" | tee -a $brocade_txt
brocade_peerzone_targeta=$(echo "${targeta[*]}" | tr ' ' ';')
brocade_peerzone_targetb=$(echo "${targetb[*]}" | tr ' ' ';')
brocade_peerzone_inita=$(echo "${init_s0p1[*]}" "${init_s1p1[*]}" | tr ' ' ';')
brocade_peerzone_initb=$(echo "${init_s0p2[*]}" "${init_s1p2[*]}" | tr ' ' ';')
echo "zonecreate --peerzone $zonename -principal \"$brocade_peerzone_targeta\" -members \"$brocade_peerzone_inita\""| tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "=============== Add initiators to current zone A ===============" | tee -a $brocade_txt
echo "zoneadd --peerzone $zonename -members \"$brocade_peerzone_inita\"" | tee -a $brocade_txt
echo "" | tee -a $brocade_txt
echo "=============== Add created zone to zoneconfig A================" | tee -a $brocade_txt
echo "cfgadd \"$cfgname\", \"$zonename\"" | tee -a $brocade_txt
echo "cfgsave" | tee -a $brocade_txt
echo "cfgenable $cfgname" | tee -a $brocade_txt
echo ""
}

fn_sh_cisco(){
echo "========= Cisco Fabric A =========" | tee $cisco_txt
echo "conf t" | tee -a $cisco_txt
echo "device-alias database" | tee -a $cisco_txt
a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} pwwn ${init_s0p1[$a]}" | tee -a $cisco_txt
    else
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} pwwn ${init_s0p1[$a]}" | tee -a $cisco_txt
    echo "device-alias name $srsb"_"${servername[$a]}"_"${suf_s1p1[$a]} pwwn ${init_s1p1[$a]}" | tee -a $cisco_txt
    fi
done
echo "device-alias commit"
echo "zone name $zonename vsan $vsan"
a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
    if [[ ${alitargeta[$a]} == *_* ]]; then
    echo "member device-alias ${alitargeta[$a]} target" | tee -a $cisco_txt
    fi
done
a="-1"
for i in $(cat "$pwwns_csv" | tail -n +2); do
((a=a+1))
    if [ null = "${init_s1p1[$a]}" ]; then
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} init" | tee -a $cisco_txt
    else
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s0p1[$a]} init" | tee -a $cisco_txt
    echo "member device-alias $srsb"_"${servername[$a]}"_"${suf_s1p1[$a]} init" | tee -a $cisco_txt
    fi
done
echo "zone commit vsan $vsan" | tee -a $cisco_txt
echo "zoneset name $zoneset vsan $vsan" | tee -a $cisco_txt
echo "member $cisco_zonename" | tee -a $cisco_txt
echo "zone commit vsan $cisco_vsan" | tee -a $cisco_txt
echo "zoneset activate name $cisco_zoneset vsan $cisco_vsan" | tee -a $cisco_txt
echo "zone commit vsan $cisco_vsan" | tee -a $cisco_txt
echo "end" | tee -a $cisco_txt
echo "copy run start fabric" | tee -a $cisco_txt
}

#echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname2a pwwn $cisco_line_initp2a" >> ~/scripts/SAN/zoning/tmp/cisco_alias_a
#echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname1a init" >> ~/scripts/SAN/zoning/tmp/cisco_member_a


fn_reload
fn_menu

#!/bin/bash

#Main menu function.
function main_menu_fn() {
while true;
COLUMNS=1
	echo "========================================="
	echo "========= Main menu script =============="
	echo "========================================="
	do
		select main_menu_opt in "Brocade" "Cisco" "Huawei" "Quit"
		do 
			case $main_menu_opt in
			"Huawei")
				break
				;;
			"Cisco")
				cisco_fn
				break
				;;
			"Brocade")
				brocade_fn
				break
				;;
			"Quit")
				break 2 
				;;
			*) 
				echo "Wrong option"
				break
				;;
			esac
		done
	done
}
#======================================================================================================================================================
#=========================================================Brocade======================================================================================
#======================================================================================================================================================
#Brocade menu function. It loads pwwns.xlsx file and gets variables from the file by invoking the function "brocade_load_pwwns_line_fn". Also it sets "zonename" and "cfgname" in default values.
function brocade_fn() {
brocade_load_pwwns_line_fn
zonename=$(echo "DS_"$arrayname"__"$isname)
cfgname="main_config" #here we can change default cfgname
while true;
COLUMNS=1
	do
	echo "========================================="
	echo "========= Brocade script menu ==========="
	echo "========================================="
		select brocade_menu_opt in "Reload pwwns file" "Show zone commands" "Change zonename" "Change cfgname" "Restore [zone|cfg]name to default" "Connect to the switch and perform configuration (is not ready yet)" "Back"
		do 
			case $brocade_menu_opt in
				"Reload pwwns file") #It realods the pwwns.csv file. We can edit pwwns.xlsx from a client machine and reload new values from here without stopping the script.
					brocade_load_pwwns_line_fn
					break
					;;
				"Show zone commands") #It shows brocade perrzone commands, creates the file brocade.txt in the shared directory, so we can open the broacade.txt file with notepad++ (for example) within a share directory on Windows machine.
					brocade_zone_show_fn
					break
					;;
				"Change zonename") #Here we can manually set zonename. It will be set until we chose "Restore [zone|cfg]name to default" option.
					read -p "Enter zonename: " zonename
					echo "Current zonename is: $zonename"
					break
					;;
				"Change cfgname") #Here we can manually set cfgname. It will be set until we chose "Restore [zone|cfg]name to default" option.
					read -p "Enter cfgname: " cfgname
					echo "Current cfgname is: $zonename"
					break
					;;
				"Restore [zone|cfg]name to default") #Restores the default values for zonename and cfgname.
					select restore_menu_opt in "Restore both" "Restore zonename" "Restore cfgname" "Back"
					do 
						case $restore_menu_opt in
							"Restore both")
							zonename=$(echo "DS_"$arrayname"__"$isname)
							cfgname="main_config"
							echo "Current zonename is: $zonename"
							echo "Current cfgnzme is: $cfgname"
							break 2 
							;;
							"Restore zonename")
							zonename=$(echo "DS_"$arrayname"__"$isname)
							echo "Current zonename is: $zonename"
							break 2 
							;;
							"Restore cfgname")
							cfgname="main_config"
							echo "Current cfgnzme is: $cfgname"
							break 2 
							;;
							"Back")
							break 2 
							;;
							*) 
							echo "Wrong option"
							break 2
							;;
						esac
					done
					break
					;;
				"Connect to the switch and perform configuration (is not ready yet)")
					break 2 
					;;
				"Back")
					break 2 
					;;
				*) 
					echo "Wrong option"
					break
				;;
			esac
		done
	done
}


function brocade_load_pwwns_line_fn() {
#The function converts pwwns.xlsx to pwwns.csv and parses the file in a loop. For each line variables are created. It also sets constant variables from the csv file. PWWNs adresses are bering checked so it doesn't matter the format we use in pwwns.xlsx. 
oldIFS=$IFS #backup default IFS
xlsx2csv -i ~/scripts/SAN/zoning/cifsshare/pwwns.xlsx > ~/scripts/SAN/zoning/tmp/pwwns.csv #light and simple xlsx>csv converter.
#There are variables the script uses to create peerzone commands.
servertype=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:lower:] [:upper:] | cut -d ',' -f 11 )
servername=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 1 )
serverip=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 2 | sed 's/../&:/g;s/:$//')
initp1a=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 3 | sed 's/../&:/g;s/:$//')
initp1b=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 4 | sed 's/../&:/g;s/:$//')
initp2a=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 5 | sed 's/../&:/g;s/:$//')
initp2b=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 6 | sed 's/../&:/g;s/:$//')
targetp1a=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 7 | sed 's/../&:/g;s/:$//')
targetp1b=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 8 | sed 's/../&:/g;s/:$//')
isname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9)
arrayname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10)
inita=$(echo $initp1a $initp2a | tr ' ' ';')
initb=$(echo $initp1b $initp2b | tr ' ' ';')
targeta=$(echo $targetp1a | tr ' ' ';')
targetb=$(echo $targetp1b | tr ' ' ';')
#For aliases the sctipt writes the loop output in temp files. At each lounch the script wipes those files.
> ~/scripts/SAN/zoning/tmp/brocade_alias_a
> ~/scripts/SAN/zoning/tmp/brocade_alias_b
IFS=$'\n' #set IFS in new line format. It's vital for this loop.
for lines in $(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2)
	do 
		brocade_line_servername=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 1 )
		#brocade_line_serverip=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 2 | sed 's/../&:/g;s/:$//')
		brocade_line_initp1a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 3 | sed 's/../&:/g;s/:$//')
		brocade_line_initp1b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 4 | sed 's/../&:/g;s/:$//')
		brocade_line_initp2a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 5 | sed 's/../&:/g;s/:$//')
		brocade_line_initp2b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 6 | sed 's/../&:/g;s/:$//')
		brocade_line_targetp1a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 7 | sed 's/../&:/g;s/:$//')
		brocade_line_targetp1b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 8 | sed 's/../&:/g;s/:$//')
		#brocade_line_isname=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9)
		#brocade_line_arrayname=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10)	
#Check part. Check part. The script compares lendth of the pwwns variables. If it's not corrent the message appears.
		if [ ${#brocade_line_initp1a} -ne 23 ] && [ ${#brocade_line_initp1a} -ne 0 ]; then
		echo "Error: Check init-1A in the pwwns.xlsx"
		fi
		if [ ${#brocade_line_initp1b} -ne 23 ] && [ ${#brocade_line_initp1b} -ne 0 ]; then
		echo "Error: Check init-1B in the pwwns.xlsx"
		fi
		if [ ${#brocade_line_initp2a} -ne 23 ] && [ ${#brocade_line_initp2a} -ne 0 ]; then
		echo "Error: Check init-2A in the pwwns.xlsx"
		fi
		if [ ${#brocade_line_initp2b} -ne 23 ] && [ ${#brocade_line_initp2b} -ne 0 ]; then
		echo "Error: Check init-2B in the pwwns.xlsx"
		fi
		if [ ${#brocade_line_targetp1a} -ne 23 ] && [ ${#brocade_line_targetp1a} -ne 0 ]; then
		echo "Error: Check target-A in the pwwns.xlsx"
		fi
		if [ ${#brocade_line_targetp1b} -ne 23 ] && [ ${#brocade_line_targetp1b} -ne 0 ]; then
		echo "Error: Check target-B in the pwwns.xlsx"
		fi
#Aliases part. It checks the variables in fields init-2-A and init-2-B are exist. If true it assign suffix "s*p*" else it assigns suffix "p*". Fabric A: s*p1, Fabric B: s*p2.
		if ! [ -z $brocade_line_initp2a ]; then
			portname1a=s0p1
			portname2a=s1p1
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname1a\", \"$brocade_line_initp1a\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_a
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname2a\", \"$brocade_line_initp2a\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_a
			else
			portname1a=p1
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname1a\", \"$brocade_line_initp1a\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_a
		fi
		if ! [ -z $brocade_line_initp2b ]; then
			portname1b=s0p2
			portname2b=s1p2
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname1b\", \"$brocade_line_initp1b\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_b
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname2b\", \"$brocade_line_initp2b\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_b
			else
			portname1b=p2
			echo "alicreate \"$servertype"_"$brocade_line_servername"_"$portname1b\", \"$brocade_line_initp1b\"" >> ~/scripts/SAN/zoning/tmp/brocade_alias_b
		fi
	done
IFS=$oldIFS #restore default IFS.
}
brocade_zone_show_fn() {
	echo "=============== Create zone in Fabric A ===============" | tee ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo -e "zonecreate --peerzone" $zonename "-principal" \"$targeta\" "-members" \"$inita\""\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Create zone in Fabric B ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo -e "zonecreate --peerzone" $zonename "-principal" \"$targetb\" "-members" \"$initb\""\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Add initiators to current zone A ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo -e "zoneadd --peerzone" $zonename "-members" \"$inita\""\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Add initiators to current zone B ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo -e "zoneadd --peerzone" $zonename "-members" \"$initb\""\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Create aliases in Fabric A ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	cat ~/scripts/SAN/zoning/tmp/brocade_alias_a | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	printf "\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Create aliases in Fabric B ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	cat ~/scripts/SAN/zoning/tmp/brocade_alias_b | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	printf "\n" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "=============== Add created zone to zoneconfig. Attention! Default cfgname is "$cfgname" you can change it ether in option 4 or by edit 87 line in the script ===============" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "cfgadd \"$cfgname\", \"$zonename\"" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "cfgsave" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
	echo "cfgenable \"$cfgname\"" | tee -a ~/scripts/SAN/zoning/cifsshare/brocade.txt
}
#======================================================================================================================================================
#=========================================================CISCO========================================================================================
#======================================================================================================================================================
function cisco_fn() {
cisco_load_pwwns_line_fn
cisco_vsan=3
cisco_zonename=DS_$arrayname"__"$isname
cisco_zoneset=MAIN
while true;
COLUMNS=1
	do
	echo "========================================="
	echo "========= Cisco script menu ============="
	echo "========================================="
		select cisco_menu_opt in "Reload pwwns file" "Show zone commands" "Change VSAN" "Change zonename" "Change zoneset" "Restore zone|vsan to default" "Back"
		do 
			case $cisco_menu_opt in
				"Reload pwwns file") #It realods the pwwns.csv file. We can edit pwwns.xlsx from a client machine and reload new values from here.
				cisco_load_pwwns_line_fn
				break
				;;
				"Show zone commands")
				cisco_show_zone_fn
				break
				;;
				"Change VSAN")
				read -p "Enter VSAN number: " cisco_vsan
				echo "Current VSAN is $cisco_vsan"
				break
				;;
				"Change zonename")
				read -p "Enter zonename : " cisco_zonename
				echo "Current zonename is $cisco_zonename"
				break
				;;
				"Change zoneset")
				read -p "Enter zoneset name: " cisco_zoneset
				echo "Current zoneset : $cisco_zoneset"
				break
				;;
				"Restore zone|vsan to default") #Restores the default values for zonename and cfgname.
					select restore_menu_opt in "Restore all" "Restore zoneset" "Restore zonename" "Restore vsan" "Back"
					do 
						case $restore_menu_opt in
							"Restore all")
							cisco_vsan=3
							cisco_zonename=DS_$arrayname"__"$isname
							cisco_zoneset=MAIN
							echo "Current zonename is: $cisco_zonename"
							echo "Current zoneset is: $cisco_zoneset"
							echo "Current vsan is: $cisco_vsan"
							break 2 
							;;
							"Restore zonename")
							cisco_zonename=DS_$arrayname"__"$isname
							echo "Current zonename is: $cisco_zonename"
							break 2 
							;;
							"Restore zoneset")
							cisco_zoneset=MAIN
							echo "Current zoneset is: $cisco_zoneset"
							break 2 
							;;
							"Restore vsab")
							cisco_vsan=3
							echo "Current vsan is: $cisco_vsan"
							break 2 
							;;
							"Back")
							break 2 
							;;
							*) 
							echo "Wrong option"
							break 2
							;;
						esac
					done
					break
					;;
				"Back")
				break 2 
				;;
				*) 
				echo "Wrong option"
				break
				;;
			esac
		done
	done
}

function cisco_load_pwwns_line_fn() {
#The function convert pwwns.xlsx into pwwns.csv and parses the file pwwns.csv by lines in a loop. For each line variables are created. Second part of the function performs checking PWWNs adresses. Last section creates files alias_* in ~/scripts/SAN/zoning/tmp directory which contain alias commands.
oldIFS=$IFS #backup default IFS
IFS=$'\n' #set IFS in new line format. It's vital for that loop.
#libreoffice --headless --convert-to csv ~/scripts/SAN/zoning/cifsshare/pwwns.xlsx --outdir ~/scripts/SAN/zoning/tmp > /dev/null #Convert xlsx to cvs. The comma is seperator. File is located in my cifs share on Windows PC. I have alreade mounted cifs share to ~/WindowsShare using mount.cifs.
xlsx2csv -i ~/scripts/SAN/zoning/cifsshare/pwwns.xlsx > ~/scripts/SAN/zoning/tmp/pwwns.csv
> ~/scripts/SAN/zoning/tmp/cisco_alias_a
> ~/scripts/SAN/zoning/tmp/cisco_alias_b
> ~/scripts/SAN/zoning/tmp/cisco_member_a
> ~/scripts/SAN/zoning/tmp/cisco_member_b

servertype=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:lower:] [:upper:] | cut -d ',' -f 11 )
isname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9)
arrayname=$(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2 | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10)
for lines in $(cat ~/scripts/SAN/zoning/tmp/pwwns.csv | tail -n +2)
	do 
		cisco_line_servername=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 1 )
		#cisco_line_serverip=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 2 | sed 's/../&:/g;s/:$//')
		cisco_line_initp1a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 3 | sed 's/../&:/g;s/:$//')
		cisco_line_initp1b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 4 | sed 's/../&:/g;s/:$//')
		cisco_line_initp2a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 5 | sed 's/../&:/g;s/:$//')
		cisco_line_initp2b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 6 | sed 's/../&:/g;s/:$//')
		cisco_line_targetp1a=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 7 | sed 's/../&:/g;s/:$//')
		cisco_line_targetp1b=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | tr [:upper:] [:lower:] | cut -d ',' -f 8 | sed 's/../&:/g;s/:$//')
		#cisco_line_isname=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 9)
		#cisco_line_arrayname=$(echo $lines | tr -dc '*,A-Z,a-z,0-9,_,\n' | cut -d ',' -f 10)	
#Checking part
		if [ ${#cisco_line_initp1a} -ne 23 ] && [ ${#cisco_line_initp1a} -ne 0 ]; then
		echo "Error: Check init-1A in the pwwns.xlsx"
		fi
		if [ ${#cisco_line_initp1b} -ne 23 ] && [ ${#cisco_line_initp1b} -ne 0 ]; then
		echo "Error: Check init-1B in the pwwns.xlsx"
		fi
		if [ ${#cisco_line_initp2a} -ne 23 ] && [ ${#cisco_line_initp2a} -ne 0 ]; then
		echo "Error: Check init-2A in the pwwns.xlsx"
		fi
		if [ ${#cisco_line_initp2b} -ne 23 ] && [ ${#cisco_line_initp2b} -ne 0 ]; then
		echo "Error: Check init-2B in the pwwns.xlsx"
		fi
		if [ ${#cisco_line_targetp1a} -ne 23 ] && [ ${#cisco_line_targetp1a} -ne 0 ]; then
		echo "Error: Check target-A in the pwwns.xlsx"
		fi
		if [ ${#cisco_line_targetp1b} -ne 23 ] && [ ${#cisco_line_targetp1b} -ne 0 ]; then
		echo "Error: Check target-B in the pwwns.xlsx"
		fi
#Alias part. It checks the variables for fileds init-2-A and init-2-B are exist. If true it assign suffix "s*p*" else it assigns suffix "p*". Fabric A: s*p1, Fabric B: s*p2.
		if ! [ -z $cisco_line_initp2a ]; then
			portname1a=s0p1
			portname2a=s1p1
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname1a pwwn $cisco_line_initp1a" >> ~/scripts/SAN/zoning/tmp/cisco_alias_a
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname2a pwwn $cisco_line_initp2a" >> ~/scripts/SAN/zoning/tmp/cisco_alias_a
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname1a init" >> ~/scripts/SAN/zoning/tmp/cisco_member_a
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname2a init" >> ~/scripts/SAN/zoning/tmp/cisco_member_a
			else
			portname1a=p1
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname1a pwwn $cisco_line_initp1a" >> ~/scripts/SAN/zoning/tmp/cisco_alias_a
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname1a init" >> ~/scripts/SAN/zoning/tmp/cisco_member_a
		fi
		if ! [ -z $cisco_line_initp2b ]; then
			portname1b=s0p2
			portname2b=s1p2
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname1b pwwn $cisco_line_initp1b" >> ~/scripts/SAN/zoning/tmp/cisco_alias_b
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname2b pwwn $cisco_line_initp2b" >> ~/scripts/SAN/zoning/tmp/cisco_alias_b
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname1b init" >> ~/scripts/SAN/zoning/tmp/cisco_member_b
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname2b init" >> ~/scripts/SAN/zoning/tmp/cisco_member_b
			else
			portname1b=p2
			echo "member device-alias $servertype"_"$cisco_line_servername"_"$portname1a pwwn $cisco_line_initp1b" >> ~/scripts/SAN/zoning/tmp/cisco_alias_b
			echo "device-alias name $servertype"_"$cisco_line_servername"_"$portname1b pwwn $cisco_line_initp1b" >> ~/scripts/SAN/zoning/tmp/cisco_alias_b
		fi
	done
IFS=$oldIFS #restore default IFS. We want to read bash array
}

function cisco_show_zone_fn() {
	echo "========== Fabric A ===========" | tee ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "conf t" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "device-alias database" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	cat ~/scripts/SAN/zoning/tmp/cisco_alias_a | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "device-alias commit" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone name $cisco_zonename vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	cat ~/scripts/SAN/zoning/tmp/cisco_member_a | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zoneset name $cisco_zoneset vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "member $cisco_zonename" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zoneset activate name $cisco_zoneset vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan"| tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "end" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo -e "copy run start fabric\n" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "========== Fabric B ===========" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "conf t" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "device-alias database" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	cat ~/scripts/SAN/zoning/tmp/cisco_alias_b | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "device-alias commit" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone name $cisco_zonename vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	cat ~/scripts/SAN/zoning/tmp/cisco_member_b | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zoneset name $cisco_zoneset vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "member $cisco_zonename" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zoneset activate name $cisco_zoneset vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "zone commit vsan $cisco_vsan" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "end" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
	echo "copy run start fabric" | tee -a ~/scripts/SAN/zoning/cifsshare/cisco.txt
}


main_menu_fn

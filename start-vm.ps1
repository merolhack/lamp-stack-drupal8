# @file: start-vm.ps1
# powershell -noexit -noprofile -executionpolicy bypass -file "C:\Users\Lenin Meza\Documents\SysAdmin\PowerShell\start-vm.ps1"

$vmname = "Centos 7 - Apache 2.4 - PHP 7 - MariaDB 10 - Drupal 8 Test"

echo "Script para iniciar la maquina virtual en VirtualBox"

cd "C:\Program Files\Oracle\VirtualBox\"
./VBoxManage startvm $vmname

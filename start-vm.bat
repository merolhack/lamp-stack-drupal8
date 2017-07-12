REM @file: start-vm.bat
@echo off

set vmname="Centos 7 - Apache 2.4 - PHP 7 - MariaDB 10 - Drupal 8 Test"

echo "Script para iniciar la maquina virtual en VirtualBox"
cd "C:\Program Files\Oracle\VirtualBox"
VBoxManage.exe startvm %vmname%

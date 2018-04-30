echo off
title Installationscript for installing docker-ci-tool-stack to minikube by AdARTIS -all rights reserved-
echo Welcome to the script for installing a docker-ci-tool-stack to Kubernetes's minikube
echo Please make sure that this script is run in cmd.exe with administrator rights, that at least Microsoft Windows 7 is run and that no additional software is installed on your computer.
echo Releasing port 1024-65535 on local firewall
	netsh advfirewall firewall add rule name="Open_Port_1-65535_TCP_IN" dir=in action=allow protocol=TCP localport=1-65535
	netsh advfirewall firewall add rule name="Open_Port_1-65535_TCP_OUT" dir=out action=allow protocol=TCP localport=1-65535
	netsh advfirewall firewall add rule name="Open_Port_1-65535_UDP_IN" dir=in action=allow protocol=UDP localport=1-65535
	netsh advfirewall firewall add rule name="Open_Port_1-65535_UDP_OUT" dir=out action=allow protocol=UDP localport=1-65535	
goto continue94
    REM echo Checking for administrator rights ...
    net session >nul 2>&1
    if %errorLevel% == 0 (
	echo Success: You have administrator rights. 
    goto continue01
    ) else (
        echo Failure: Please run this script with administrator rights.
		goto exit
    )
    pause >nul
:continue01
set /p input01="Is this script run the first time on your computer? (yes/no))"
   if %input01% == yes (
   	IF EXIST C:\Users\%username%\.kube RMDIR "C:\Users\%username%\.kube" /S /Q
	IF EXIST C:\Users\%username%\.minikube RMDIR "C:\Users\%username%\.minikube" /S /Q
    goto continue99
    ) else (
	set /p input02="Should the configuration files of Minikube be deleted for a new Minikube installation? (yes/no))"
    if %input01% == yes (
	IF EXIST C:\Users\%username%\.kube RMDIR "C:\Users\%username%\.kube" /S /Q
	IF EXIST C:\Users\%username%\.minikube RMDIR "C:\Users\%username%\.minikube" /S /Q
    ) else (
	goto continue96
	)
	)
:continue99
echo Installing Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
echo Installing wget
choco install wget 
echo Installing git
choco install git
echo Installing Virtual Box
choco install virtualbox 
echo Installing kubectl	
choco install kubernetes-cli
echo Installing minikube
choco install minikube
echo Installing docker-17.10.0-ce
choco install docker 
echo Installing gitlab-runner
choco install gitlab-runner 
echo Starting choco install eclipse 
choco install eclipse
echo Install docker daemon
choco install docker-toolbox 
choco choco upgrade docker-toolbox
echo Install openssh
choco install openssh
echo Install Kubernetes kompose
choco install kubernetes-kompose
IF EXIST C:\Users\%username%\ziptools RMDIR "C:\Users\%username%\ziptools" /S /Q
cd C:\Users\%username%\
mkdir ziptools
cd C:\Users\%username%\ziptools
wget -q http://www.stahlworks.com/dev/unzip.exe
wget -q http://www.stahlworks.com/dev/gzip.exe
wget -q http://www.stahlworks.com/dev/tar.exe
copy gzip.exe gunzip.exe
setx PATH "%PATH%;C:\Users\%username%\ziptools"
echo Creating and starting Docker machine 192.168.99.100. Please enter "exit" after the Docker-Toolbox is popped up.  
"C:\Program Files\Git\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"
echo Downloading docker-ci-tool-stack
IF EXIST C:\Users\%username%\docker-ci-tool-stack RMDIR "C:\Users\%username%\docker-ci-tool-stack" /S /Q
cd C:\Users\%username%
git clone https://github.com/marcelbirkner/docker-ci-tool-stack.git
cd docker-ci-tool-stack
IF EXIST docker-nexus3 RMDIR "docker-nexus3" /S /Q
git clone https://github.com/sonatype/docker-nexus3.git
:continue96
set /p input03="Do you want to create a new docker machine named 'default'? (yes/no))"
   if %input03% == yes (
	echo Deleting Docker machine "default" on 192.168.99.100:2376
	docker-machine kill default
	IF EXIST C:\Users\%username%\.docker\machine\machines\default RMDIR "C:\Users\%username%\.docker\machine\machines\default" /S /Q
	docker-machine create default
	docker-machine env default
    goto continue95
   ) else (
    docker-machine restart default
	docker-machine env default
	if %errorLevel% == 0 (
	echo The Dockerservice has been started successfully. 
    ) else (
        echo Failure: Dockerservice did not start. Creating a default docker-machine.
	    docker-machine kill default
	    IF EXIST C:\Users\%username%\.docker\machine\machines\default RMDIR "C:\Users\%username%\.docker\machine\machines\default" /S /Q
	    docker-machine create default
     	docker-machine env default
		goto continue95
    )
   )
:continue95
echo Loading the ci-cd-tool-stack into the 'default' docker-machine
cd C:\Users\%username%\docker-ci-tool-stack
START /B docker-compose up
:continue94
docker-machine kill default
echo Deleting former minikube clusters
minikube delete
echo Copying the default docker-machine to minikube
IF EXIST C:\Users\%username%\.minikube\machines\minikube RMDIR "C:\Users\%username%\.minikube\machines\minikube" /S /Q
IF NOT EXIST C:\Users\%username%\.minikube\machines\minikube mkdir C:\Users\%username%\.minikube\machines\minikube
xcopy C:\Users\%username%\.docker\machine\machines\default\*.* C:\Users\%username%\.minikube\machines\minikube /E /I /Y
echo Creating the minikube-config-file
REM config modifies minikube config files using subcommands like "minikube config set vm-driver kvm"
REM Configurable fields:
REM * vm-driver
REM * v
REM * cpus
REM * disk-size
REM * host-only-cidr
REM * memory
REM * log_dir
REM * kubernetes-version
REM * iso-url
REM * WantUpdateNotification
REM * ReminderWaitPeriodInHours
REM * WantReportError
REM * WantReportErrorPrompt
REM * WantKubectlDownloadMsg
REM * WantNoneDriverWarning
REM * profile
REM * bootstrapper
REM * ShowBootstrapperDeprecationNotification
REM * dashboard
REM * addon-manager
REM * default-storageclass
REM * coredns
REM * kube-dns
REM * heapster
REM * efk
REM * ingress
REM * registry
REM * registry-creds
REM * freshpod
REM * default-storageclass
REM * storage-provisioner
REM * metrics-server
REM * hyperv-virtual-switch
REM * disable-driver-mounts
REM * cache
minikube config set vm-driver virtualbox
minikube config set cpus 2
minikube config set kubernetes-version v1.04
minikube config set memory 4096 
mkdir C:\Users\%username%\Desktop\minikubelogs
C:\Users\sysop\.minikube\machines\minikube
minikube config set log_dir C:\Users\%username%\Desktop\minikubelogs
echo Starting minikube in virtual box
minikube start --v=7 --alsologtostderr
if %errorLevel% == 0 (
echo Kubernetes Minikube has been started successfully. 
    ) else (
        echo Failure: Kubernetes Minikube did not start.
		goto exit
    ) 
echo Importing docker container of the docker-ci-tool in minikube with the help of kubectl
kompose convert -f docker-compose.yml
echo Creating the docker-ci-tool-stack service with the help of kubectl 
kubectl create -f jenkins-claim0-persistentvolumeclaim.yaml
kubectl create -f jenkins-claim1-persistentvolumeclaim.yaml
kubectl create -f jenkins-data-persistentvolumeclaim.yaml
kubectl create -f jenkins-deployment.yaml
kubectl create -f jenkins-service.yaml
kubectl create -f nexus-data-persistentvolumeclaim.yaml
kubectl create -f nexus-deployment.yaml
kubectl create -f nexus-service.yaml
kubectl create -f sonardb-deployment.yaml
kubectl create -f sonardb-service.yaml
kubectl create -f sonar-deployment.yaml
kubectl create -f sonar-service.yaml
   if %errorLevel% == 0 (
echo docker-ci-tool-stack is successfully imported to Kubernetes Minikube.
    ) else (
        echo Failure: docker-ci-tool-stack has not been imported to Kubernetes Minikube.
		goto exit
    )
echo Now that docker-ci-tool-stack has been deployed, let uss access it.
echo Further information for accessing a deployed application: https://kubernetes.io/docs/tools/kompose/user-guide/ from Point 3
:exit
	Exit /B 5
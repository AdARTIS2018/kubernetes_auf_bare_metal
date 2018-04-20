echo off
title Installationscript for installing docker-ci-tool-stack to minikube by AdARTIS -all rights reserved-
echo Welcome to the script for installing a docker-ci-tool-stack to Kubernetes's minikube
echo Please make sure that just Windows is installed on your computer, i.e. that no additional software is installed prior to this kubernetes ci/cd-tool setup and that you run this script on a Windows machine which at least is of version 7 and that this script is run in cmd.exe with administrator rights.
    echo Administrative permissions required. Detecting permissions...
    net session >nul 2>&1
    if %errorLevel% == 0 (
    goto continue01
    ) else (
        echo Failure: Current permissions inadequate.
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
echo Installing 7zip
choco install 7zip.portable 
:continue96
echo Release port 1024-65535 on local firewall
netsh advfirewall firewall add rule name="Open_Port_1023-65535_TCP_IN" dir=in action=allow protocol=TCP localport=1023-65535
netsh advfirewall firewall add rule name="Open_Port_1023-65535_TCP_OUT" dir=out action=allow protocol=TCP localport=1023-65535
netsh advfirewall firewall add rule name="Open_Port_1023-65535_UDP_IN" dir=in action=allow protocol=UDP localport=1023-65535
netsh advfirewall firewall add rule name="Open_Port_1023-65535_UDP_OUT" dir=out action=allow protocol=UDP localport=1023-65535
echo Creating and starting Docker machine 192.168.99.100 
"C:\Program Files\Git\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"
echo Downloading docker-ci-tool-stack
IF EXIST C:\Users\%username%\docker-ci-tool-stack RMDIR "C:\Users\%username%\docker-ci-tool-stack" /S /Q
cd C:\Users\%username%
git clone https://github.com/marcelbirkner/docker-ci-tool-stack.git
cd docker-ci-tool-stack
git clone https://github.com/sonatype/docker-nexus3.git
docker-compose up
echo Starting minikube in virtual box
minikube start --kubernetes-version="v1.10" --vm-driver="virtualbox" --v=7 --memory=2048 --alsologtostderr
    if %errorLevel% == 0 (
    goto continue95
    ) else (
        echo Finishing program because minikube did not start.
		minikube stop
		goto exit
    )
    pause >nul
:continue95
cd C:\Users\%username%\docker-ci-tool-stack
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
echo Minikube is up with docker-ci-tool-stack as a service.
echo Now that docker-ci-tool-stack has been deployed, let’s access it.
echo Further information for accessing a deployed application: https://kubernetes.io/docs/tools/kompose/user-guide/ from Point 3
:exit
	Exit /B 5
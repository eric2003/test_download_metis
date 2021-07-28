function InstallMSMPI() {
    # install MPI SDK and Runtime
    Write-Host "Installing Microsoft MPI SDK..."
    $download_url = "https://download.microsoft.com/download/A/E/0/AE002626-9D9D-448D-8197-1EA510E297CE/"
    $msmpisdk_filename = "msmpisdk.msi"
    $msmpisdk_webfilename = $download_url + $msmpisdk_filename

    MyDownloadFile( $msmpisdk_webfilename )
    
    Start-Process -FilePath msiexec.exe -ArgumentList "/quiet /qn /i msmpisdk.msi" -Wait
    Write-Host "Microsoft MPI SDK installation complete"
    
    Write-Host "Installing Microsoft MPI Runtime..."
    $msmpisetup_filename = "msmpisetup.exe"
    $msmpisetup_webfilename = $download_url + $msmpisetup_filename
    
    MyDownloadFile( $msmpisetup_webfilename )
    
    Start-Process -FilePath MSMpiSetup.exe -ArgumentList -unattend -Wait
    Write-Host "Microsoft MPI Runtime installation complete..."
    
    $msmpi_bin_path = "C:/Program Files/Microsoft MPI/Bin"
    $msmpi_sdk_path = "C:/Program Files (x86)/Microsoft SDKs/MPI"
    
    #$Env:Path = $Env:Path + ";$msmpi_bin_path"
    #[environment]::SetEnvironmentvariable("path", $Env:Path, [System.EnvironmentVariableTarget]::Machine)
	
	AddMachinePath( $msmpi_bin_path )
    
    Write-Host "ls $msmpi_sdk_path"
    ls $msmpi_sdk_path
    Write-Host "ls $msmpi_sdk_path"
    ls $msmpi_bin_path
    
    Write-Host "mpiexec"
    mpiexec 
}

function InstallHDF5() {
    Write-Host "Installing HDF5..."
	$zipexe = "C:/Program Files/7-zip/7z.exe" 
    Write-Host "ls C:/Program Files/7-zip"
    ls "C:/Program Files/7-zip"
	
    Start-Process $zipexe -Wait -ArgumentList 'x ./hdf5-1.10.7-Std-win10_64-vs16.zip'
    ls
    cd hdf
    ls
    Write-Host "Installing HDF5-1.10.7..."
    Start-Process -FilePath msiexec.exe -ArgumentList "/quiet /qn /i HDF5-1.10.7-win64.msi" -Wait
    Write-Host "HDF5-1.10.7 installation complete"
	$HDF5_InstallDir = "C:/Program Files/HDF_Group/HDF5/1.10.7"
	Write-Host "ls $HDF5_InstallDir"
	ls $HDF5_InstallDir
	Write-Host "-------------------------------------------"
	$Program_Dir = "C:/Program Files"
	Write-Host "ls $Program_Dir"
	ls $Program_Dir
    ModifyEnvironmentVariable	
}

function InstallCGNS() {
    Write-Host "Installing CGNS..."
	$zipexe = "C:/Program Files/7-zip/7z.exe" 
    Start-Process $zipexe -Wait -ArgumentList 'x ./CGNS-4.2.0.zip'
    ls
    cd CGNS-4.2.0
    ls
	Write-Host "mkdir build..."
	mkdir build
	Write-Host "ls..."
	ls
	cd build
	$tmp = GetMachineEnvironmentVariable("HDF5_DIR")
	$Env:HDF5_DIR
	Write-Host "Machine Environment HDF5_DIR = $tmp"
	Write-Host "local Env:HDF5_DIR = $Env:HDF5_DIR"
	$Env:HDF5_DIR = $tmp;
	Write-Host "now Env:HDF5_DIR = $Env:HDF5_DIR"
	$cgns_prefix = "C:/cgns"
	$cgns_bin = $cgns_prefix + "/bin"
	cmake -DCGNS_ENABLE_64BIT="ON" `
	      -DCGNS_ENABLE_HDF5="ON" `
		  -DCGNS_BUILD_SHARED="ON" `
		  -DCMAKE_INSTALL_PREFIX=$cgns_prefix ../
    cmake --build . --parallel 4 --config release
	cmake --install .
	#$Env:path = GetMachineEnvironmentVariable("path")
	#$Env:path = $Env:Path + ";$cgns_bin" 
	#ModifyMachineEnvironmentVariable "path" $Env:path
	AddMachinePath( $cgns_bin )
    Write-Host "Installing CGNS-4.2.0..."
}

function AddMachinePath( $varPath ) {
	$Env:path = GetMachineEnvironmentVariable( "path" )
	$Env:path = $Env:Path + ";$varPath" 
	ModifyMachineEnvironmentVariable "path" $Env:path
}

function GetMachineEnvironmentVariable( $varName ) {
	$varValue = [environment]::GetEnvironmentvariable($varName , [System.EnvironmentVariableTarget]::Machine)
	$varValue
}

function ModifyEnvironmentVariable() {
    $varName = "HDF5_DIR"
	$varValue = "C:\Program Files\HDF_Group\HDF5\1.10.7\cmake"
    ModifyMachineEnvironmentVariable $varName $varValue
}

function ModifyMachineEnvironmentVariable( $varName, $varValue ) {
    $target = "Machine"
    [Environment]::SetEnvironmentVariable($varName, $varValue, $target)
}

function DownloadHDF5() {
	$hdf5_version_name = "hdf5-1.10.7"
	Write-Host "Downloading $hdf5_version_name..."
	$hdf5_url          = "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.7/bin/windows/"
	$hdf5_name         = "hdf5-1.10.7-Std-win10_64-vs16"
	$hdf5_package_name = $hdf5_name + ".zip"
	$hdf5_web_addr = $hdf5_url + $hdf5_package_name
		  
	MyDownloadFile( $hdf5_web_addr )
	ls
	Write-Host "$hdf5_version_name downloading complete"
}

function DownloadCGNS() {
	Write-Host "Downloading CGNS-4.2.0..."
	$download_url = "https://github.com/CGNS/CGNS/archive/refs/tags/"
	$cgns_filename = "v4.2.0.zip"
	$cgns_real_filename = "CGNS-4.2.0.zip"	
	$cgns_webfilename = $download_url + $cgns_filename
	
	Write-Host "download_url is $download_url"
	Write-Host "cgns_webfilename is $cgns_webfilename"
	Write-Host "cgns_real_filename is $cgns_real_filename"
	Write-Host "calling MyDownloadFile2 cgns_webfilenamec cgns_real_filename"

	#MyDownloadFile( $cgns_webfilename )
	MyDownloadFile2 $cgns_webfilename $cgns_real_filename
	ls
	Write-Host "CGNS-4.2.0 downloading complete"
}


function MyGetFileName( $filePath ) {
	$file_name_complete = [System.IO.Path]::GetFileName("$filePath")
	$file_name_complete
	#Write-Host "fileNameFull :" $file_name_complete	
}

function MyDownloadFile( $fullFilePath ) {
	$my_filename = MyGetFileName("$fullFilePath")
	$my_location = Get-Location
	$my_local_filename = "$my_location" + "/" + $my_filename
	
	$my_client = new-object System.Net.WebClient
	$my_client.DownloadFile( $fullFilePath, $my_local_filename )	
}

function MyDownloadFile2( $fullFilePath, $my_filename ) {
	Write-Host "MyDownloadFile2 fullFilePath is $fullFilePath"
	Write-Host "MyDownloadFile2 my_filename is $my_filename"
	$my_location = Get-Location
	Write-Host "MyDownloadFile2 my_location is $my_location"
	$my_local_filename = "$my_location" + "/" + $my_filename
	Write-Host "MyDownloadFile2 my_local_filename is $my_local_filename"
	
	$my_client = new-object System.Net.WebClient
	$my_client.DownloadFile( $fullFilePath, $my_local_filename )	
}


function main() {
	InstallMSMPI
	DownloadHDF5
	InstallHDF5
	DownloadCGNS
	InstallCGNS
}

main

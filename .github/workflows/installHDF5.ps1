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
    Write-Host "Installing CGNS-4.2.0..."
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
	Write-Host "$hdf5_version_name downloading complete"
}

function DownloadCGNS() {
	Write-Host "Downloading CGNS-4.2.0..."
	$download_url = "https://github.com/CGNS/CGNS/archive/refs/tags/"
	$cgns_filename = "v4.2.0.zip"
	$cgns_webfilename = $download_url + $cgns_filename

	MyDownloadFile( $cgns_webfilename )
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

function main() {
	DownloadHDF5
    InstallHDF5
	DownloadCGNS
}

main

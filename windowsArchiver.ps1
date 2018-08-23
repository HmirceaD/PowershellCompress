Param(
	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$dirPath,

	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[DateTime]$date,

	[Parameter(Mandatory=$True)]
	[ValidateNotNullOrEmpty()]
	[string]$outputPath = $MyInvocation.MyCommand.Path

)

#check if parameters are correct
#date is required by powershell to be correct
$dirPathEx = Test-Path $dirPath
$outputPathEx = Test-Path $outputPath
If($dirPathEx -eq $False -Or $outputPathEx -eq $False){
	
	Write-Output "Nu-i bun un path"
	exit
}

#get all files in the $dirPath

$global:filesToBeArchived = [System.Collections.ArrayList]@()

function Parse-DirPath{
	param([string]$tempPath, [bool]$removeOrAdd)
	
	#gets all directories
	$directoriesInPath = Get-ChildItem $tempPath -Directory
	#get all .txt files before certain date
	$txtFiles = Get-ChildItem -Path $tempPath | Where-Object { $_.Extension -eq ".txt" -and $_.LastWriteTime -lt $date} 

	if($removeOrAdd -eq $True){
		#adds them to files to be parsed
		$global:filesToBeArchived += $txtFiles
	} else{
		#removes the files
		forEach( $file in $txtFiles){
			Remove-Item  -Path $file.FullName	
		}
	}

	#go for subdirectories
	forEach($subDir in $directoriesInPath){

		Parse-DirPath -tempPath $subDir -removeOrAdd $removeOrAdd
	}

}

#parse
Parse-DirPath -tempPath $dirPath -removeOrAdd $True

#compress the zip thing
$global:filesToBeArchived | Compress-Archive -DestinationPath $outputPath -Update

#delete
Parse-DirPath -tempPath $dirPath -removeOrAdd $False


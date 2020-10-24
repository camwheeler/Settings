Set-Location C:\Projects\git
Set-Alias date Get-Date
Set-Alias np 'C:\Program Files\Notepad++\notepad++.exe'
Set-Alias s 'C:\Program Files\Sublime Text 3\sublime_text.exe'
Set-Alias e 'explorer'

$vs2017 = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"
$vs2019 = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe"

function vs{
    OpenSolution($vs2019)
}

function OpenSolution([string]$programPath){
	$solutions = @()
	ls -recurse -include *.sln | ForEach-Object { $solutions += $_.FullName }
	If($solutions.count -eq 1){
		Start-Process $programPath -ArgumentList $solutions[0]
	}
	ElseIF($solutions.count -gt 1){
		$solutions | ForEach-Object {
			$output = ([array]::IndexOf($solutions, $_) + 1).ToString() + ") " + (Split-Path $_ -leaf)
			Write-Host $output
		}

		[int]$selection = $null
		$selectionString = Read-Host
		If([int32]::TryParse($selectionString , [ref]$selection )){
			Start-Process $programPath -ArgumentList $solutions[$selection - 1]
		}
	}
	Else{
		Write-Host "No solutions found."
	}
}

# Compute file hashes - useful for checking successful downloads
function md5    { Get-FileHash -Algorithm MD5 $args }
function sha1   { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

function cleanbin {
	$directory = $pwd
	Write-Host "Cleaning projects in $pwd" -ForegroundColor Yellow
	Get-ChildItem .\ -include bin,obj -Recurse | ForEach-Object ($_) {
		$localDirectory = Resolve-Path -Relative $_.FullName | Split-Path
		if($directory -ne ($localDirectory)){
			$_ | Resolve-Path -Relative | % { Write-Host "`t$localDirectory" -ForegroundColor Cyan }
			$directory = $localDirectory
        }
        Write-Host "`t`t -$($_.Name)" -NoNewline -ForegroundColor Red
        if($_ -is [System.IO.DirectoryInfo]) {
            Write-Host "\" -ForegroundColor Red
        }
        else {
            Write-Host "" -ForegroundColor Red
        }
		remove-item $_.fullname -Force -Recurse
    }
}

function cleangit {
	git branch --merged | %{$_.trim()} | ?{$_ -notmatch 'develop' -and $_ -notmatch 'master'} | %{git branch -d $_}
}

Start-Service ssh-agent
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Avit

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

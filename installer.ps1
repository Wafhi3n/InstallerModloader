#Loc#

if ($PsUICulture -eq  "fr-FR")
{
    $culture=$PsUICulture
$UserMessages = DATA
{    ConvertFrom-StringData @'
        gitInstallation = Installation de git
        notInstalledIn = non installé dans
        gitClone = installation avec git clone...
        notInstall = Le Modloader n'est pas installé
        icoDesc = Civilization VI - CivFR
        shortcutCreated = Icone crée sur le Bureau : Civ6-BBG!
        notEmpty = Dossier de Mods non vide, souhaitez-vous supprimer tout les mods à l'interieurs ? (o)ui ou (n)on
        yes = o
        no = n
        done = installation terminée
        alreadyInstall = deja installé
        fileIco = launcher_CivFR.ico
'@
}
}else{
    $culture="en-EN";
$UserMessages = DATA
{    ConvertFrom-StringData @'
gitInstallation = Git will now be installed with winget
notInstalledIn = is not Installed in
gitClone = "will now be installed with git Clone...
notInstall = Modloader is not installed
icoDesc = Civilization VI - CPL
shortcutCreated = Shortcut created on desktop : Civilization VI - CPL!
notEmpty = Mods Folder not empty, do you want to clean it ? (y)es ou (n)o
yes = y
no = n
done = Setup completed
alreadyInstall = already installed
fileIco = launcher_CPL.ico
'@
}
} 

#Fonction#
function VerifGit {
    try
    {
        git | Out-Null
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Host $UserMessages.gitInstallation
        winget install --id Git.Git -e --source winget
        #refresh l'envirronement pour avoir git
        $Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    }
}
function VerifAndInstallWithGit {
    param (
        $Repo,
        $Path

    )
    $DirName=GetName $Repo
    $TotalPath=$Path+"\"+$DirName
    if (!(Test-Path -Path $TotalPath -PathType Container )) {
        Write-Host $($DirName+" - "+$UserMessages.notInstalledIn+" "+$TotalPath);
        Write-Host $($UserMessages.gitClone)
        Set-Location $Path
        git clone $Repo
    }          
}
function GetName {
    param(
        $GitName
    )
     $GitName.Split('/')[-1].Split('.')[0]
}
function VerifAndInstallModWithGit {
    param (
        $Mod
    )    
    VerifAndInstallWithGit $Mod $dirMod    
}

function createIcon() {
    param (
    )
    $targetPath = "powershell.exe"
    $Arguments = '-ExecutionPolicy Bypass -File "'+$com+'" byInstaller'
    $Path=$($desktop+"\"+$UserMessages.icoDesc+".lnk")
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($Path)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.Arguments  = $Arguments
    $Shortcut.IconLocation = $($documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\"+$culture+"\"+$UserMessages.fileIco)
    $Shortcut.Save()
}

#Conf
$documents=[environment]::getfolderpath("mydocuments")
$desktop=[environment]::getfolderpath("desktop")
$documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv"
$gitUpdategitCiv = "https://github.com/Wafhi3n/UpdateGitModCiv"
$env:GIT_REDIRECT_STDERR = '2>&1'

if(!(Test-Path -Path $($documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv"))){
    #installation
    Write-Host $($UserMessages.notInstall)
    $com = $documents+"\My Games\Sid Meier's Civilization VI\UpdateGitModCiv\majGitCiv.ps1"
    VerifGit
    #Verification de Modloader
    VerifAndInstallWithGit $gitUpdategitCiv $($documents+"\My Games\Sid Meier's Civilization VI")
    #Verification de la presence de l'icone
    if(!(Test-Path -Path $($desktop+"\"+$shortCutName+".lnk")  -PathType Leaf )-and $isShortcut -ne "shotcut"){
        createIcon
        Write-Host $($UserMessages.shortcutCreated)
    }

    #verification du dossier de mods
    if((Test-Path -Path $($documents+"\My Games\Sid Meier's Civilization VI\Mods"))){
        ls $($documents+"\My Games\Sid Meier's Civilization VI\Mods")
        $rmModFolder = Read-Host -Prompt $($UserMessages.notEmpty)
        Write-Host $rmModFolder
        if ($rmModFolder = $UserMessages.yes){
            "ok"
            Get-ChildItem -Path $($documents+"\My Games\Sid Meier's Civilization VI\Mods") -Recurse | Remove-Item -force -recurse
        }
    }
    Write-Host $($UserMessages.done)
    Start-Sleep -s 5
    exit 0;
}else{
    Write-Host $($UserMessages.alreadyInstall)
}
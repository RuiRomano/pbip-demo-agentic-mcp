param (
    $src = @("**\*.SemanticModel", "**\*.Report")        
)
  
$currentFolder = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

if ($src.Length -eq 0) {
    
    Write-Host "Please provide a valid path to the source files."

    return
}

#region: Tools download

$toolsPath = "$currentFolder\_tools"

$tools = @(
    @{"tool" = "TabularEditor"; "downloadUrl" = "https://github.com/TabularEditor/TabularEditor/releases/latest/download/TabularEditor.Portable.zip"; "rulesUrl" = "https://raw.githubusercontent.com/microsoft/Analysis-Services/master/BestPracticeRules/BPARules.json" }
    ,
    @{"tool" = "PBIInspector"; "downloadUrl" = "https://github.com/NatVanG/PBI-InspectorV2/releases/latest/download/win-x64-CLI.zip"; "rulesUrl" = "https://raw.githubusercontent.com/NatVanG/PBI-InspectorV2/refs/heads/main/Rules/Base-rules.json" }
)

foreach ($tool in $tools) {

    $toolName = $tool.tool
    $downloadUrl = $tool.downloadUrl
    $rulesUrl = $tool.rulesUrl

    $destinationPath = "$toolsPath\$toolName"

    if (!(Test-Path $destinationPath)) {

        New-Item -ItemType Directory -Path $destinationPath -ErrorAction SilentlyContinue | Out-Null            

        Write-Host "Downloading $toolName"

        $zipFile = "$destinationPath\$toolName.zip"

        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

        Expand-Archive -Path $zipFile -DestinationPath $destinationPath -Force     

        Remove-Item $zipFile        

        # Downloading default rules

        Invoke-WebRequest -Uri $rulesUrl -OutFile "$destinationPath\defaultRules.json"
    }    
}

#endregion

#region Run tools

$tabularEditorEXE = "$toolsPath\TabularEditor\TabularEditor.exe"
$tabularEditorRulesPath = "$currentFolder\bpa-rules-semanticmodel.json"
$pbiInspectorEXE = "$toolsPath\PBIInspector\win-x64\CLI\PBIRInspectorCLI.exe"
$pbiInspectorRulesPath = "$currentFolder\bpa-rules-report.json"

if (!(Test-Path $tabularEditorRulesPath)) {

    Write-Host "Using default rules for Tabular Editor"
    $tabularEditorRulesPath = "$toolsPath\TabularEditor\defaultRules.json"
}

if (!(Test-Path $pbiInspectorRulesPath)) {
    Write-Host "Using default rules for PBI Inspector"
    $pbiInspectorRulesPath = "$toolsPath\PBIInspector\defaultRules.json"
}

foreach ($srcPath in $src) {
    
    if (!(Test-Path $srcPath)) {
        Write-Host "Source path '$srcPath' does not exist."
        continue
    }

    $itemsFolders = Get-ChildItem  -Path $srcPath -recurse -include ("*.pbidataset", "*.pbism", "*.pbir") | Sort-Object Name -Descending

    foreach ($itemFile in $itemsFolders) {
        
        # Semantic model
        if ($itemFile.Extension -in @(".pbidataset", ".pbism")) {

            $itemPath = "$($itemFile.Directory.FullName)\definition"

            if (!(Test-Path $itemPath)) {
                $itemPath = "$($itemFile.Directory.FullName)\model.bim"

                if (!(Test-Path $itemPath)) {
                    throw "Cannot find semantic model definition."
                }
            }

            Write-Host "Running Tabular Editor BPA rules for: '$itemPath'"

            $process = Start-Process -FilePath $tabularEditorEXE -ArgumentList """$itemPath"" -A ""$tabularEditorRulesPath"" -G" -NoNewWindow -Wait -PassThru    

            if ($process.ExitCode -ne 0) {
                throw "Error running rules for: '$itemPath'"
            }                
        }
        # Report
        elseif ($itemFile.Extension -eq ".pbir") {

            $itemPath = "$($itemFile.Directory.FullName)\definition"

            if (!(Test-Path $itemPath)) {
                Write-Warning "Cannot find report PBIR definition. If you are using PBIR-Legacy (report.json), please convert it to PBIR using Power BI Desktop."
                continue
            }

            Write-Host "Running PBI Inspector BPA rules for: '$itemPath'"

            $process = Start-Process -FilePath $pbiInspectorEXE -ArgumentList "-pbipreport ""$itemPath"" -rules ""$pbiInspectorRulesPath"" -formats ""GitHub""" -NoNewWindow -Wait -PassThru    

            if ($process.ExitCode -ne 0) {
                throw "Error running BPA rules for: '$itemPath'"
            }    
        }
        else {
            throw "Unsupported file type: $($itemFile.Extension)"
        }        
    }

}

#endregion
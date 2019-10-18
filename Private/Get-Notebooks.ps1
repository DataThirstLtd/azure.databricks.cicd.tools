Function Get-Notebooks ($FolderContents, $OriginalPath, $LocalOutputPath, $Format="SOURCE" ) {

    if ($Format -eq "DBC"){
        Set-LocalNotebook $OriginalPath "dbc" $Region $InternalBearerToken $LocalOutputPath "DBC"
        return
    }

    $FolderContent = $FolderContents.objects

    ForEach ($Object In $FolderContent)
    {
        if($Object.object_type -eq "DIRECTORY")
        {
            $FolderName = ($Object.path).Replace($OriginalPath,"")
            Write-Verbose "Folder Name: $FolderName!"
            $SubfolderContents = Get-FolderContents $Object.path
            Get-Notebooks $SubfolderContents ($Object.path + "/") $LocalOutputPath $Format
        }
        elseif ($Object.object_type -eq "NOTEBOOK")
        {
            $Notebook = $Object.path
            $NotebookLanguage = $Object.language
            Write-Verbose "Calling Writing of $Notebook ($NotebookLanguage)"
            Set-LocalNotebook $Notebook $NotebookLanguage $LocalOutputPath $Format
        }
        else {
            Write-Warning "Unknown Type $Object.object_type"
        }
    }
}


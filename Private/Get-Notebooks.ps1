Function Get-Notebooks ($FolderContents, $OriginalPath, $Region, $InternalBearerToken, $LocalOutputPath, $Format="SOURCE" ) {

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
            Write-Verbose "Folder Name: $FolderName"
            $SubfolderContents = Get-FolderContents $Object.path $Region $InternalBearerToken
            Get-Notebooks $SubfolderContents ($Object.path + "/") $Region $InternalBearerToken $LocalOutputPath $Format
        }
        elseif ($Object.object_type -eq "NOTEBOOK")
        {
            $Notebook = $Object.path
            $NotebookLanguage = $Object.language
            Write-Verbose "Calling Writing of $Notebook ($NotebookLanguage)"
            Set-LocalNotebook $Notebook $NotebookLanguage $Region $InternalBearerToken $LocalOutputPath $Format
        }
        else {
            Write-Warning "Unknown Type $Object.object_type"
        }
    }
}
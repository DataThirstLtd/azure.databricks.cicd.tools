Set-Location $PSScriptRoot
Import-Module "..\azure.databricks.cicd.tools.psm1" -Force

Describe "HashCompare" {

    It "Matched Simple"{
        $Previous = @{bob=1;fred=3}
        $New = @{bob=1;fred=3}
        HashCompare $Previous $New | Should -Be 0
    }

    It "Previous Missing One"{
        $Previous = @{bob=1;fred=3}
        $New = @{bob=1;fred=3;ted=4}
        HashCompare $Previous $New | Should -Be 1
    }

    It "New Missing One"{
        $Previous = @{bob=1;fred=3;ted=4}
        $New = @{bob=1;fred=3}
        HashCompare $Previous $New | Should -Be 1
    }

    It "Same Count but different"{
        $Previous = @{bob=1;simon=3}
        $New = @{bob=1;fred=3}
        HashCompare $Previous $New | Should -Be 2
    }

    It "Nested matched"{
        $Previous = @{bob=1;simon=@{d=1}}
        $New = @{bob=1;simon=@{d=1}}
        HashCompare $Previous $New | Should -Be 0
    }

    It "Nested difference"{
        $Previous = @{bob=1;simon=@{d=1}}
        $New = @{bob=1;simon=@{d=2}}
        HashCompare $Previous $New | Should -Be 1
    }

    It "Nested difference (new additional)"{
        $Previous = @{bob=1;simon=@{d=1}}
        $New = @{bob=1;simon=@{d=2;e=1}}
        HashCompare $Previous $New | Should -Be 2
    }

    It "Nested difference (previous additional)"{
        $Previous = @{bob=1;simon=@{d=1;e=1}}
        $New = @{bob=1;simon=@{d=2}}
        HashCompare $Previous $New | Should -Be 2
    }

    It "Double Nested matched"{
        $Previous = @{bob=1;simon=@{d=@{r=1;s=1}}}
        $New = @{bob=1;simon=@{d=@{r=1;s=1}}}
        HashCompare $Previous $New | Should -Be 0
    }

    It "Double Nested difference"{
        $Previous = @{bob=1;simon=@{d=@{r=1;s=1}}}
        $New = @{bob=1;simon=@{d=@{r=4;s=1}}}
        HashCompare $Previous $New | Should -Be 1
    }

    It "DataType Change string int"{
        $Previous = @{bob=1;simon=@{d=@{r=1;s=1}}}
        $New = @{bob=1;simon=@{d=@{r="hello";s=1}}}
        HashCompare $Previous $New | Should -Be 1
    }

    It "DataType Change hashtable"{
        $Previous = @{bob=1;simon=@{d=@{r=2;s=2}}}
        $New = @{bob=1;simon=@{d=1}}
        HashCompare $Previous $New | Should -Be 1
    }
}

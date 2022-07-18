<#
    .SYNOPSIS
        Creates one archive page per year for blog articles

    .DESCRIPTION
        When using Jekyll you'll find that some themes (like jekyll-theme-potato-hacker) don't support paging in blogs. 
        Large blogs thus get huge and load slowly. This script can be used to create archive pages for old blog posts. 
        It creates one page per year in the _dropdown folder.


    .PARAMETER workDir
        The folder containing the Jekyll website    

    .EXAMPLE
        pwsh archive-blog.ps1 ~/rauschzeit.github.io

    .NOTES
        The script depends on powershell-yaml. You'll have to install that first via:
        "Install-Module -Name powershell-yaml"
#>

param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    [string]$workDir
)

Import-Module powershell-yaml
Set-StrictMode -Version 3

class MarkdownFile {
    
    [System.IO.FileSystemInfo]$File
    [System.Object]$FrontMatter
    [string[]]$Markdown

    # Contructor that gets used to read a file
    MarkdownFile($file) {
        $this.File = $file        
        $this.FrontMatter = $this.GetFrontMatter()
        $this.Markdown = $this.GetMarkdown()
    }

    # Contructor that gets used to create a file
    MarkdownFile($filePath, $pageHeader) {
        if(Test-Path -Path $filePath -PathType Leaf) {
            Remove-Item -Path $filePath
        }
        $this.File = New-Item -ItemType File -Path $filePath
        $this.FrontMatter = $pageHeader
        $this.Markdown = @()
    }

    hidden [System.Object]GetFrontMatter() {
        [string[]]$content = Get-Content -Path $this.File.FullName -Encoding UTF8
        [string[]]$yamlLines = @()       
        if("---" -ne $content[0]) {
            return $null
        }

        for ($i=2; $i -le ($content.Length - 1); $i += 1) {
            if("---" -eq $content[$i]) {
                $yamlLines = $content[1 .. ($i -1)]
                break;
            }
        }

        if(0 -lt $yamlLines.Length) {            
            return ConvertFrom-Yaml ($yamlLines -join "`r`n")
        }

        return $null
    }

    hidden [string[]]GetMarkdown() {
        [string[]]$content = Get-Content -Path $this.File.FullName -Encoding UTF8
        if("---" -ne $content[0]) {
            return $content
        }

        for ($i=2; $i -le ($content.Length - 1); $i += 1) {
            if("---" -eq $content[$i] -and $content.Length -gt $i +1) {
                return $content[($i +1) .. ($content.Length -1)]                
            }
        }

        return $content
    }

    [void]Write() {
        "---" | Out-File -FilePath $this.File.FullName
        ConvertTo-Yaml $this.FrontMatter | Out-File -FilePath $this.File.FullName -Append
        "---" | Out-File -FilePath $this.File.FullName -Append
        $this.Markdown -join "`r`n" | Out-File -FilePath $this.File.FullName -Append
    }

}

class ArchivePageHeader {

    [string]$layout
    [string]$title
    [string]$dropdown
    [int]$priority

    ArchivePageHeader([string]$title, [int]$priority) {
        $this.layout = "page"
        $this.title = $title
        $this.dropdown = "Blog-Archiv"
        $this.priority = $priority
    }

}

class BlogProcessor {

    [string]$WorkDir    

    BlogProcessor($dir) {
        $this.WorkDir = $dir                
    }

    [void]Run() {
        [MarkdownFile]$archivePage = $null
        [string]$currentYear = Get-Date -Format "yyyy"
        [string]$yearBeingProcessed = ""
        [int]$priority = 1
        [System.IO.FileSystemInfo[]]$files = Get-ChildItem -Path "$($this.WorkDir)/_posts" -Recurse -include ('*.md', '*.html')
        foreach ($file in $files) {
            $blogPostYear = $file.Name[0..3] -join ""
            if($currentYear -ne $blogPostYear) {                
                if($yearBeingProcessed -ne $blogPostYear) {
                    if("" -ne $yearBeingProcessed) {
                        $archivePage.Write()
                    }
                 
                    [ArchivePageHeader]$header = [ArchivePageHeader]::new("Blog-Archiv $blogPostYear", $priority++)
                    $archivePage = [MarkdownFile]::new("$($this.WorkDir)/_dropdown/blog-$blogPostYear.md", $header)
                    $archivePage.Markdown = @("# Blog-Archiv $blogPostYear")                    
                    $yearBeingProcessed = $blogPostYear
                }
                
                Write-Host $file.Name

                $mdFile = [MarkdownFile]::new($file)
                $postPrefix = @()
                $postPrefix += "`r`n"
                $postPrefix += "<a id=`"$($mdFile.FrontMatter.wordpress_id)`"></a>`r`n"
                try {
                    $postPrefix += "## $($mdFile.FrontMatter.title)`r`n"
                } catch {
                    $postPrefix += "## Ohne-Titel`r`n"
                }

                $archivePage.Markdown = $archivePage.Markdown + $postPrefix
                foreach($line in $mdFile.Markdown) {
                    # You don't need this: special handling for broken links in rauschzeit.de
                    [string]$fixedLine = $line -replace "http\:\/\/rauschzeit.de\/\?p=", "#"   
                    $archivePage.Markdown = $archivePage.Markdown + $fixedLine
                }
            }
        }
        if($null -ne $archivePage) {
            $archivePage.Write()
        }
    }

}

$processor = [BlogProcessor]::new($workDir)
$processor.Run()

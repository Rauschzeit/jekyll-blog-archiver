# Jekyll-Blog-Archiver

```
NAME
    /home/tom/jekyll-blog-archiver/archive-blog.ps1

SYNOPSIS
    Creates one archive page per year for blog articles


SYNTAX
    /home/tom/jekyll-blog-archiver/archive-blog.ps1 [-workDir] <String> [<CommonParameters>]


DESCRIPTION
    When using Jekyll you'll find that some themes (like jekyll-theme-potato-hacker) don't support paging in blogs.
    Large blogs thus get huge and load slowly. This script can be used to create archive pages for old blog posts.
    It creates one page per year in the _dropdown folder.


PARAMETERS
    -workDir <String>
        The folder containing the Jekyll website

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByPropertyName)
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        The script depends on powershell-yaml. You'll have to install that first via:
        "Install-Module -Name powershell-yaml"

    -------------------------- EXAMPLE 1 --------------------------

    PS > pwsh archive-blog.ps1 ~/rauschzeit.github.io
```
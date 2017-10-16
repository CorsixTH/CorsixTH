# Copyright (c) 2017 David Fairbrother
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Requirements:

# git - Installed and added to path

# Parameters
Param(
    [Parameter(Mandatory=$true)][bool]$BuildAnimView,
    [Parameter(Mandatory=$true)][bool]$IsX64Build,
    [Parameter(Mandatory=$true)][string]$VcpkgCommitSha
)

################
# Variables
################

$anim_view_libs = "wxwidgets"
$corsixth_libs = "ffmpeg", "freetype", "lua", "luafilesystem", "lpeg", "sdl2", "sdl2-mixer"

$vcpkg_git_url = "https://github.com/Microsoft/vcpkg"

$dest_folder_name = "vcpkg"
$dest_folder_path = ".\vcpkg"

$x86_triplet_name = "x86-windows"
$x64_triplet_name = "x64-windows"

###################
# Functions
###################

function run_command($command){
    Invoke-Expression $command
    if ($LASTEXITCODE -ne 0){
        throw "Failed to run command :`n $command `nExiting."
    }
}

##################
# Main script
##################

# Wrap in func so we can try-finally
function run_script {

    # Test the required files are in the path
    if ((Get-Command "git.exe") -eq $null) {
        throw "Error git was not found. Is it installed, added to your path 
               and have you restarted your Powershell session since?"
    }

    # Check we have the latest copy of vcpkg
    if ((Test-Path $dest_folder_path) -eq $false){
        # If vcpkg does not exist clone it
        run_command -command "git clone $vcpkg_git_url $dest_folder_name"
        Set-Location -Path $dest_folder_path
    } else {
        # Move into vcpkg folder and update to latest version
        Set-Location -Path $dest_folder_path
        run_command "git reset --hard; git fetch origin; git checkout $VcpkgCommitSha"
    }

    $commit_id_filename = "commit_id.txt"
    if ((Test-Path $commit_id_filename) -eq $false -or
        (Get-Content $commit_id_filename | Where-Object {$_ -NotContains $VcpkgCommitSha})){
            # Commit we point to has updated, bootstrap any changes.
        run_command ".\bootstrap-vcpkg.bat"
        Set-Content -Path $commit_id_filename -Value $VcpkgCommitSha
    }

    # Always make sure we are using the latest files
    run_command ".\vcpkg update"

    # Build the triplet flag e.g. --triplet "x64-windows"
    $triplet = "--triplet `""
    if ($IsX64Build) {$triplet += $x64_triplet_name} else {$triplet += $x86_triplet_name}
    $triplet += '"'

    $libs_list = ""
    # Build our libs list
    foreach ($library in $corsixth_libs){
        $libs_list += $library + ' '
    }

    if ($BuildAnimView){
        foreach ($library in $anim_view_libs){
            $libs_list += $library + ' '
        }
    }

    # Compile them locally
    $install_command = ".\vcpkg install " + $triplet + $libs_list
    run_command -command $install_command

    # Copy various files from bin to tools 
    $vcpkg_installed_path = ".\installed\"
    if ($IsX64Build) {$vcpkg_installed_path += $x64_triplet_name}
        else {$vcpkg_installed_path += $x86_triplet_name}

    Set-Location $vcpkg_installed_path

    Write-Output "Copying files from bin to tools"
    $files_to_copy_from_bin = "lfs.dll", "lpeg.dll"
    foreach ($file in $files_to_copy_from_bin){
        Copy-Item -Path ".\bin\$file" -Destination ".\tools"
    }
    
    Write-Output "Finished building libraries"
}

# Run the script
$starting_dir = Convert-Path .
try{
    run_script
    # Move back up a dir to return user to original location
    Set-Location -Path $starting_dir
} catch{
    Set-Location -Path $starting_dir
    Exit -1
}

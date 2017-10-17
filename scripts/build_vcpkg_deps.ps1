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
    [Parameter(Mandatory=$true)][string]$BuildFolderAbsPath,
    [Parameter(Mandatory=$true)][bool]$IsX64Build,
    [Parameter(Mandatory=$true)][string]$VcpkgCommitSha
)

################
# Variables
################

$anim_view_libs = "wxwidgets"
$corsixth_libs = "ffmpeg", "freetype", "lua", "luafilesystem", "lpeg", "sdl2", "sdl2-mixer"

$vcpkg_git_url = "https://github.com/CorsixTH/vcpkg"

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

# Wrap in function so we can try-catch
function run_script {

    # Test the required files are in the path
    if ((Get-Command "git.exe") -eq $null) {
        throw "Error git was not found. Is it installed, added to your path 
               and have you restarted since?"
    }

    # Check we have the latest copy of vcpkg
    if (-Not (Test-Path $dest_folder_path)){
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

    # If we are building the animation viewer be sure to include those libs
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
    
    Write-Output "Copying files to build folder"

    # Create the Debug and Release folder if they do not exist (fresh folder)
    # We expect it to be built to *BuildFolder*\CorsixTH\(Debug|Release)
    $debug_build_path = $BuildFolderAbsPath + "\CorsixTH\Debug"
    $release_build_path = $BuildFolderAbsPath + "\CorsixTH\Release"

    # Create the destination folders if they do not exist
    # Have to pipe to Out-Null as they print the result which adds noise to
    # the CMake console
    if (-Not (Test-Path -Path $debug_build_path)){
        New-Item -ItemType Directory -Force -Path $debug_build_path | Out-Null
    }
    if (-Not (Test-Path -Path $release_build_path)){
        New-Item -ItemType Directory -Force -Path $release_build_path | Out-Null
    }

    # Copy all tools to the output folders
    Copy-Item -Force -Path ".\tools\*" -Destination $debug_build_path
    Copy-Item -Force -Path ".\tools\*" -Destination $release_build_path

    # Copy the DLLs over
    Copy-Item -Force -Path ".\debug\bin\*.dll" -Destination $debug_build_path
    Copy-Item -Force -Path ".\bin\*.dll" -Destination $release_build_path


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

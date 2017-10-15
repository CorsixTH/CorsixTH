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
# cmake - Installed and added to path

$corsixth_libs = "ffmpeg", "freetype", "lua", "sdl2", "sdl2-mixer", "wxwidgets"

$vcpkg_git_url = "https://github.com/Microsoft/vcpkg"

$dest_folder_name = "vcpkg"
$dest_folder_path = ".\vcpkg"


###################
# Functions
###################

function install_libs($install_command){
    Invoke-Expression $install_command
    if ($LASTEXITCODE -ne 0){
        throw "Failed to install libs. Command was: $install_command \nExiting"
    }
}

function export_libs ($export_command, $arch){
    Invoke-Expression $export_command
    if ($LASTEXITCODE -ne 0){
        throw "Failed to export libs. Command was: $export_command \nExiting"
    }

    # Rename to something more useful
    $file = Get-Item -Path "vcpkg-export*"
    $new_name = "CorsixTH-Win-Deps-$arch-$(get-date -f MM-dd-yyyy_HH_mm_ss).7z"
    Rename-Item -Path $file -NewName $new_name
}


##################
# Main script
##################

# Test the required files are in the path
if ((Get-Command "git.exe") -eq $null) {
    throw "Error git was not found. Is it installed, added to your path 
           and have you restarted your Powershell session since?"
}

# Test the required files are in the path
if ((Get-Command "cmake.exe") -eq $null) {
    throw "Error cmake was not found. Is it installed, added to your path 
           and have you restarted your Powershell session since?"
}


# Check we have the latest copy of vcpkg
if ((Test-Path $dest_folder_path) -eq $false){
    # If vcpkg does not exist clone it
    $command = "git clone $vcpkg_git_url $dest_folder_name"
    Invoke-Expression $command
    if ($LASTEXITCODE -ne 0 -or (Test-Path $dest_folder_path) -eq $false){
        throw "Failed to clone to vcpkg. Exiting."
    }
    Set-Location -Path $dest_folder_path
} else {
    # Move into vcpkg folder and update to latest version
    Set-Location -Path $dest_folder_path

    $command = "git reset --hard; git pull origin master"
    Invoke-Expression $command
    if ($LASTEXITCODE -ne 0){
        throw "Failed to update vcpkg. Exiting."
    }
}

# We should now be in the vcpkg folder as both if blocks have moved us in there.
# Next bootstrap it
Invoke-Expression ".\bootstrap-vcpkg.bat"

$libs_list = ""
$x86_triplet = '--triplet "x64-windows"'
$x64_triplet = '--triplet "x86-windows"'

# Build our libs list
foreach ($library in $corsixth_libs){
    $libs_list += $library + ' '
}

$install_command = ".\vcpkg install "
$install_command_64 = $install_command + $x64_triplet + $libs_list
$install_command_86 = $install_command + $x86_triplet + $libs_list

# Compile them locally
install_libs -install_command $install_command_64
install_libs -install_command $install_command_86

# Construct our export command
$export_command = ".\vcpkg export "
$export_command_64 = $export_command + $x64_triplet + $libs_list
$export_command_86 = $export_command + $x86_triplet + $libs_list

# Ask for 7zip format as that works best with CMake
$export_command_64 += "--7zip"
$export_command_86 += "--7zip"

# Before we start remove any existing exported files so we can identify the created files
Remove-Item -Path "vcpkg-export*" -Recurse -Force

export_libs -export_command $export_command_64 -arch "x64"
export_libs -export_command $export_command_86 -arch "x86"

# Move created 7zip files up to parent dir
Move-Item *.7z ..

# Move back up a dir to return user to original location
Set-Location -Path ..
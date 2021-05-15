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
    [Parameter(Mandatory = $true)][bool]$BuildAnimView,
    [Parameter(Mandatory = $true)][string]$VcpkgTriplet,
    [Parameter(Mandatory = $true)][string]$VcpkgCommitSha
)

################
# Variables
################

$anim_view_libs = "wxwidgets"
$corsixth_libs = "ffmpeg[core,avcodec,avformat,swresample,swscale]", "freetype", "lua", "luafilesystem", "lpeg", "sdl2", "sdl2-mixer[dynamic-load,libflac,mpg123,libmodplug,libvorbis]", "luasocket", "luasec", "catch2"

$vcpkg_git_url = "https://github.com/CorsixTH/vcpkg"

$dest_folder_name = "vcpkg"
$dest_folder_path = ".\vcpkg"

###################
# Functions
###################

function run_command($command) {
    Invoke-Expression $command
    if ($LASTEXITCODE -ne 0) {
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
    if (-Not (Test-Path $dest_folder_path)) {
        # If vcpkg does not exist clone it
        run_command -command "git clone $vcpkg_git_url $dest_folder_name"
        Set-Location -Path $dest_folder_path
        run_command "git checkout $VcpkgCommitSha"
    }
    else {
        # Move into vcpkg folder and update to latest version
        Set-Location -Path $dest_folder_path
        run_command "git reset --hard; git fetch origin; git checkout $VcpkgCommitSha"
    }

    $commit_id_filename = "commit_id.txt"
    if (-Not (Test-Path $commit_id_filename) -or
        (Get-Content $commit_id_filename | Where-Object { $_ -ne $VcpkgCommitSha })) {
        # Sha does not match or does not exist.
        Write-Output "Dependencies have changed. Bootstrapping and updating vcpkg."
        run_command ".\bootstrap-vcpkg.bat"

        # Remove any outdated libraries before installing
        run_command ".\vcpkg remove --outdated --recurse"

        # Update the SHA we last saw
        Set-Content -Path $commit_id_filename -Value $VcpkgCommitSha
    }

    # Build the triplet flag e.g. --triplet "x64-windows"
    $triplet = "--triplet `""
    $triplet += $VcpkgTriplet
    $triplet += '"'

    $libs_list = ""

    # mpg123 on x64-windows requires x86-windows yasm-tool.
    # https://github.com/microsoft/vcpkg/issues/15890
    if ($VcpkgTriplet -eq "x64-windows") {
        $yasm_tool_install = ".\vcpkg install yasm-tool:x86-windows"
        run_command -command $yasm_tool_install
    }

    # Build our libs list
    foreach ($library in $corsixth_libs) {
        $libs_list += $library + ' '
    }

    # If we are building the animation viewer be sure to include those libs
    if ($BuildAnimView) {
        foreach ($library in $anim_view_libs) {
            $libs_list += $library + ' '
        }
    }

    # Compile them locally
    $install_command = ".\vcpkg install " + $triplet + $libs_list
    run_command -command $install_command

    # Copy various files from bin to tools
    $vcpkg_installed_path = ".\installed\"
    $vcpkg_installed_path += $VcpkgTriplet

    Set-Location $vcpkg_installed_path

    Write-Output "Copying files from bin to tools"

    $files_to_copy_from_bin = "lfs.dll", "lpeg.dll"
    foreach ($file in $files_to_copy_from_bin) {
        Copy-Item -Path ".\bin\$file" -Destination ".\tools\lua"
    }

    Write-Output "Finished building libraries"
}

# Run the script
$starting_dir = Convert-Path .
try {
    run_script
    # Move back up a dir to return user to original location
    Set-Location -Path $starting_dir
}
catch [Exception] {
    Set-Location -Path $starting_dir
    # Echo the exception back out
    $_
    Exit -1
}

#!/bin/bash

# EMBA - EMBEDDED LINUX ANALYZER
#
# Copyright 2020-2023 Siemens Energy AG
#
# EMBA comes with ABSOLUTELY NO WARRANTY. This is free software, and you are
# welcome to redistribute it under the terms of the GNU General Public License.
# See LICENSE file for usage of this software.
#
# EMBA is licensed under GPLv3
#
# Author(s): Michael Messner

# Description:  Installs fwhunt-scan including rules
#               fwhunt-scan https://github.com/binarly-io/fwhunt-scan
#               fwhunt rules https://github.com/binarly-io/FwHunt

I02_UEFI_fwhunt() {
  module_title "${FUNCNAME[0]}"

  if [[ "$LIST_DEP" -eq 1 ]] || [[ $IN_DOCKER -eq 1 ]] || [[ $DOCKER_SETUP -eq 0 ]] || [[ $FULL -eq 1 ]]; then

    print_tool_info "meson" 1
    print_tool_info "python3-pip" 1
    print_tool_info "gcc" 1
    print_pip_info "rzpipe"
    print_pip_info "uefi_firmware"
    print_pip_info "pyyaml"
    print_pip_info "click"
    print_git_info "rizin" "rizinorg/rizin" ""
    print_git_info "fwhunt-scan" "EMBA-support-repos/fwhunt-scan" "Tools for analyzing UEFI firmware and checking UEFI modules with FwHunt rules."
    print_git_info "fwhunt-rules" "EMBA-support-repos/FwHunt" "The Binarly Firmware Hunt (FwHunt) rule format was designed to scan for known vulnerabilities in UEFI firmware."
    print_git_info "BIOSUtilities" "EMBA-support-repos/BIOSUtilities" "Various BIOS Utilities for Modding/Research"
  
    if [[ "$LIST_DEP" -eq 1 ]] || [[ $DOCKER_SETUP -eq 1 ]] ; then
      ANSWER=("n")
    else
      echo -e "\\n""$MAGENTA""$BOLD""These applications (if not already on the system) will be downloaded!""$NC"
      ANSWER=("y")
    fi
  
    case ${ANSWER:0:1} in
      y|Y )
  
        pip3 install rzpipe 2>/dev/null
        pip3 install click 2>/dev/null
        pip3 install pyyaml 2>/dev/null
        pip3 install uefi_firmware 2>/dev/null

        # rizin:
        apt-get install "${INSTALL_APP_LIST[@]}" -y --no-install-recommends
        echo -e "$ORANGE""$BOLD""Installing rizin""$NC"
        if [[ -d external/rizin ]]; then
          rm -r external/rizin
        fi
        git clone https://github.com/rizinorg/rizin.git external/rizin
        cd external/rizin || ( echo "Could not install EMBA component rizin" && exit 1 )
        meson build
        ninja -C build
        ninja -C build install
        cd "$HOME_PATH" || ( echo "Could not install EMBA component rizin" && exit 1 )

        # BIOSUtilities
        echo -e "$ORANGE""$BOLD""Installing BIOSUtilities""$NC"
        if [[ -d external/BIOSUtilities ]]; then
          rm -r external/BIOSUtilities
        fi
        git clone https://github.com/EMBA-support-repos/BIOSUtilities.git external/BIOSUtilities

        echo -e "$ORANGE""$BOLD""Installing FwHunt""$NC"
        if [[ -d external/fwhunt-scan ]]; then
          rm -r external/fwhunt-scan
        fi
        git clone https://github.com/EMBA-support-repos/fwhunt-scan.git external/fwhunt-scan
        cd external/fwhunt-scan || ( echo "Could not install EMBA component fwhunt-scan" && exit 1 )
        git clone https://github.com/EMBA-support-repos/FwHunt.git rules
        echo "Installed $(find rules/ -iname "BRLY-*" | wc -l) fwhunt rules"
        # ldconfig
        # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib64/
        # python3 setup.py install
        pip3 install fwhunt-scan
        cd "$HOME_PATH" || ( echo "Could not install EMBA component fwhunt-scan" && exit 1 )
      ;;
    esac
  fi
} 

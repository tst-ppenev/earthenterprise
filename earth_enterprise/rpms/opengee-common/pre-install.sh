#!/bin/bash
#
# Copyright 2018 the Open GEE Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# OSPackage hard-codes the interpreter to `/bin/sh` for Debian systems, so make
# sure this scripts runs in `sh`, even if you specify `bash` above.

set +x
set -e

#------------------------------------------------------------------------------
check_group()
{
    local GROUP_EXISTS=$(getent group "$GEGROUP")

    # Add group if it does not exist:
    if [ -z "$GROUP_EXISTS" ]; then
        groupadd -r "$GEGROUP" &> /dev/null
    fi
}

is_directory_not_link()
{
    [ -d "$1" ] && [ ! -L "$1" ]
}

remove_nonlink_directory()
{
    if is_directory_not_link "$1"; then
        # A little extra protection so it will only do rm -rf in certain cases
        if [ "1" = "$2" ]; then
            rm -rf "$1"
        else
            rmdir "$1"
        fi
    fi
}

remove_nonlink_directories()
{
    remove_nonlink_directory "$BASEINSTALLDIR_OPT/etc"
    remove_nonlink_directory "$BASEINSTALLDIR_OPT/log"
    remove_nonlink_directory "$BASEINSTALLDIR_OPT/run"
    remove_nonlink_directory "$BASEINSTALLDIR_OPT/gehttpd/htdocs/shared_assets/docs" 1
}

#-----------------------------------------------------------------
# Main Function
#-----------------------------------------------------------------
# 8) Check if group and users exist

check_group

# On Red Hat, only if we are going to install, remove some directories in the
# pre-install stage, so cpio can carry group name if needed.  Skip on upgrade.
if [ "$1" != "1" ]; then
    remove_nonlink_directories
fi
#-----------------------------------------------------------------

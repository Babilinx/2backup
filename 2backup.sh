#!/usr/bin/env bash

# 2backup (btrfs backup), a simple snapshots management and backup tool for btrfs.
# Copyright (C) 2023  Babilinx
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.



usage() {
cat << EOF
2backup  Copyright (C) 2023  Babilinx
This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it
under certain conditions; see 'https://www.gnu.org/licenses/gpl-3.0.en.html' for details.

Usage:
  2backup [options] [arguments]
  bb [options] [arguments]

Options:
  profile                                      Interact with profiles.
    arguments:
      create <profile>                         Create a profile.
      delete <profile>                         Delete a profile.
      list                                     List all profiles.
      show <profile>                           Show infos of a profile.

  snapshots                                    Interact with snapshots.
    arguments:
      create <profile>                         Create a snapshot of a profile, with the description given after.
      create <profile> -m <description>        Create a snapshot of a profile with the giver description.
      delete <snapshot ID> -p <profile>        Delete a profile's snapshot (can contain more than one snapshot).
      delete <snapshot hash>                   Delete a given snapshot.
      list                                     List all snapshots.
      list -p <profile>                        List all snapshots of a profile.
      show <snapshot hash>                     Show infos on a snapshot.
      show <snapshot ID> -p <profile>          Show infos on a snapshot of a profile.
      mount <snapshot ID> -p <profile>         Mount a snapshot of a profile.
      mount <snapshot hash>                    Mount a given snapshot.
      umount <snapshot ID> -p <profile>        Unmount a snapshot of a profile.
      umount <snapshot hash>                   Unmount a given snapshot.

  rollback                                     Do rollback stuff.
    arguments:
      <snapshot hash>                          Rollback the given snapshot.
      <snapshot ID> -p <profile>               Rollback a profile to the given snapshot.

EOF
}


init() {
    [ ! -d "/etc/2backup" ] && mkdir /etc/2backup
    [ ! -d "/etc/2backup/profiles" ] && mkdir /etc/2backup/profiles
}


profile_create() {
    if [[ ! "$1" == "" ]]; then
        PROFILE="$1"
        cat > /etc/2backup/profiles/$PROFILE << "EOF"
SUBV=("@default1" "@default2")

TIMELINE_LIMIT_HOURLY="0"
TIMELINE_LIMIT_DAILY="0"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="0"
TIMELINE_LIMIT_YEARLY="0"
EOF
        echo "Profile '$PROFILE' created. Configure it at '/etc/2backup/profiles/$PROFILE'."
        exit

    else
        >&2 echo "Profile name can't be blank!"
        exit 1
    fi
}


profile_delete() {
    PROFILE="$1"

    if [ -e "/etc/2backup/profiles/$PROFILE" ]; then
        read -p "Do you really want to delete profile '$PROFILE'? [y/N] " ASK

        if [[ "$ASK" == "y" || "$ASK" == "Y" ]]; then
            rm /etc/2backup/profiles/$PROFILE
            echo "Profile '$PROFILE' as been deleted."
            exit
        else
            echo "Deletion aborted."
            exit
        fi
    else
        >&2 echo "Profile '$PROFILE' do not exist!"
        exit 1
    fi
}


main() {
    echo

    for i in "$@"; do
        case $i in

            profile)
                OPTION="profile"
                shift
                ;;

            subvolume)
                OPTION="subvolume"
                shift
                ;;

            rollback)
                OPTION="rollback"
                OBJECT="$2"
                shift; shift
                ;;

            create)
                create=true
                OBJECT="$2"
                shift; shift
                ;;

            delete)
                delete=true
                OBJECT="$2"
                shift; shift
                ;;

            list)
                list=true
                shift
                ;;

            show)
                show=true
                OBJECT="$2"
                shift; shift
                ;;

            mount)
                mount=true
                OBJECT="$2"
                shift; shift
                ;;

             umount)
                umount=true
                OBJECT="$2"
                shift; shift
                ;;

            -p)
                PROFILE="$2"
                shift; shift
                ;;

            -m)
                MESSAGE="$2"
                shift; shift
                ;;

            -h|--help)
                usage
                exit
                ;;

#            *)
#                >&2 echo "Unknown option $1"
#                exit 1
#                ;;

        esac
    done

    case $OPTION in

        profile)
            if [[ "$create" == true ]]; then
                profile_create $OBJECT
            elif [[ "$delete" == true ]]; then
                profile_delete $OBJECT
            elif [[ "$show" == true ]]; then
                profile_show $OBJECT
            elif [[ "$list" == true ]]; then
                profile_list
            else
                >&2 echo "Unknown argument(s): $ARGS"
                >&2 echo "See -h|--help."
                exit 1
            fi
            ;;

        snapshot)
            if [[ "$create" == true ]]; then
                snapshot_create $OBJECT $DESCRIPTION
            elif [[ "$delete" == true ]]; then
                snapshot_delete $OBJECT $PROFILE
            elif [[ "$show" == true ]]; then
                snapshot_show $OBJECT $PROFILE
            elif [[ "$list" == true ]]; then
                snapshot_list $PROFILE
            elif [[ "$mount" == true ]]; then
                snapshot_mount $OBJECT $PROFILE
            elif [[ "$umount" == true ]]; then
                snapshot_umount $OBJECT $PROFILE
            else
                >&2 echo "Unknown argument(s): $ARGS"
                >&2 echo "See -h|--help."
                exit 1
            fi
            ;;

        rollback)
            rollback $OPTIONS $PROFILE
            ;;

    esac

}

ARGS="$@"
init
main $ARGS

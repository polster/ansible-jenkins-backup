#!/bin/bash -xe
#
# {{ ansible_managed }}
#
##########################################################################
#
# Script used to backup/archive Jenkins configuration.
#
# Author: Simon Dietschi
# Inception year: 2015
#
##########################################################################

# Default variables, may be overridden by external env vars
JENKINS_HOME={{ ansible_jenkins_backup_jenkins_home }}
DEST_FILE={{ ansible_jenkins_backup_dir }}/{{ ansible_jenkins_backup_file_name }}
WORK_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
TMP_DIR="$WORK_DIR/tmp"
ARC_NAME="jenkins-config-backup"
ARC_DIR="$TMP_DIR/$ARC_NAME"
TMP_TAR_NAME="$TMP_DIR/archive.tar.gz"

usage()
{
    cat <<EOF

usage: $0 options

This script creates a back-up of the current Jenkins config.

OPTIONS:
   -h    Show this message
   -j    Jenkins home
   -d    The destination file (including the path)
EOF
}

while getopts "h:d:j:" OPTION
do
    echo "Option is: $OPTION"
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        j)
            JENKINS_HOME=$OPTARG
            ;;
        d)
            DEST_FILE=$OPTARG
            ;;
        ?)
            echo "Illegal argument $OPTION=$OPTARG" >&2
            usage
            exit
            ;;
    esac
done

if [ -z "$JENKINS_HOME" -o -z "$DEST_FILE" ] ; then
  usage >&2
  exit 1
fi

rm -rf "$ARC_DIR" "$TMP_TAR_NAME"
mkdir -p "$ARC_DIR/"{plugins,jobs,users,secrets}

cp "$JENKINS_HOME/"*.xml "$ARC_DIR"

cp "$JENKINS_HOME/plugins/"*.[hj]pi "$ARC_DIR/plugins"
hpi_pinned_count=$(find $JENKINS_HOME/plugins/ -name *.hpi.pinned | wc -l)
jpi_pinned_count=$(find $JENKINS_HOME/plugins/ -name *.jpi.pinned | wc -l)
if [ $hpi_pinned_count -ne 0 -o $jpi_pinned_count -ne 0 ]; then
  cp "$JENKINS_HOME/plugins/"*.[hj]pi.pinned "$ARC_DIR/plugins"
fi

if [ -d "$JENKINS_HOME/users/" ] ; then
  cp -R "$JENKINS_HOME/users/"* "$ARC_DIR/users"
fi

if [ -d "$JENKINS_HOME/secrets/" ] ; then
  cp -R "$JENKINS_HOME/secrets/"* "$ARC_DIR/secrets"
fi

if [ -d "$JENKINS_HOME/jobs/" ] ; then
  cd "$JENKINS_HOME/jobs/"
  ls -1 | while read job_name ; do
    mkdir -p "$ARC_DIR/jobs/$job_name/"
    find "$JENKINS_HOME/jobs/$job_name/" -maxdepth 1 -name "*.xml" | xargs -I {} cp {} "$ARC_DIR/jobs/$job_name/"
  done
fi

cd "$TMP_DIR"
tar -czvf "$TMP_TAR_NAME" "$ARC_NAME/"*
mv -f "$TMP_TAR_NAME" "$DEST_FILE"
rm -rf "$ARC_DIR"

exit 0

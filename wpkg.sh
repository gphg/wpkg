#!/usr/bin/env sh

CURRENT_DIR=$(readlink -m $(dirname $0))

# default packages file if not given via ENVIRONMENT
if [ -z "$WGET_PACKAGES_FILE" ] ; then
    WGET_PACKAGES_FILE=$(readlink -m "${CURRENT_DIR}/package.txt")
fi

echo "[INFO] Downloading packages listed in:" $WGET_PACKAGES_FILE

# remove lines with comments from the packages file
TEMPFILE=$(mktemp)
grep -v -e"^$" -e"^\s*#" $WGET_PACKAGES_FILE > $TEMPFILE

__verify() {
    local _file="$1"
    local _func=$(echo "$2" | cut -d':' -f1)
    case $_func in
        md5) md5sum $_file
            ;;
        sha1) sha1sum $_file
            ;;
        sha224) sha224sum $_file
            ;;
        sha256) sha256sum $_file
            ;;
        sha384) sha384sum $_file
            ;;
        sha512) sha512sum $_file
            ;;
        *) return 1
            ;;
    esac
    return 0
}

# per line: download file to target path and check sha1 checksum
while read -r URL FILE HASH
do
    HASH_SUM=$(echo "$HASH" | cut -d':' -f2)

    # validation (haha)
    if [ $URL = $FILE ] ; then
        echo "[ERROR] Invalid wget download instruction. URL and filename are the same:" $LINE
        continue
    fi
    if [ $FILE = $HASH ] ; then
        echo "[ERROR] Invalid wget download instruction. Filename and checksum are the same:" $LINE
        continue
    fi
    if [ $URL = $HASH ] ; then
        echo "[ERROR] Invalid wget download instruction. Sha1 value the same as the URL:" $LINE
        continue
    fi

    # check if local file already exists and has the correct checksum
    if [ -f $FILE ] ; then
        CHECKSUM=$(__verify "$FILE" "$HASH" | cut -d' ' -f1)
        if [ "$CHECKSUM" = "$HASH_SUM" ] ; then
            echo "[SUCCESS] File already downloaded correctly:" $FILE
            continue
        else
            echo "[INFO] File checksum mismatch. Fetching file:" $FILE
        fi
    fi

    # download file
    wget --continue -O $FILE -- $URL
    if [ $? -ne 0 ]; then
        echo "[ERROR] Download failed from:" $URL
    fi

    # verify downloaded file
    echo "[INFO] Calculating checksum for file:" $FILE
    CHECKSUM=$(__verify "$FILE" "$HASH" | cut -d' ' -f1)
    if [ "$CHECKSUM" = "$HASH_SUM" ] ; then
        echo "[SUCCESS] Download succesful:" $FILE
    else
        echo "[ERROR] Checksum error for downloaded file:" $FILE
        echo "[ERROR] Expected   =>" $HASH_SUM
        echo "[ERROR] Calculated =>" $CHECKSUM
    fi
done < $TEMPFILE

rm $TEMPFILE

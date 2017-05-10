#!/usr/bin/env bash
NEWFILE=$(mktemp -d "${TMPDIR:-/tmp/}backup_atom.XXXXXXXXXXXX")/tmpfile.txt
EXTENSIONS_FILE=$DOTFILES/atom/atom-extensions.txt

echo "***Launching Atom backup utility***"
if [ ! -f $EXTENSIONS_FILE ]; then
    apm list --installed --bare | tr '\n' ' ' > $EXTENSIONS_FILE
    echo "Backup file created"
    exit 0
fi
apm list --installed --bare | tr '\n' ' ' > $NEWFILE
RESULT=$(diff --ignore-all-space --brief $NEWFILE $EXTENSIONS_FILE)
if [[ $RESULT ]]; then
    NOW=$(date +"%Y%m%d%H%M%S")
    mv $EXTENSIONS_FILE $DOTFILES/atom/atom-extensions_backup_$NOW.txt
    mv $NEWFILE $EXTENSIONS_FILE
    # Delete all but the 5 most recent backups
    \ls -t | grep backup | tail -n +6 | xargs -I {} rm -- {}
    echo "Done"
    exit 0
else
    rm $NEWFILE
    echo "Everything is up to date"
    exit 0
fi
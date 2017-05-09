#! /bin/bash
NEWFILE=$(mktemp -d "${TMPDIR:-/tmp/}backup_vscode.XXXXXXXXXXXX")/tmpfile.txt
EXTENSIONS_FILE=$DOTFILES/vscode/vscode-extensions.txt

echo "***Launching VSCode backup utility***"
if [ ! -f $EXTENSIONS_FILE ]; then
    /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --list-extensions | tr '\n' ' ' > $EXTENSIONS_FILE
    echo "Backup file created"
    exit 0
fi
/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code --list-extensions | tr '\n' ' ' > $NEWFILE
RESULT=$(diff --ignore-all-space --brief $NEWFILE $EXTENSIONS_FILE)
if [[ $RESULT ]]; then
    NOW=$(date +"%Y%m%d%H%M%S")
    mv $EXTENSIONS_FILE $DOTFILES/vscode/vscode-extensions_backup_$NOW.txt
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
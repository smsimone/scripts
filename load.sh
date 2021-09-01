### Loads all the scripts contained in this folder

to_load=($(find . -name "*.sh" | grep -e "[^./load.sh]"))
for script in $to_load; do
    source $script
done

# Initial unload
if [ -d "KIF/Mods/998_Mods" ]; then
    rm -rf "KIF/Mods/998_Mods"
    echo "Cleared old mods dir"
fi
# Initial unload (last)
if [ -d "KIF/Mods" ]; then
    if ls KIF/Mods/z_* 1> /dev/null 2>&1; then
        rm -rf KIF/Mods/z_*
        echo "Cleared old z_* dirs"
    fi
fi

# Load last mods
if compgen -G "Mods/Load_Last/*" > /dev/null; then
    for mod in Mods/Load_Last/*; do
        echo "Found item: $mod"
        if [ -e "$mod" ]; then
            mod_name=$(basename "$mod")
            cp -r "$mod" "KIF/Mods/z_$mod_name"
        else
            echo "Skipping item: $mod"
        fi
    done
else
    echo "No items found in Mods/Load_Last/"
fi


# Load initial mods
mkdir -p "KIF/Mods/998_Mods"
find Mods -maxdepth 1 -mindepth 1 ! -name 'Load_Last' -exec cp -r {} KIF/Mods/998_Mods/ \;
# cp -r vendor "KIF/Mods/998_Mods/vendor"  # Copy vendor dependencies into the Mods folder

echo "Imported mods"

echo "Running game..."
wine KIF/Game.exe

# Final unload
if [ -d "KIF/Mods/998_Mods" ]; then
    rm -rf "KIF/Mods/998_Mods"
    echo "Cleared old mods dir"
fi
# Final unload (last)
if [ -d "KIF/Mods" ]; then
    if ls KIF/Mods/z_* 1> /dev/null 2>&1; then
        rm -rf KIF/Mods/z_*
        echo "Cleared old z_* dirs"
    fi
fi
# Initial unload
if [ -d "PIF/Data/Scripts/998_Mods" ]; then
    rm -rf "PIF/Data/Scripts/998_Mods"
    echo "Cleared old mods dir"
fi
# Initial unload (last)
if [ -d "PIF/Data/Scripts" ]; then
    if ls PIF/Data/Scripts/z_* 1> /dev/null 2>&1; then
        rm -rf PIF/Data/Scripts/z_*
        echo "Cleared old z_* dirs"
    fi
fi

# Load last mods
if compgen -G "Mods/Load_Last/*" > /dev/null; then
    for mod in Mods/Load_Last/*; do
        echo "Found mod: $mod"
        if [ -e "$mod" ]; then
            mod_name=$(basename "$mod")
            cp -r "$mod" "PIF/Data/Scripts/z_$mod_name"
        else
            echo "Skipping mod: $mod"
        fi
    done
else
    echo "No items found in Mods/Load_Last/"
fi

# Load ModData
if compgen -G "Mods/ModData/*" > /dev/null; then
    mkdir -p "PIF/ModData"
    for data in Mods/ModData/*; do
        echo "Found mod data: $data"
        if [ -e "$data" ]; then
            data_name=$(basename "$data")
            cp -r "$data" "PIF/ModData/$data_name"
        else
            echo "Skipping mod data: $data"
        fi
    done
else
    echo "No items found in Mods/ModData"
fi


# Load initial mods
mkdir -p "PIF/Data/Scripts/998_Mods"
find Mods -maxdepth 1 -mindepth 1 ! -name 'Load_Last' ! -name 'ModData' ! -name 'Release' -exec cp -r {} PIF/Data/Scripts/998_Mods/ \;
# cp -r vendor "PIF/Data/Scripts/998_Mods/vendor"  # Copy vendor dependencies into the Mods folder

echo "Imported mods"

echo "Running game..."
wine PIF/Game.exe

# Final unload
if [ -d "PIF/Data/Scripts/998_Mods" ]; then
    rm -rf "PIF/Data/Scripts/998_Mods"
    echo "Cleared old mods dir"
fi

# Final unload (last)
if [ -d "PIF/Data/Scripts" ]; then
    if ls PIF/Data/Scripts/z_* 1> /dev/null 2>&1; then
        rm -rf PIF/Data/Scripts/z_*
        echo "Cleared old z_* dirs"
    fi
fi

# Final unload (mod data)
if [ -d "PIF/ModData" ]; then
    rm -rf "PIF/ModData"
    echo "Cleared old mod data"
fi
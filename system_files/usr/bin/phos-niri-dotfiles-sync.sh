#!/bin/bash

USER_CONFIG="$HOME/.config"
SYS_DEFAULTS="/usr/share/phos-niri/dotfiles"

# Assicuriamoci che la cartella .config esista
mkdir -p "$USER_CONFIG"

# Funzione per aggiungere in modo sicuro la stringa di avvio in config.kdl se manca
add_noctalia_to_niri() {
    local niri_config="$USER_CONFIG/niri/config.kdl"
    
    # Se il file config.kdl non esiste per qualche motivo, lo copiamo dal sistema
    if [ ! -f "$niri_config" ]; then
        mkdir -p "$USER_CONFIG/niri"
        cp "$SYS_DEFAULTS/niri/config.kdl" "$niri_config"
        return
    fi

    # Controlla se noctalia è già menzionato nello spawn-at-startup
    if grep -q "noctalia" "$niri_config"; then
        echo "Noctalia già configurato in Niri."
        return
    fi

    # Logica di inserimento in config.kdl:
    # Cerchiamo il blocco spawn-at-startup. Se è compatto tipo spawn-at-startup "programma",
    # o se è un blocco multilinea, inseriamo la stringa.
    if grep -q "spawn-at-startup {" "$niri_config"; then
        # Caso blocco multilinea: inserisce "noctalia" subito dopo l'apertura della graffa
        sed -i '/spawn-at-startup {/a \    "noctalia"' "$niri_config"
    else
        # Caso blocco assente o singolo: lo appendiamo in fondo al file in modo pulito
        echo -e "\nspawn-at-startup {\n    \"noctalia\"\n}" >> "$niri_config"
    fi
}

# --- LOGICA DEI CASI COMPLESSI ---

# Scenario 2.1 & 2.4: Se non esistono né niri né noctalia
if [ ! -d "$USER_CONFIG/niri" ] && [ ! -d "$USER_CONFIG/noctalia" ]; then
    echo "Nessun dotfile trovato. Copio i default di sistema..."
    cp -r "$SYS_DEFAULTS/niri" "$USER_CONFIG/"
    cp -r "$SYS_DEFAULTS/noctalia" "$USER_CONFIG/"

# Scenario 2.2: Esiste Niri ma non Noctalia
elif [ -d "$USER_CONFIG/niri" ] && [ ! -d "$USER_CONFIG/noctalia" ]; then
    echo "Rilevato Niri ma manca Noctalia. Integro la configurazione..."
    cp -r "$SYS_DEFAULTS/noctalia" "$USER_CONFIG/"
    add_noctalia_to_niri

# Scenario 2.3: Esistono entrambi, verifichiamo solo lo spawn
elif [ -d "$USER_CONFIG/niri" ] && [ -d "$USER_CONFIG/noctalia" ]; then
    echo "Entrambi i dotfile presenti. Verifico l'autostart di Noctalia..."
    add_noctalia_to_niri
fi

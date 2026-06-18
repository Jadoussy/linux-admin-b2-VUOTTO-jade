#!/bin/bash
# ============================================================
# Script  : logwatcher.sh
# Auteur  : Vuotto Jade
# Date    : 2026-06-18
# Desc    : Surveillance des tentatives de connexion SSH
# Usage   : Lancé par le service systemd logwatcher.service
# ============================================================

# === Variables ===============================================
AUTH_LOG="/var/log/auth.log"        # adapter si /var/log/secure (RHEL)
LOG_DIR="/var/log/logwatcher"
LOG_FILE="$LOG_DIR/activity.log"
INTERVAL=30                         # secondes entre chaque cycle
SEUIL=5                             # seuil d'alerte


# === Initialisation ==========================================
# Créer LOG_DIR si absent (mkdir -p)
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi

# Compteur de base (nombre de lignes au démarrage) : compte ce qui existe déjà pour ne pas déjà déclencher l'alerte
if [ -f "$AUTH_LOG" ]; then
    LAST_COUNT=$(grep -E "Failed password|Invalid user" "$AUTH_LOG" | wc -l)
else  
    LAST_COUNT=0
fi

# === Boucle principale =======================================
while true; do

    TIMESTAMP=$(date '+%H:%M:%S')
    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    # Compte le nombre de tentatives
    if [ -f "$AUTH_LOG" ]; then
        TOTAL=$(grep -E "Failed password|Invalid user" "$AUTH_LOG" | wc -l)
    else  
        TOTAL=0
    fi

    # Calcule le nombre de NOUVELLES tentatives depuis le cycle précédent
    NOUVELLES=$((TOTAL - LAST_COUNT))

    # Mettre à jour le compteur de référence
    LAST_COUNT=$TOTAL

    # Ecrit dans journal :
    echo  "[LOGWATCHER] $NOUVELLES tentative(s) SSH échouée(s) — $TIMESTAMP"

    # Si NOUVELLES > SEUIL, écrire un message d'alerte dans journald
    if [ "$NOUVELLES" -gt "$SEUIL" ]; then
        echo "[LOGWATCHER][ALERTE] Pic suspect : $NOUVELLES" >&2
    fi

    # EcriT dans LOG_FILE :
    echo "$DATE | Nouvelles: $NOUVELLES | Total: $TOTAL" >> "$LOG_FILE"

    sleep $INTERVAL

done

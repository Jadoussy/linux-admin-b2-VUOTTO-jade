#!/bin/bash
# ============================================================
# Script  : harden_ssh.sh
# Auteur  : Vuotto Jade
# Date    : 2026-06-18
# Desc    : Durcissement de la configuration SSH
# Usage   :     chmod +x harden_ssh.sh
#               sudo ./scripts/harden_ssh.sh
# ⚠  IMPORTANT : Ayez une deuxième session SSH ouverte
#                avant d'exécuter ce script !
# ============================================================

# === Vérification root =======================================
# Si le script n'est pas lancé (-ne) en root : 
if [ "$EUID" -ne 0 ]; then
    # Alors, on affiche un message d'erreur et quitte 
    echo "Le script doit être exécuté avec sudo (privilèges)" >&2
    exit 1
fi

# === Variables ===============================================
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="$SSHD_CONFIG.bak.$(date +%Y%m%d)"


# === Sauvegarde ==============================================
echo "[INFO] Sauvegarde de $SSHD_CONFIG → $BACKUP"

# copier sshd_config vers $BACKUP
cp "$SSHD_CONFIG" "$BACKUP"



# === Fonction de restauration ================================
restore_and_exit() {
    echo "[ERREUR] La configuration SSH est invalide." >&2
    echo "[INFO] Restauration de la sauvegarde..." >&2

    # Restaure $BACKUP vers $SSHD_CONFIG
    cp "$BACKUP" "$SSHD_CONFIG"

    echo "[INFO] Sauvegarde restaurée. Aucune modification appliquée." >&2
    exit 1
}


# === Application des directives ==============================
# Fonction utilitaire : modifier ou ajouter une directive dans sshd_config
set_directive() {
    local key="$1"
    local value="$2"

    # Vérifie si la clé n'existe pas déjà
    if grep -qE "^#? *${key} " "$SSHD_CONFIG"; then
        # Remplace la ligne existante par la nouvelle clé/valeur propre
        sed -i -E "s/^#? *${key} .*/${key} ${value}/" "$SSHD_CONFIG"
    else
        # Sinon (= la clé n'existe pas du tout), elle est rajoutée à la fin du fichier
        echo "${key} ${value}" >> "$SSHD_CONFIG"
    fi
}

echo "[INFO] Application des directives de sécurité..."

# Appeler set_directive pour chaque paramètre :
set_directive "PermitRootLogin" "no"
set_directive "PasswordAuthentication" "no"
set_directive "PubkeyAuthentication" "yes"
set_directive "MaxAuthTries" "3"
set_directive "LoginGraceTime" "20"
set_directive "ClientAliveInterval" "300"
set_directive "ClientAliveCountMax" "2"
set_directive "X11Forwarding" "no"

# === Validation ==============================================
echo "[INFO] Validation de la syntaxe..."

# Si le code retour est non nul, appeler restore_and_exit
if ! sshd -t; then
    restore_and_exit
fi     

# === Résumé des modifications ================================
echo ""
echo "============================================================"
echo " Modifications appliquées (diff)"
echo "============================================================"
# Affiche le diff entre $BACKUP et $SSHD_CONFIG
diff "$BACKUP" "$SSHD_CONFIG" || true
# true évite que le script s'arrète brutalement si le diff détecte des changements



# === Message final ===========================================
echo ""
echo "============================================================"
echo " ✅ Configuration validée — sshd NON redémarré"
echo "============================================================"
echo " Vérifiez votre connexion SSH depuis un autre terminal,"
echo " puis redémarrez manuellement avec :"
echo "   sudo systemctl restart ssh"
echo "============================================================"

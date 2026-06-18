#!/bin/bash
# ============================================================
# Script  : setup_project.sh
# Auteur  : Vuotto Jade
# Date    : 2026-06-18
# Desc    : Mise en place de l'espace de travail partagé
# Usage   : sudo ./scripts/setup_project.sh
# Note    : Exécuter après create_users.sh
# ============================================================

# === Vérification root =======================================
# Si le script n'est pas lancé (-ne) en root : 
if [ "$EUID" -ne 0 ]; then
    # Alors, on affiche un message d'erreur et quitte 
    echo "Le script doit être exécuté avec sudo (privilèges)" >&2
    exit 1
fi


# === Variables ===============================================
BASE_DIR="/srv/devproject"
GROUPE_DEV="devteam"

USER_ACL="charlie"


# === Création de l'arborescence ==============================

# Création du dossier "devproject" (chemin:"/srv/devproject") et ses sous dossiers (src,docs,releases,logs)
mkdir -p "$BASE_DIR"/{src,docs,releases,logs}


# === Propriétaires et permissions ============================

# Configuration pour :  src/      → root:devteam, 770
chown root:"$GROUPE_DEV" "$BASE_DIR/src"
chmod 770 "$BASE_DIR/src"

# Configuration pour :  docs/     → root:devteam, 770
chown root:"$GROUPE_DEV" "$BASE_DIR/docs"
chmod 770 "$BASE_DIR/docs"

# Configuration pour :  releases/ → root:devteam, 750
chown root:"$GROUPE_DEV" "$BASE_DIR/releases"
chmod 750 "$BASE_DIR/releases"

# Configuration pour :  logs/     → root:root,    700
chown root:root "$BASE_DIR/logs"
chmod 700 "$BASE_DIR/logs"

# === Bits spéciaux ===========================================
echo -e "\n--- Bits spéciaux (sticky bit et SGID) ---"

# g+s : active le SGID (tout fichier créé dans "src/" et "docs/" va hériter automatiquement du grp devteam) 
# o+t : active le sticky bit (seul le propriétaire du fichier pourra supprimer/renommer ce fichier dans les dossiers "src/" et "docs/")
chmod g+s,o+t "$BASE_DIR/src"
chmod g+s,o+t "$BASE_DIR/docs"

# === ACL pour charlie ========================================
echo -e "\n--- Création d'une ACL pour charlie ---"

# Donne à charlie un accès en lecture (r-x) sur docs/
setfacl -m u:"$USER_ACL":r-x "$BASE_DIR/docs"


# === Fichiers de test ========================================
# TODO : créer un fichier de test dans chaque sous-dossier
echo -e "\n--- Création de fichier de test : s---"

touch "$BASE_DIR/src/test1.txt"
touch "$BASE_DIR/docs/test2.txt"
touch "$BASE_DIR/releases/test3.txt"
touch "$BASE_DIR/logs/test4.txt"

echo "[OK] Les fichiers de test ont été générés."

# === Récapitulatif ===========================================
echo -e "\n============================================================"
echo " Récapitulatif de l'arborescence"
echo "============================================================"

echo -e "\n Permission détaillées de l'arborescence"
ls -laR "$BASE_DIR"

echo -e "\n Permission ACL du dossier docs"
getfacl "$BASE_DIR/docs/"
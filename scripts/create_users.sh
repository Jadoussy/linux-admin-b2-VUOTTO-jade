#!/bin/bash
# ============================================================
# Script  : create_users.sh
# Auteur  : Vuotto Jade
# Date    : 2026-06-18
# Desc    : Création automatisée des comptes équipe dev
# Usage   : sudo ./scripts/create_users.sh
# ============================================================

# === Vérification root =======================================

# Si le script n'est pas lancé (-ne) en root : 
if [ "$EUID" -ne 0 ]; then
    # Alors, on affiche un message d'erreur et quitte 
    echo "Le script doit être exécuté avec sudo (privilèges)" >&2
    exit 1
fi

# === Variables ===============================================
GROUPE_DEV="devteam"        # nom du groupe développeurs
GID_DEV=3001                # GID du groupe développeurs
GROUPE_OPS="ops"            # nom du groupe ops
GID_OPS=3002                # GID du groupe ops

USER1="alice"               # premier utilisateur
UID1=2001                   # son UID
USER2="bob"                 # deuxième utilisateur
UID2=2002
USER3="charlie"             # troisième utilisateur
UID3=2003

PROJET_DIR="/opt/devproject"   # chemin du répertoire projet
MDP_TEMP="ESGIB2_2026"         # mot de passe temporaire (au moins 8 caractères de longueur)

# === Création des groupes ====================================
echo "--- Création des groupes : $GROUPE_DEV & $GROUPE_OPS ---"

# On vérifie que le groupe "devteam" n'existe pas déja avant de le créer (éviter un plantage)
if getent group "$GROUPE_DEV" >/dev/null; then
    echo "$GROUPE_DEV existe déjà."
else
    # Création du groupe "devteam"
    groupadd -g "$GID_DEV" "$GROUPE_DEV"
    echo "groupe créé : $GROUPE_DEV (GID : $GID_DEV)"
fi

# idem pour le groupe "ops"
if getent group "$GROUPE_OPS" >/dev/null; then
    echo "$GROUPE_OPS existe déjà."
else
    groupadd -g "$GID_OPS" "$GROUPE_OPS"
    echo "groupe créé : $GROUPE_OPS (GID : $GID_OPS)"
fi




# === Création des utilisateurs ===============================
# Création des trois utilisateurs avec :
#        - répertoire home (-m)
#        - shell bash (-s /bin/bash)
#        - UID imposé (-u)
#        - groupe primaire imposé (-g)
echo -e "\n--- Création des utilisateurs : $USER1 & $USER2 & $USER3 ---"

# Alice (groupe dev)
# On vérifie que l'utilisateur n'existe pas avant de lancer la création.
if id "$USER1" >/dev/null 2>&1; then
    echo "$USER1 existe déjà."
else
    useradd -m -s /bin/bash -u "$UID1" -g "$GROUPE_DEV" "$USER1"
    echo "Utilisateur créé : $USER1 (UID : $UID1)."
fi

# Bob (groupe dev)
if id "$USER2" >/dev/null 2>&1; then
    echo "$USER2 existe déjà."
else
    useradd -m -s /bin/bash -u "$UID2" -g "$GROUPE_DEV" "$USER2"
    echo "Utilisateur créé : $USER2 (UID : $UID2)."
fi

# Charlie (groupe ops)
if id "$USER3" >/dev/null 2>&1; then
    echo "$USER3 existe déjà."
else
    useradd -m -s /bin/bash -u "$UID3" -g "$GROUPE_OPS" "$USER3"
    echo "Utilisateur créé : $USER3 (UID : $UID3)."
fi

# === Groupes secondaires =====================================
echo -e "\n--- Groupes secondaires ---"

# Ajout du groupe "ops" à alice EN TANT QUE GROUPE SECONDAIRE pour ne pas écraser ses groupes existants
usermod -aG "$GROUPE_OPS" "$USER1"
echo "$USER1 a été ajoutée à : $GROUPE_OPS (GID : $GID_OPS)."

# === Mots de passe temporaires ===============================
echo -e "\n--- Mots de passe temporaires : $MDP_TEMP ---"

# utilisation de la boucle for pour parcourir les 3 utilisateurs pour leur appliquer le MDP temp et sa config
for USER in "$USER1" "$USER2" "$USER3"; do

    # Applique le MDP temporaire à utilisateur parcouru actuellement par la boucle for
    echo "$USER:$MDP_TEMP" | chpasswd 

    # force le changement de MDP à la première connexion (passwd -e)
    chage -d 0 "$USER" 
    echo "MDP temporaire configuré et expiration activée pour $USER ."
done  

# === Répertoire projet =======================================
echo -e "\n--- Répertoire projet : $PROJET_DIR ---"

# S'il n'existe pas déjà (-p), création du répertoire "/opt/devproject/"
mkdir -p "$PROJET_DIR"

# Changement de propriétaire (root) et groupe (devteam)
chown root:"$GROUPE_DEV" "$PROJET_DIR"

# Attribution des droits : 
# propriétaire : rwx (écriture, lecture et exécution) 7
# groupe : rwx (écriture, lecture et exécution) 7
# autres : - (aucun droit) 0
chmod 770 "$PROJET_DIR"

echo "Répertoire $PROJET_DIR configuré (root:$GROUPE_DEV - 770)"


# === Récapitulatif ===========================================
echo ""
echo "============================================================"
echo " Récapitulatif de création"
echo "============================================================"
# Affichage de l'id de chacun des 3 utilisateurs
id "$USER1"
id "$USER2"
id "$USER3"

echo -e "\n--- Information sur le dossier : ---"
# Affichage des info et droits du dossier (-d) "devproject" (chemin:"/opt/devproject")
ls -ld "$PROJET_DIR"
echo "============================================================"
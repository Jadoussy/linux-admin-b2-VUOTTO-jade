# Rapport Mission 2 – Gestion des utilisateurs & groupes

**Auteur :** Vuotto Jade 
**Date :** 2026-06-18
**Distribution :** Ubuntu (version 24.04.4 LTS)

---

## 1. Exécution du script

```bash
sudo ./scripts/create_users.sh
```

**Sortie :**

```
sudo ./create_users.sh 
--- Création des groupes : devteam & ops ---
groupe créé : devteam (GID : 3001)
groupe créé : ops (GID : 3002)

--- Création des utilisateurs : alice & bob & charlie ---
Utilisateur créé : alice (UID : 2001).
Utilisateur créé : bob (UID : 2002).
Utilisateur créé : charlie (UID : 2003).

--- Groupes secondaires ---
alice a été ajoutée à : ops (GID : 3002).

--- Mots de passe temporaires : ESGIB2_2026 ---
MDP temporaire configuré et expiration activée pour alice .
MDP temporaire configuré et expiration activée pour bob .
MDP temporaire configuré et expiration activée pour charlie .

--- Répertoire projet : /opt/devproject ---
Répertoire /opt/devproject configuré (root:devteam - 770)

============================================================
 Récapitulatif de création
============================================================
uid=2001(alice) gid=3001(devteam) groupes=3001(devteam),3002(ops)
uid=2002(bob) gid=3001(devteam) groupes=3001(devteam)
uid=2003(charlie) gid=3002(ops) groupes=3002(ops)

--- Information sur le dossier : ---
drwxrwx--- 2 root devteam 4096 juin  18 10:37 /opt/devproject
============================================================
```

---

## 2. Vérification des comptes créés

```bash
id alice
```

```
uid=2001(alice) gid=3001(devteam) groupes=3001(devteam),3002(ops)
```

```bash
id bob
```

```
uid=2002(bob) gid=3001(devteam) groupes=3001(devteam)
```

```bash
id charlie
```

```
uid=2003(charlie) gid=3002(ops) groupes=3002(ops)
```

---

## 3. Vérification des groupes

```bash
cat /etc/group | grep -E 'devteam|ops'
```

```
whoopsie:x:125:
devteam:x:3001:
ops:x:3002:alice
```

---

## 4. Vérification du répertoire projet

```bash
ls -ld /opt/devproject/
```

```
drwxrwx--- 2 root devteam 4096 juin  18 10:37 /opt/devproject/
```

---

## 5. Analyse : comportement en cas de double exécution

<!-- Expliquer ici ce qui se passe si le script est lancé une deuxième fois.
     Comment avez-vous géré l'idempotence (useradd qui plante si le user existe déjà) ?
     Quelle commande / condition avez-vous utilisée ? -->

Quand on lance le script pour une deuxième fois, on a juste nos messages pré-définis dans le script pour nous dire que l'utilisateur ou groupe existe déjà. Le script est fait pour exécuter les commandes de création seulement si l'utilisateur ou groupe n'existe pas déjà.
L'indempotence est évitée grace aux conditions if (si) qui permettent de vérifier avant de lancer la création de grp ou user.
L'utilisation de la condition **if** avec la commande **getent** qui renvoi 0 si le groupe existe déjà.
Sinon, le résultat de **getent** est autre que 0 (du coup 1 s'il trouve aucun grp/user) alors on peut lancer la commande de création.
***>/dev/null*** permet de masquer la sortie pour garder le cmd clean.

``` Exemple : 
if getent group "$GROUPE_DEV" >/dev/null; then
    # résultat de getent : 0 -> donc le groupe existe déjà
else
     # résultat de getent : 1 -> donc le groupe existe pas, il peut être créé : 
    groupadd -g "$GID_DEV" "$GROUPE_DEV"
fi
```
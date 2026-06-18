# Rapport Mission 3 – Système de fichiers & permissions

**Auteur :** Vuotto Jade 
**Date :** 2026-06-18
**Distribution :** Ubuntu (version 24.04.4 LTS)

---

## 1. Exécution du script

```bash
sudo ./scripts/setup_project.sh
```

**Sortie :**

```
sudo ./setup_project.sh

--- Bits spéciaux (sticky bit et SGID) ---

--- Création d'une ACL pour charlie ---

--- Création de fichier de test : s---
[OK] Les fichiers de test ont été générés.

============================================================
 Récapitulatif de l'arborescence
============================================================

 Permission détaillées de l'arborescence
/srv/devproject:
total 24
drwxr-xr-x  6 root root    4096 juin  18 12:14 .
drwxr-xr-x  4 root root    4096 juin  18 12:14 ..
drwxrws--T+ 2 root devteam 4096 juin  18 12:14 docs
drwx------  2 root root    4096 juin  18 12:14 logs
drwxr-x---  2 root devteam 4096 juin  18 12:14 releases
drwxrws--T  2 root devteam 4096 juin  18 12:14 src

/srv/devproject/docs:
total 8
drwxrws--T+ 2 root devteam 4096 juin  18 12:14 .
drwxr-xr-x  6 root root    4096 juin  18 12:14 ..
-rw-r--r--  1 root devteam    0 juin  18 12:14 test2.txt

/srv/devproject/logs:
total 8
drwx------ 2 root root 4096 juin  18 12:14 .
drwxr-xr-x 6 root root 4096 juin  18 12:14 ..
-rw-r--r-- 1 root root    0 juin  18 12:14 test4.txt

/srv/devproject/releases:
total 8
drwxr-x--- 2 root devteam 4096 juin  18 12:14 .
drwxr-xr-x 6 root root    4096 juin  18 12:14 ..
-rw-r--r-- 1 root root       0 juin  18 12:14 test3.txt

/srv/devproject/src:
total 8
drwxrws--T 2 root devteam 4096 juin  18 12:14 .
drwxr-xr-x 6 root root    4096 juin  18 12:14 ..
-rw-r--r-- 1 root devteam    0 juin  18 12:14 test1.txt

 Permission ACL du dossier docs
getfacl : suppression du premier « / » des noms de chemins absolus
# file: srv/devproject/docs/
# owner: root
# group: devteam
# flags: -st
user::rwx
user:charlie:r-x
group::rwx
mask::rwx
other::---
```

---

## 2. Arborescence après configuration

```bash
ls -laR /srv/devproject/
```

```
total 24
drwxr-xr-x  6 root root    4096 juin  18 12:14 .
drwxr-xr-x  4 root root    4096 juin  18 12:14 ..
drwxrws--T+ 2 root devteam 4096 juin  18 12:14 docs
drwx------  2 root root    4096 juin  18 12:14 logs
drwxr-x---  2 root devteam 4096 juin  18 12:14 releases
drwxrws--T  2 root devteam 4096 juin  18 12:14 src
ls: impossible d'ouvrir le répertoire '/srv/devproject/docs': Permission non accordée
ls: impossible d'ouvrir le répertoire '/srv/devproject/logs': Permission non accordée
ls: impossible d'ouvrir le répertoire '/srv/devproject/releases': Permission non accordée
ls: impossible d'ouvrir le répertoire '/srv/devproject/src': Permission non accordée
```

---

## 3. Vérification des ACL

```bash
getfacl /srv/devproject/docs/
```

```
getfacl : suppression du premier « / » des noms de chemins absolus
# file: srv/devproject/docs/
# owner: root
# group: devteam
# flags: -st
user::rwx
user:charlie:r-x
group::rwx
mask::rwx
other::---
```

---

## 4. Test de validation – utilisateur alice

```bash
su - alice -c "touch /srv/devproject/src/test_alice.txt && ls -l /srv/devproject/src/"
```

```
total 0
-rw-r--r-- 1 root  devteam 0 juin  18 12:14 test1.txt
-rw-r--r-- 1 alice devteam 0 juin  18 12:16 test_alice.txt
```

*Interprétation : Expliquer pourquoi alice **peut**/ne peut pas créer ce fichier, quel groupe est attribué au fichier grâce au SGID. *
Alice peut créer ce fichier car elle appartient au groupe "devteam" et c'est sur le dossier "src/" qui possède les droits : 770.
Le fichier créé est automatiquement attribué au groupe "devteam" (héritage) grace au bit SGID configuré au dossier parent : "src/".


---

## 5. Test de validation – utilisateur charlie

```bash
su - charlie -c "cat /srv/devproject/docs/test2.txt"

```

```

*Interprétation :*
Le fichier est vide c'est pour ça qu'on a aucune réponse du terminal.
Quand j'essaye avec nano (éditeur de fichier dans le terminal), il est indiqué que le fichier n'est pas accéssible en écriture.

*Expliquer pourquoi charlie peut lire ce fichier grâce à l'ACL sans appartenir au groupe devteam*
Car l'ACL nominative de charlie lui accord spécifiquement un droit de lecture et accès sans avoir besoin de l'ajouter dans le groupe.
---

## 6. Explication : utilité du bit SGID en contexte collaboratif
<!-- 5 à 10 lignes expliquant :
     - ce que fait le SGID sur un répertoire
     - pourquoi c'est utile quand plusieurs membres d'une équipe partagent un dossier
     - ce qui se passerait sans ce bit -->

Le SGID appliqué au répertoire, tout sous fichier ou sous dossier inclu dans ce répertoire d'hériter automatiquement du groupe "devteam" plutôt que celui du créateur.
Cela permet à tout les membres du groupe "devteam" d'accéder aux fichiers/sous dossiers du répertoire créés par leurs membres.
Evite de bloquer les fichiers créés et qu'ils soient uniquement accessible par son créateur (les fichiers sont créés par défaut dans le groupe personnel de leur utilisateur/créateur). 
Exemple : alice créer un fichier, il appartient par défaut au groupe "alice", le SGID empêche cela en forcant le groupe du fichier en "devteam".


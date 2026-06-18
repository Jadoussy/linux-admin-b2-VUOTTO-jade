[18/06/26] VUOTTO Jade ESGI B2

Ma configuration : 
- VM Linux : distribution Ubuntu (version 24.04.4 LTS)
- Machine hôte : Windows 11

# Tableau de statut

| Mission | Description | Statut | Points estimés |
| :--- | :--- | :---: | :---: |
| M1 | Mise en place du dépôt GitHub | ✅  | /10 |
| M2 | Gestion des utilisateurs & groupes | ✅ | /20 |
| M3 | Système de fichiers & permissions | ✅ | /20 |
| M4 | Service systemd custom | ✅ | /20 |
| M5 | Sécurisation SSH & pare-feu | ✅ | /20 |
| Bonus | (optionnel) | ❌ | /10 |

### Mission 1
J'ai recréé l'arborescence du projet, rédigé le readMe et préparé mon environnement (installation de VScode et Git sur la VM Linux).

### Mission 2
J'ai créé un script qui créer des groupes et utilisateurs s'il n'existe pas déjà. L'utilisation de la condition if, else et la boucle for pour gérer l'idempotence du script.

### Mission 3
J'ai créé un script qui gère les droits POSIX et créer une ACL pour un utilisateur. Utilisation des bits spéciaux pour créer un dossier collaboratif pour les utilisateurs membres de devteam.

### Mission 4
J'ai créé un script de surveillance des tentatives de connexion SSH échouées. Ainsi qu'un fichier de config systemd pour faire tourner et supérviser automatiquement le script en arrière plan en tant que service système.

### Mission 5
J'ai créé un script pour durcir le protocole SSH, une backup et la validation de syntaxe de config. Ainsi que la mise en place d'un pare feu via UFW.

# Vérifications finales

git log --oneline
```
1eb1180 (HEAD -> main, origin/main, origin/HEAD) docs(m5): update README.md
6c7e198 docs(m5): update README.md
18765f6 docs(m5): rapport mission 5 avec captures de vérification et tests
abf71b6 feat(m5): scrip tharden_ssh : durcicement du protocle SSH et pare feu UFW
6886660 docs(m4): update README.md
68b9c7a feat(m4): script logwatcher.sh pour monitorer les tentatives de connexion échouées SSH
3271381 feat(m4): fichier unit logwatcher.service
a010b0f docs(m4): rapport mission 4 avec captures de vérification et tests
```
git status
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

git push origin main
```
Everything up-to-date
```

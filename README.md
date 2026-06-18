[18/06/26] VUOTTO Jade ESGI B2

Ma configuration : 
- une VM Linux distribution Ubuntu (version 24.04.4 LTS)
- ma machine hote sous Windows 11

### Tableau de statut

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
J'ai créé un script pour durcir le protocole SSH et la mise en place d'un pare feu via UFW.
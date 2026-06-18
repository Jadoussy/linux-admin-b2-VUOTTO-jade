# Rapport Mission 5 – Sécurisation SSH & pare-feu

**Auteur :** Vuotto Jade 
**Date :** 2026-06-18
**Distribution :** Ubuntu (version 24.04.4 LTS)

---

## 1. Exécution du script de durcissement

```bash
sudo ./scripts/harden_ssh.sh
```

**Sortie :**

```
[INFO] Sauvegarde de /etc/ssh/sshd_config → /etc/ssh/sshd_config.bak.20260618
[INFO] Application des directives de sécurité...
[INFO] Validation de la syntaxe...

============================================================
 Modifications appliquées (diff)
============================================================
41c41
< #LoginGraceTime 2m
---
> LoginGraceTime 20
45c45
< MaxAuthTries 10
---
> MaxAuthTries 3
67c67
< PasswordAuthentication yes
---
> PasswordAuthentication no
100c100
< X11Forwarding yes
---
> X11Forwarding no
109,110c109,110
< #ClientAliveInterval 0
< #ClientAliveCountMax 3
---
> ClientAliveInterval 300
> ClientAliveCountMax 2

============================================================
 ✅ Configuration validée — sshd NON redémarré
============================================================
 Vérifiez votre connexion SSH depuis un autre terminal,
 puis redémarrez manuellement avec :
   sudo systemctl restart ssh
```

---

## 2. Diff – avant / après

```bash
diff /etc/ssh/sshd_config.bak.20261806 /etc/ssh/sshd_config
```

```
41c41
< #LoginGraceTime 2m
---
> LoginGraceTime 20
45c45
< MaxAuthTries 10
---
> MaxAuthTries 3
67c67
< PasswordAuthentication yes
---
> PasswordAuthentication no
100c100
< X11Forwarding yes
---
> X11Forwarding no
109,110c109,110
< #ClientAliveInterval 0
< #ClientAliveCountMax 3
---
> ClientAliveInterval 300
> ClientAliveCountMax 2
```

---

## 3. Validation de la syntaxe

```bash
sudo sshd -t
echo "Code retour : $?"
```

```
[sudo] Mot de passe de esgi :
Code retour : 0
```

---

## 4. Configuration UFW

Commandes exécutées :

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw deny from 192.0.2.0/24

sudo ufw enable
```

**État du pare-feu :**

```bash
sudo ufw status verbose
```

```
État : actif
Journalisation : on (low)
Par défaut : deny (incoming), allow (outgoing), disabled (routed)
Nouveaux profils : skip

Vers                       Action      De
----                       ------      --
22                         ALLOW IN    Anywhere
2222                       ALLOW IN    Anywhere
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443                        ALLOW IN    Anywhere
2222/tcp                   ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
Anywhere                   DENY IN     192.0.2.0/24
22 (v6)                    ALLOW IN    Anywhere (v6)
2222 (v6)                  ALLOW IN    Anywhere (v6)
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
443 (v6)                   ALLOW IN    Anywhere (v6)
2222/tcp (v6)              ALLOW IN    Anywhere (v6)
443/tcp (v6)               ALLOW IN    Anywhere (v6)
```

---

## 5. Test de connexion SSH

```bash
ssh -i ~/.ssh/id_ed25519 esgi@192.168.86.30
```

```
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-124-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

La maintenance de sécurité étendue pour Applications n'est pas activée.

0 mise à jour peut être appliquée immédiatement.

21 mises à jour de sécurité supplémentaires peuvent être appliquées avec ESM Apps.
En savoir plus sur l'activation du service ESM Apps at https://ubuntu.com/esm

New release '25.10' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Thu Jun 18 16:08:09 2026 from 192.168.86.30
```

---

## 6. Analyse : pourquoi PasswordAuthentication no est-il critique ?

<!-- 5 lignes minimum expliquant :
     - ce qu'est une attaque par brute-force SSH
     - pourquoi les mots de passe sont vulnérables même complexes
     - ce qu'apportent les clés SSH en comparaison
     - pourquoi cette directive est plus impactante que PermitRootLogin no seul -->

Une attaque par brute-force consiste à envoyer un bot/script faire des milliers de tentatives de MDP à la seconde dans le but de, à force, tomber sur le bon MDP pour rentrer.
Plus ils sont complexes, plus ils prennent de temps à être trouvés. Cependant, les machines (puissances de calcul : cpu et gpu) sont de plus en plus performantes et réduisent le temps pour trouver le MDP.
Ils seront vulnérables tant qu'il est possible de trouver/deviner la combinaison du MDP.

Contrairement au clés ssh, qui sont des clés complexes (cryptographie) et uniques. Qui sont configurées par le dév avec shh et reconnues par ssh comme clé connue/autorisée. De l'extérieur, on ne peut pas ajouter de clés autorisées par le système.

Cette directive est plus impactante que bloquer la connexion à root (utilisateur systeme avec tout les droits). Car les autres utilisateurs restent vulnérables aux attaques par brut-force.

---

## 7. Réflexion : mesures de durcissement complémentaires en production

<!-- Citer et expliquer brièvement 3 mesures supplémentaires que vous ajouteriez
     sur un vrai serveur en production (Fail2Ban, port knocking, certificats SSH, etc.) -->

Fail2Ban : Outil pour bannir temporairement ou définitivement les @ ip d'un attaquant qui cumule les échecs.
White-listing : Liste blanche prédéfinie qui indique les seules @ ip autorisées à se connecter.
2FA : Ajouter un logiciel de double autentification comme Google authenticator et imposer de donner le code à usage unique de connexion en complément de ssh.

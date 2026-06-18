# Rapport Mission 4 – Service systemd custom

**Auteur :** Vuotto Jade 
**Date :** 2026-06-18
**Distribution :** Ubuntu (version 24.04.4 LTS)

---

## 1. Fichier unit logwatcher.service

```ini
[Unit]
Description=Service de surveillance des tentatives de connexion ssh (logwatcher)          

# dépendances (network.target syslog.target)
After=network.target syslog.target                                                         

[Service]
# type approprié pour une boucle infinie
Type=simple                                   

# User=esgi # utilisateur sous lequel tourne le service

# chemin absolu vers logwatcher.sh
ExecStart=/bin/bash /home/esgi/Bureau/Linux18juin/linux-admin-b2-VUOTTO-jade/scripts/logwatcher.sh     

# politique de redémarrage en cas d'échec
Restart=on-failure    

# délai avant redémarrage
RestartSec=10s

# destination des logs stdout                     
StandardOutput=journal

# destination des logs stderr          
StandardError=journal

# identifiant dans journald
SyslogIdentifier=logwatcher       

# Optionnel – Hardening (bonus)
# NoNewPrivileges=yes
# ProtectSystem=strict
# PrivateTmp=yes

[Install]
# target de démarrage
WantedBy=multi-user.target               
```

---

## 2. Déploiement et activation

```bash
sudo cp configs/logwatcher.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now logwatcher
```

---

## 3. État du service

```bash
sudo systemctl status logwatcher
```

```
● logwatcher.service - Service de surveillance des tentatives de connexio>
     Loaded: loaded (/etc/systemd/system/logwatcher.service; enabled; pre>
     Active: active (running) since Thu 2026-06-18 14:53:10 CEST; 50s ago
   Main PID: 5783 (bash)
      Tasks: 2 (limit: 2264)
     Memory: 1.0M (peak: 2.1M)
        CPU: 135ms
     CGroup: /system.slice/logwatcher.service
             ├─5783 /bin/bash /home/esgi/Bureau/Linux18juin/linux-admin-b>
             └─5807 sleep 30

juin 18 14:53:10 esgi-VirtualBox systemd[1]: Started logwatcher.service ->
juin 18 14:53:10 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentati>
juin 18 14:53:40 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentati>
lines 1-14/14 (END)...skipping...
● logwatcher.service - Service de surveillance des tentatives de connexion ssh (logwatcher)
     Loaded: loaded (/etc/systemd/system/logwatcher.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-06-18 14:53:10 CEST; 50s ago
   Main PID: 5783 (bash)
      Tasks: 2 (limit: 2264)
     Memory: 1.0M (peak: 2.1M)
        CPU: 135ms
     CGroup: /system.slice/logwatcher.service
             ├─5783 /bin/bash /home/esgi/Bureau/Linux18juin/linux-admin-b2-VUOTTO-jade/scripts/logwatcher.sh
             └─5807 sleep 30

juin 18 14:53:10 esgi-VirtualBox systemd[1]: Started logwatcher.service - Service de surveillance des tentatives de connexion ssh (logwatcher).
juin 18 14:53:10 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) — 14:53:10
juin 18 14:53:40 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) — 14:53:40
```

---

## 4. Logs journald (20 dernières lignes)

```bash
sudo journalctl -u logwatcher --no-pager -n 20
```

```
juin 18 14:53:10 esgi-VirtualBox systemd[1]: Started logwatcher.service - Service de surveillance des tentatives de connexion ssh (logwatcher).
juin 18 14:53:10 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) — 14:53:10
juin 18 14:53:40 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) — 14:53:40
juin 18 14:54:10 esgi-VirtualBox logwatcher[5783]: [LOGWATCHER] 0 tentative(s) SSH échouée(s) — 14:54:10
```

---

## 5. Fichier de log activity.log

```bash
cat /var/log/logwatcher/activity.log
```

```
2026-06-18 14:53:10 | Nouvelles: 0 | Total: 1
2026-06-18 14:53:40 | Nouvelles: 0 | Total: 1
2026-06-18 14:54:10 | Nouvelles: 0 | Total: 1
2026-06-18 14:54:40 | Nouvelles: 0 | Total: 1
```

---

## 6. Explication : Type=simple vs Type=forking

<!-- Expliquer la différence entre ces deux types.
     Pourquoi simple est-il adapté à logwatcher.sh ?
     Dans quel cas utiliserait-on forking ? -->

**Simple** indique à **systemd** comment le processus démarre et comment surveiller son état de santé
Il est adapté car le processus doit rester au 1er plan pour faire le lien avec la boucle **while true** (tourne toujours) rythmée par un **sleep**.
**Forking** est utilisé lorsqu'un programme lance un procéssus enfant et que le parent s'arrète immédiatemment. Le système doit alors chercher et suivre le **PID** du processus enfant en arrière plan.

La différence entre les deux est que **Simple** s'exécute de manière linéaire et continu alors que **Forking** se clone puis s'arrête pour laisser tourner ces processus enfants (fils.)

---

## 7. Explication : Restart=on-failure

<!-- Expliquer ce que fait cette directive.
     Dans quel cas serait-elle insuffisante ? (ex: si le script quitte avec code 0) -->

Cette directive indique à **systemd** de redémarrer automatiquement le processus s'il est arrêté de manière anormale ou kill.
Elle serait insuffisante dans les cas suivant : 
- Si le script rencontre une condition prévue par le dév et execute un "exit 0" qui fait met fin de manière normal le processus.
- Si le script contient une erreur de syntaxe ou requiert un fichier introuvable. **Systemd** va le relancer en boucle ce qui va utiliser des ressources pour un programme qui ne marche pas ou bug.
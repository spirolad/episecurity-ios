# Application EpiBrother

EpiBrother est une solution de messagerie interne destinée aux entreprises. Son objectif est d’analyser les échanges professionnels à l’aide de l’intelligence artificielle afin de détecter les comportements et les messages contraires au règlement intérieur de l’entreprise.

Lorsqu’un message est identifié comme potentiellement contraire aux règles établies par l’entreprise, il est automatiquement signalé au manager concerné afin qu’il puisse examiner la situation et prendre les mesures appropriées.

L’application cible iOS et iPadOS via Xcode.

## Découpage des responsabilités

- Jules Ladaigue : chef de projet
- Quentin Coedo : architecte sécurité et Red Team
- Olivier Bensemhoun : développeur

## Planning

Le projet sera découpé en cinq séances de quatre heures, chacune avec un backlog et un jalon.

### Liste des jalons

* **Jeudi 19 novembre : définir le projet**
  - Décision sur l’objectif de l’application et définition du périmètre
  - Répartition des rôles et de la charge de travail
  - Analyse STRIDE
  - Définition des différentes fonctionnalités
* **Vendredi 20 novembre : choix technique de réalisation**
  - Choix de l’architecture et des différents composants de l’application
  - Étude pour sécuriser l’application
  - Affinage du backlog avec les user stories et les tâches
* **Lundi 23 novembre : création du MVP**
  - Développement des différentes fonctionnalités
  - Relecture du code et vérification de la sécurité
  - Test utilisateur pour vérifier le bon fonctionnement
* **Vendredi 27 novembre : retour d’audit**
  - Audit des autres groupes
  - Correction des problèmes potentiels rencontrés lors des audits croisés
  - Affinage à la suite des retours sur l’interface
* **Mercredi 15 janvier**
  - Préparation à la soutenance finale
  - Démonstration en direct de l’application

## État du backlog

* **Authentification — ✅ Terminé**
  - [Frontend] Connexion, affichage des erreurs, restauration de session et déconnexion
  - [Backend] Authentification, validation JWT, révocation des jetons et contrôle d’accès par rôle

* **Envoi de messages — ✅ Fonctionnel**
  - [Frontend] Chiffrement AES-GCM local, déchiffrement à l’affichage, liste des collègues et historique
  - [Backend] Contrôle des collègues d’un même manager, stockage et transmission des messages
  - **Limite :** la clé AES est stockée dans le trousseau de chaque appareil ; le chiffrement n’est donc pas encore un chiffrement de bout en bout inter-appareils.

* **Analyse par intelligence artificielle — ⚠️ Partiel**
  - [Backend] Service heuristique DLP/toxicité, création et stockage des signalements
  - **Limite :** aucun modèle IA/LLM n’est branché et les messages préfixés `ENC:` sont volontairement ignorés par l’analyse backend.

* **Comptes, rôles et équipes — ✅ Terminé**
  - [Frontend] Création de comptes, modification du profil, annuaire, rôles et affectation à un manager
  - [Backend] Création/modification/suppression, rôles et affectations manager/salarié

* **Messages problématiques — ✅ Fonctionnel**
  - [Frontend] Liste, détail, motif, sévérité, prise en charge, clôture et classement sans suite
  - [Backend] Filtrage par équipe, détail autorisé, mise à jour des statuts et protection des signalements d’une autre équipe
  - **Limite :** le service de notification push/WebSocket est encore un squelette ; l’actualisation se fait par chargement manuel ou rafraîchissement de l’écran.

* **Information légale — ✅ Terminé**
  - [Frontend] Notice à la première connexion, données analysées, modalités de signalement et confirmation de lecture


## Scénario utilisateur

**En tant que salarié,**
je veux pouvoir envoyer des messages à mes collègues,
afin de pouvoir communiquer efficacement.

**En tant que salarié,**
je veux être informé du fait que mes messages problématiques peuvent être signalés,
afin d’avoir conscience qu’il peut y avoir des conséquences liées à mes messages.

**En tant que manager,**
je veux pouvoir identifier les comportements contraires aux différentes règles,
afin de prendre des mesures pour protéger l’entreprise.

**En tant qu’administrateur,**
je veux que les salariés soient informés que leurs messages peuvent être signalés,
afin d’éviter des amendes de la CNIL.

**En tant qu’administrateur,**
je veux pouvoir créer des comptes pour les salariés et les managers,
afin de pouvoir gérer les communications.

**En tant qu’administrateur,**
je veux pouvoir affecter des salariés à un manager,
afin qu’il puisse gérer les problèmes de son équipe.

### Choix technologie de cryptage

**Le Chiffrement Symétrique de Transport**
Une fois que les clés de session ont été négociées par le protocole d'établissement, le message lui-même est chiffré à l'aide d'algorithmes de chiffrement symétrique.   

Applications d'exemples : Presque toutes les messageries E2EE (Signal, WhatsApp, Telegram pour les "Chats Secrets").

Comment ça fonctionne : L'appareil de l'expéditeur brouille le message en utilisant une clé secrète unique et un algorithme rapide (le plus souvent AES-256 en mode GCM ou ChaCha20-Poly1305). Le destinataire utilise exactement la même clé pour déchiffrer.   

Points positifs :
Extrêmement rapide et économe en batterie pour les smartphones.
Mise en place facile.
Très haut niveau de sécurité mathématique.

Points négatifs :
Ne gère pas à lui seul l'échange de clés : si la clé secrète est interceptée au départ, tout le système s'effondre (d'où l'obligation de l'associer à un protocole d'échange comme X3DH).

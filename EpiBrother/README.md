# Application EpiBrother

EpiBrother est une solution de messagerie interne destinée aux entreprises. Son objectif est d’analyser les échanges professionnels à l’aide de l’intelligence artificielle afin de détecter les comportements et les messages contraires au règlement intérieur de l’entreprise.

Lorsqu’un message est identifié comme potentiellement contraire aux règles établies par l’entreprise, il est automatiquement signalé au manager concerné afin qu’il puisse examiner la situation et prendre les mesures appropriées.

L’application est disponible sur macOS.

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

## Backlog

* **Authentification**
  - [Frontend] Créer l’écran de connexion - Terminé
  - [Frontend] Gérer les erreurs d’identification et afficher les messages appropriés - Terminé
  - [Frontend] Conserver la session de l’utilisateur connecté - Terminé
  - [Frontend] Permettre la déconnexion - Terminé
  - [Backend] Créer le service d’authentification - Terminé
  - [Backend] Vérifier les identifiants de l’utilisateur - Terminé
  - [Backend] Générer et valider le jeton de session - Terminé
  - [Backend] Révoquer la session lors de la déconnexion - Terminé
  - [Backend] Contrôler les accès selon le rôle de l’utilisateur - Terminé

* **Envoi de messages entre utilisateurs**
  - Chiffrement des messages
    - [Frontend] Chiffrer le message au moment de l’envoi - Terminé
    - [Frontend] Déchiffrer le message au moment de la réception - Terminé
    - [Backend] Service pour générer les clés de chiffrement - À faire
  - Chat entre collègues
    - [Frontend] Envoyer des messages aux collègues ayant le même manager - Terminé
    - [Frontend] Afficher la liste des collègues - Terminé
    - [Frontend] Afficher l’historique des conversations - Terminé
    - [Backend] Service pour récupérer la liste des collègues - Terminé
    - [Backend] Service pour récupérer la liste des messages chiffrés - Terminé
    - [Backend] Service pour transmettre les messages aux destinataires - Terminé
  - Analyse par intelligence artificielle
    - [Backend] Créer un service d’analyse - Terminé
    - [Backend] Ajouter un modèle d’IA pour analyser les messages - À faire
    - [Backend] Stocker les messages jugés problématiques par l’IA - Terminé

* **Compte utilisateur**
  - Gestion des comptes utilisateurs
    - [Frontend] Afficher le formulaire de création d’un compte utilisateur - Terminé
    - [Frontend] Permettre la modification des informations du profil - Terminé
    - [Frontend] Afficher la liste des utilisateurs - Terminé
    - [Backend] Créer un compte utilisateur - Terminé
    - [Backend] Modifier les informations du profil - Terminé
    - [Backend] Récupérer la liste des utilisateurs - Terminé
  - Gestion des rôles
    - [Frontend] Permettre à l’administrateur de choisir le rôle d’un utilisateur - Terminé
    - [Frontend] Adapter l’affichage des fonctionnalités selon le rôle - Terminé
    - [Backend] Attribuer un rôle utilisateur : salarié, manager ou administrateur - Terminé

* **Gestion des équipes**
  - [Frontend] Afficher l’affectation des salariés aux managers - Terminé
  - [Frontend] Permettre à l’administrateur d’affecter un salarié à un manager - Terminé
  - [Frontend] Permettre à l’administrateur de modifier une affectation - Terminé
  - [Backend] Affecter un salarié à un manager - Terminé
  - [Backend] Récupérer les salariés associés à un manager - Terminé
  - [Backend] Modifier l’affectation d’un salarié - Terminé

* **Messages problématiques**
  - Consultation des messages
    - [Frontend] Lister les messages signalés pour un manager - Terminé
    - [Frontend] Afficher le contenu d’un message signalé - Terminé
    - [Frontend] Afficher la raison et le niveau de problématicité détectés - Terminé
    - [Backend] Récupérer les messages signalés pour un manager - Terminé
    - [Backend] Fournir les détails d’un signalement - Terminé
  - Gestion des signalements
    - [Frontend] Permettre au manager de prendre en charge un signalement - Terminé
    - [Frontend] Permettre au manager de clôturer un signalement - Terminé
    - [Backend] Notifier automatiquement le manager concerné - À faire
    - [Backend] Mettre à jour l’état d’un signalement - Terminé

* **Information légale**
  - Information du salarié sur le traitement des messages
    - [Frontend] Afficher une information lors de l’inscription ou de la première connexion - Terminé
    - [Frontend] Présenter les données collectées et analysées - Terminé
    - [Frontend] Expliquer les modalités de signalement des messages - Terminé


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

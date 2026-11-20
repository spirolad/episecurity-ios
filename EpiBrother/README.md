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

* **Envoi de messages entre utilisateurs**
  - Chiffrement des messages
    - Chiffrer le message au moment de l’envoi
    - Déchiffrer le message au moment de la réception
    - Service pour générer les clés de chiffrement
  - Chat entre collègues
    - Envoyer des messages aux collègues ayant le même manager
    - Afficher la liste de ses collègues
    - Service pour récupérer la liste des collègues
    - Service pour récupérer la liste des messages chiffrés
  - Analyse par intelligence artificielle
    - Créer un service d’analyse [Backend] - À faire
    - Ajouter un modèle d’IA pour analyser les messages [Backend] - À faire
    - Stocker les messages jugés problématiques par l’IA [Backend] - À faire

* **Compte utilisateur**
  - Gestion des comptes utilisateurs
    - Créer un compte utilisateur
    - Authentifier un utilisateur
    - Modifier les informations du profil
    - Consulter la liste des utilisateurs
  - Gestion des rôles
    - Attribuer un rôle utilisateur : salarié, manager ou administrateur
    - Restreindre les fonctionnalités selon le rôle

* **Gestion des équipes**
  - Affecter un salarié à un manager
  - Consulter les salariés associés à un manager
  - Modifier l’affectation d’un salarié

* **Messages problématiques**
  - Consultation des messages
    - Lister les messages signalés pour un manager
    - Consulter le contenu d’un message signalé
    - Afficher la raison et le niveau de problématicité détectés
  - Gestion des signalements
    - Notifier le manager concerné
    - Prendre en charge un signalement
    - Clôturer un signalement

* **Information légale**
  - Information du salarié sur le traitement des messages
    - Afficher une information lors de l’inscription ou de la première connexion
    - Présenter les données collectées et analysées
    - Expliquer les modalités de signalement des messages


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

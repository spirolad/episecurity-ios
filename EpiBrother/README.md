# Application EpiBrother

Epibrother est une solution de messagerie interne destinée aux entreprises. Son objectif est d'analyser les échanges professionnels à l'aide de l'intelligence artificielle afin de détecter les comportements et les messages contraires au règlement intérieur de l'entreprise.

Lorsqu'un message est identifié comme potentiellement contraire aux règles établies par l'entreprise, il est automatiquement signalé au manager concerné afin qu'il puisse examiner la situation et prendre les mesures appropriées.

L'application est disponible sur macOS et sur iOS.
## Découpage des responsabilités

* Jules Ladaigue: Chef de projet 
- Quentin Coedo:  Architecte sécurité + Red Team
- Olivier Bensemhoun: Développeur

## Planning 

Le projet sera découpé en 5 séances de 4 heures avec chacune un backlog et un jalon. 

### Liste des jalons

* Jeudi 19 novembre: définir le projet 
  - Décision sur l'objectif de l'application et définition du périmètre
  - Répartition des rôles et de la charge de travail
  - Analyse STRIDE 
  - Définition des différentes feature
- Vendredi 20 novembre: choix technique de réalisation
  - Choix de l'architecture et des différents composants de l'application
  - Étude pour sécuriser l'application
  - Affinage du backlog avec les user stories et les taches
-  Lundi 23 novembre: Création du MVP
  - Développement des différentes fonctionnalités
  - Relecture du code et vérification de la sécurité
  - Test utilisateur pour vérifier le bon fonctionnement
- Vendredi 27 novembre: Retour d'audit  
  - Audit des autres groupes
  - Correction des possibles problèmes rencontrés lors des audits croisés
  - Afinage suite aux retours sur l'interface
- Mercredi 15 janvier: 
  - Préparation à la soutenance finale
  - Démonstration en direct de l'application


### Backlog

* Envoie des messages entre utilisateur
  - Chiffrement des messages
  - Analyse par inteligence artificiel
- Compte utilisateur
  - Gestion des comptes utilisateurs 
  - Gestion des roles
- Messages problématiques
  - Consultation des messages
- Information légale
  - Information par le salarié du traitement des messages


## Scénario utilisateur

En tant que salarié
Je veux pouvoir envoyer des messages à mes collègues
Afin de pouvoir communiquer efficacement

En tant salarié
Je veux etre informé que mes messages problématiques soient potentiellement remontés
Afin d'avoir conscience qu'il peut y avoir des conséquences à mes messages  

En tant que manager 
Je veux pouvoir identifié les comportements contraire aux différentes règles
Afin de prendre des mesures pour protéger l'entreprise

En tant qu'administrateur
Je veux que les salariés soient informé que leurs messages peuvent etre remonté
Afin d'éviter d'avoir des amendes de la CNIL 

En tant qu'administrateur 
Je veux pouvoir créer des comptes salariés et des managers
Afin de pouvoir gérer les communications

En tant qu'administrateur
Je veux pouvoir affecter des salariés à un manager 
Afin qu'il puisse gérer les problèmes de leurs équipes

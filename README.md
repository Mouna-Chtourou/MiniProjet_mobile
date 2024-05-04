# Suite d'Applications Mobiles pour l'Institut

Un projet développé avec Flutter qui comprend deux applications distinctes: une pour les administrateurs et une pour les étudiants. Ce projet est conçu spécifiquement pour améliorer la gestion et la communication entre les administrateurs et les étudiants au sein de l'établissement.

## Fonctionnalités

### Application Admin

L'application Admin permet à l'administrateur de gérer efficacement les différentes activités de l'institut ISI :

- **Authentification** : Inscription et connexion avec la possibilité d'ajouter une photo de profil.
- **Gestion des catégories** : Création, affichage, et suppression des catégories.
- **Gestion des posts** : Publication de posts avec des images.
- **Formulaires dynamiques** : Ajout et gestion de formulaires que les étudiants pourront remplir.
- **Visualisation des formulaires** : Les administrateurs peuvent visualiser une liste de tous les formulaires créés.

### Application Student

L'application Student offre aux étudiants la possibilité d'interagir avec les contenus publiés par les administrateurs :

- **Authentification** : Inscription et connexion avec ajout d'une photo de profil.
- **Inscription aux catégories** : Les étudiants doivent s'inscrire aux catégories pour recevoir des notifications.
- **Notifications** : Réception de notifications lorsqu'un nouvel post est ajouté par l'admin pour une catégorie à laquelle l'étudiant est inscrit.
- **Visualisation et remplissage de formulaires** : Les étudiants peuvent voir les différents formulaires ajoutés par les administrateurs et les remplir.
- **Export PDF** : Après remplissage, les formulaires peuvent être sauvegardés en format PDF.

## Technologies Utilisées

- **Flutter** : Pour le développement des interfaces utilisateur cross-platform.
- **Firebase** : Pour l'authentification, le stockage des données et des images, et la gestion des notifications.

## Installation

Pour installer et exécuter les applications sur votre machine locale, suivez les étapes ci-dessous :

1. Clonez ce dépôt sur votre machine locale en utilisant :
git clone https://github.com/Mouna-Chtourou/MiniProjet_mobile.git

2. Naviguez dans le dossier du projet et installez les dépendances :
cd institut-app
flutter pub get

3. Pour lancer l'application (assurez-vous d'avoir un émulateur ou un appareil connecté) :
flutter run



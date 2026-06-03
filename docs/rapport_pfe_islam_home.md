# Rapport PFE - Extraction complete du projet `Islam Home`

Ce document rassemble les informations du depot dont tu as besoin pour rediger un rapport de projet de fin d'etudes dans le style de `CommunBlog_Rapport_Mohamed_Dghar.docx`.

Recommendation de cadrage:
Presente `Islam Home` comme un ecosysteme compose de trois parties:
- une application mobile Flutter multiplateforme (coeur du projet)
- un panneau d'administration web React/Firebase (back-office de contenu)
- une landing page web vitrine (presentation et telechargement)

Cela colle tres bien a la logique du rapport exemple, qui distingue front-office, back-office, besoins, conception et realisation.

## 1. Fiche d'identite du projet

- Titre conseille: `Islam Home - Application islamique mobile multiplateforme pour l'accompagnement spirituel quotidien`
- Nature du projet: projet de fin d'etudes / application mobile avec services cloud et panneau d'administration web
- Etudiant: `Mohamed Dghar`
- Nom technique du projet Flutter: `islam_home`
- Version actuelle relevee: `1.0.2+3`
- Package Android: `com.islamHome.app`
- Projet Firebase: `islam-home-official`
- Langues implementees: `arabe`, `anglais`
- Langue prevue mais non finalisee dans le depot: `francais`

## 2. Resume du projet

Texte reutilisable:

`Islam Home` est une application islamique mobile developpee dans le cadre d'un projet de fin d'etudes. Son objectif principal est de regrouper dans une seule solution numerique les besoins quotidiens du musulman: lecture du Coran, ecoute des recitations, consultation du tafsir, lecture du hadith, adhkar, horaires de priere, direction de la qibla, tasbeeh, suivi de khatma, contenu spirituel quotidien et bibliotheque audio/video. Le projet s'appuie sur une architecture modulaire construite avec Flutter et Dart, une gestion d'etat basee sur Riverpod, un stockage local hors ligne avec Hive et SQLite, ainsi qu'une couche cloud avec Firebase Authentication et Cloud Firestore. En complement de l'application mobile, le depot contient un panneau d'administration web developpe en React/Vite pour la gestion de certains contenus dynamiques et une landing page bilingue de presentation. Le resultat obtenu est un ecosysteme fonctionnel, extensible et adapte a une utilisation quotidienne, avec prise en charge du mode hors ligne, des notifications de priere, de la synchronisation des donnees utilisateur et d'une experience bilingue arabe/anglais.`

Mots-cles proposes:
`Flutter`, `Dart`, `Firebase`, `Riverpod`, `Hive`, `application islamique`, `Coran`, `hadith`, `adhkar`, `priere`, `hors ligne`, `multilingue`

## 3. Introduction generale

### 3.1 Contexte

Texte conseille:

Le developpement des usages mobiles a profondement transforme l'acces au savoir religieux et aux outils d'accompagnement spirituel. Pourtant, de nombreux utilisateurs doivent encore alterner entre plusieurs applications distinctes pour lire le Coran, consulter le tafsir, suivre les horaires de priere, utiliser une qibla, lire les adhkar ou ecouter des contenus audio islamiques. Cette fragmentation nuit a l'experience utilisateur, augmente la dependance a Internet et rend difficile la centralisation des preferences personnelles. Dans ce contexte, `Islam Home` a ete concu comme une solution unifiee, moderne et accessible, capable de rassembler les besoins quotidiens du musulman dans une application mobile unique.

### 3.2 Problematique

Formulation possible:

Comment concevoir une application islamique complete, fluide et maintenable, capable d'offrir en une seule interface des fonctionnalites de lecture, d'ecoute, de rappel, de consultation religieuse et de personnalisation, tout en garantissant une bonne experience hors ligne, une synchronisation cloud selective et une gestion simple des contenus ?

### 3.3 Objectifs du projet

- Centraliser dans une seule application les principales fonctionnalites islamiques du quotidien.
- Proposer une lecture du Coran avec recitations, tafsir, traductions et memorisation de la progression.
- Fournir les horaires de priere, les rappels audio de l'adhan et la direction de la qibla.
- Offrir des bibliotheques de hadiths, d'adhkar, de duas et de sira.
- Permettre un usage hors ligne pour une grande partie des contenus.
- Ajouter une couche de personnalisation: favoris, telechargements, historique, khatma, preferences d'affichage.
- Gerer l'authentification utilisateur et la synchronisation de certaines donnees avec Firebase.
- Mettre en place un panneau d'administration web pour gerer les contenus dynamiques.

### 3.4 Methodologie de travail

Formulation conseillee:

Le projet a ete mene selon une approche iterative proche de l'Agile. Le travail a ete structure par fonctionnalites: initialisation de l'application, mise en place de l'architecture, implementation des modules principaux, integration des services externes, gestion du hors ligne, ajout des notifications, synchronisation cloud, puis validation technique. Cette approche a permis de construire progressivement une base stable tout en gardant la possibilite d'etendre le produit par modules.

## 4. Presentation du projet

### 4.1 Description generale

`Islam Home` est une application mobile developpee avec Flutter, accompagnee d'un panneau d'administration web et d'une landing page. Le projet vise a devenir un compagnon numerique quotidien pour l'utilisateur musulman, en regroupant des outils de lecture, d'ecoute, de rappel spirituel et de consultation religieuse.

### 4.2 Public cible

- Utilisateurs musulmans souhaitant une application unique pour la pratique quotidienne.
- Utilisateurs arabophones et anglophones.
- Utilisateurs mobiles ayant besoin d'un acces hors ligne a une partie du contenu.
- Administrateur de contenu charge de gerer certains elements dynamiques via une interface web.

### 4.3 Positionnement recommande dans le rapport

Pour le rapport, tu peux presenter le projet comme:

`une plateforme islamique numerique centree sur une application mobile, completee par un back-office web de gestion de contenu et une page vitrine de diffusion.`

## 5. Perimetre fonctionnel reel du depot

### 5.1 Modules principaux visibles dans l'application

Sections relevees dans `all_sections_screen.dart`:
- Mushaf / Coran
- Hadith
- Tafsir audio
- Sira
- Adhkar et duas
- Tasbeeh
- Radio
- TV en direct
- Bibliotheque video
- Horaires de priere
- Telechargements
- Favoris
- Parametres

### 5.2 Fonctionnalites principales detaillees

#### Coran

- Lecture du mushaf page par page
- Memorisation de la derniere position de lecture
- Acces direct a une page, une sourate ou une aya
- Consultation du tafsir depuis une aya
- Lecture audio des versets
- Gestion de favoris et de playlists audio
- Suivi de progression de khatma
- Support de plusieurs riwayat du mushaf

Point fort technique:
le modele `MushafRiwaya` montre `9` riwayat supportees, dont `3` disponibles hors ligne (`Hafs`, `Warsh`, `Qalon`) et `6` telechargeables dynamiquement.

#### Recitations et audio

- Liste des recitateurs via API
- Support des riwayat
- Lecture audio continue
- Mini player et ecran lecteur dedie
- Telechargement des fichiers audio
- Notifications de lecture en arriere-plan

#### Tafsir

- Consultation du tafsir texte
- Tafsir audio
- Telechargement local de certaines sources
- Integration de sources issues de `mp3quran`, `Quran.com` et jeux de donnees locaux

#### Hadith

Le depot contient des jeux de donnees locaux importants:
- `Sahih al-Bukhari`: `7589` hadiths
- `Sahih Muslim`: `7459`
- `Sunan Abi Dawud`: `5276`
- `Sunan an-Nasai`: `5768`
- `Jami at-Tirmidhi`: `4053`
- `Sunan Ibn Majah`: `4345`
- `Muwatta Malik`: `1985`
- `40 Nawawi`: `42`
- `Hadith Qudsi`: `40`

Total local minimal releve pour les 7 grands recueils: `36475 hadiths`, sans compter Nawawi et Qudsi.

#### Adhkar et duas

- Base locale de `333` elements dans `assets/adhkar/adhkar.json`
- `12` categories relevees
- Liste par categorie
- Detail d'un dhikr
- Favoris
- Recherche
- Comptage

#### Horaires de priere

- Calcul et affichage des horaires de priere
- Choix de methode de calcul
- Saisie manuelle de ville/pays
- Utilisation de la geolocalisation
- Ajustements manuels par priere
- Rappels avant priere
- Notifications de l'adhan
- Test du son de l'adhan
- Gestion des permissions `notification`, `exact alarm`, `battery optimization`

#### Qibla

- Boussole qibla basee sur les capteurs du telephone
- Calcul de distance et d'orientation

#### Tasbeeh et historique

- Tasbeeh electronique
- Historique local
- Sauvegarde des compteurs

#### Khatma intelligente

- Suivi par page, juz ou sourate
- Objectif de date
- Calcul automatique de l'objectif quotidien
- Strategie de rattrapage
- Synchronisation cloud des progres

#### Sira et bibliotheque spirituelle

- Donnees locales de sira: `14` etapes
- Bibliotheque audio/video
- Contenu biographique en arabe et en anglais

#### Contenu quotidien et accompagnement spirituel

- Aya du jour
- Hadith du jour
- Dhikr du jour
- Rotation automatique a l'entree dans l'accueil
- Widget mobile `Home Widget`
- Moteur de recommandations par humeur (`anxious`, `sad`, `happy`, `lost`, `tired`)

#### Favoris et telechargements

- Favoris pour recitateurs, sourates, hadiths, tafsir, seerah, playlists
- Ecran de telechargements
- Historique de telechargement
- Categories telechargees relevees: `quran`, `tafsir`, `seerah`

#### Authentification et profil

- Mode invite via connexion anonyme Firebase
- Inscription email/mot de passe
- Connexion email/mot de passe
- Connexion Google
- Liaison d'un compte anonyme avec un vrai compte pour conserver les donnees
- Profil utilisateur

#### Parametres

- Changement de langue
- Partage de l'application
- Ouverture du store
- Parametres de notifications
- Diagnostic des notifications
- Version de l'application

## 6. Besoins fonctionnels

### 6.1 Pour le visiteur / utilisateur anonyme

- Utiliser l'application sans creation immediate de compte
- Lire le Coran et consulter le contenu disponible
- Parcourir les modules principaux
- Utiliser les horaires de priere, la qibla, le tasbeeh et les adhkar

### 6.2 Pour l'utilisateur inscrit

- Se connecter par email ou Google
- Synchroniser certaines donnees personnelles dans le cloud
- Conserver favoris, settings et progres
- Gagner en personnalisation et en continuites d'usage

### 6.3 Pour l'administrateur

Pages relevees dans `admin_panel_v2/src/App.jsx`:
- Dashboard
- Gestion des adhkar
- Gestion des recitateurs
- Gestion des hadiths
- Gestion du tafsir
- Gestion des inspirations quotidiennes
- Centre de notifications push
- Gestion des utilisateurs
- Parametres admin

## 7. Besoins non fonctionnels

- Performance: chargement rapide et mise en cache locale
- Maintenabilite: architecture modulaire par couches
- Extensibilite: ajout de nouveaux modules, langues ou sources de contenu
- Disponibilite hors ligne: cache Hive, donnees locales JSON, telechargements
- Ergonomie: interface mobile riche, bilingue et organisee par modules
- Compatibilite: Android, iOS, web, Windows, Linux, macOS presents dans le depot
- Fiabilite: systeme de notifications, cache, reprise de donnees et diagnostics
- Securite: Firebase Auth, separation des donnees utilisateur, regles Firestore

## 8. Contraintes du projet

- Projet realise autour d'un seul etudiant
- Forte dependance a certains services externes pour le contenu et l'audio
- Contraintes Android pour les alarmes exactes et l'execution en arriere-plan
- Taille potentiellement importante des donnees multimedia telechargees
- Francais encore non integre dans les fichiers `l10n`
- Certaines fonctionnalites d'administration semblent encore en evolution

## 9. Architecture generale

### 9.1 Architecture logicielle du mobile

Structure relevee dans `lib/`:
- `core/` pour les constantes, services transverses, theme, utilitaires
- `data/` pour les modeles, repositories, services et base locale
- `presentation/` pour les ecrans, widgets et providers Riverpod
- `routes/` reserve a la navigation
- `l10n/` pour la localisation

Interpretation recommandee:

Le projet adopte une architecture modulaire proche d'une separation en couches `presentation / data / core`, avec Riverpod pour la gestion d'etat, GoRouter pour la navigation, Hive et SQLite pour la persistance locale, et Firebase pour les services cloud.

### 9.2 Initialisation de l'application

Sequence principale relevee dans `lib/main.dart`:
- initialisation Firebase
- connexion anonyme automatique si aucun utilisateur n'existe
- initialisation Hive
- enregistrement des adapters
- ouverture des boxes essentielles
- initialisation de la base adhkar
- initialisation du cache hors ligne
- initialisation de la connectivite
- lancement de l'application
- initialisation des notifications
- enregistrement des taches d'arriere-plan Android

### 9.3 Navigation

Routes principales relevees:
- `/splash`
- `/maintenance`
- `/language-selection`
- `/onboarding-permissions`
- `/prayer-method-selection`
- `/`
- `/all-sections`
- `/search`
- `/all-reciters`
- `/reciter`
- `/quran`
- `/tafsir`
- `/hadith`
- `/azkar`
- `/sira`
- `/tasbeeh`
- `/radio`
- `/live-tv`
- `/video`
- `/prayer-times`
- `/qibla`
- `/downloads`
- `/favorites`
- `/settings`
- `/profile`
- `/login`
- `/register`
- `/player`

## 10. Technologies utilisees

### 10.1 Application mobile

- `Flutter`
- `Dart`
- `Riverpod`
- `GoRouter`
- `Hive`
- `sqflite`
- `Firebase Core`
- `Firebase Auth`
- `Cloud Firestore`
- `Dio`
- `Just Audio`
- `audio_service`
- `flutter_local_notifications`
- `workmanager`
- `geolocator`
- `geocoding`
- `flutter_compass`
- `share_plus`
- `home_widget`
- `ota_update`

### 10.2 Panneau d'administration

- `React`
- `Vite`
- `Firebase`
- `React Router`
- `Recharts`
- `TailwindCSS`

### 10.3 Landing page

- `HTML`
- `CSS`
- `JavaScript`

## 11. Sources de donnees et APIs

Services externes releves:
- `mp3quran.net` pour recitateurs, radios, live TV, tafsir et videos
- `Quran.com API v4` pour recitations et certains contenus Quran
- `api.alquran.cloud` en secours legacy
- `jsDelivr / fawazahmed0 quran-api` pour editions Quran
- `jsDelivr / fawazahmed0 hadith-api` pour hadith
- `api.hadith.gading.dev` en secours legacy
- `api.aladhan.com` pour horaires de priere
- `habous.gov.ma` via scraping pour horaires marocains
- `islamicfinder.org` via scraping / fallback
- `archive.org` pour certaines series audio et biographiques
- `GitHub raw` pour le fichier `version.json` et la distribution OTA

## 12. Persistance locale et cloud

### 12.1 Stockage local

Boxes Hive ouvertes dans l'application:
- `settings`
- `favorites`
- `prayer_times_cache`
- `tasbeeh_box`
- `tasbeeh_history_box`
- `settings_box`
- `khatma_tracks_box`
- `quran_pages_v5`

Services de cache supplementaires:
- `offline_cache`
- `offline_cache_meta`

Base locale SQLite:
- `adhkar_database.dart`

### 12.2 Synchronisation cloud

Dans `FirestoreSyncService`, les donnees suivantes sont synchronisees:
- tasbeeh
- historique tasbeeh
- khatma
- favoris
- parametres utilisateur

Sous-collections utilisateur relevees:
- `users/{uid}/tasbeeh`
- `users/{uid}/tasbeeh_history`
- `users/{uid}/khatma`
- `users/{uid}/favorites`

Documents globaux utilises:
- `daily_verses`
- `system/config`

## 13. Securite et gestion des acces

### 13.1 Authentification

Relevee dans `auth_service.dart`:
- connexion anonyme
- email/mot de passe
- Google Sign-In
- liaison d'un compte anonyme avec un vrai compte
- reinitialisation du mot de passe

### 13.2 Regles Firestore relevees

Regles presentes dans `firestore.rules`:
- acces lecture/ecriture reserve a chaque utilisateur sur ses propres donnees
- lecture publique pour `adhkar`, `seerah`, `tafsir`
- ecriture admin conditionnee a l'email `islamhome1.0@gmail.com`
- refus par defaut de tout le reste

### 13.3 Point de clarification important

Le panneau d'administration React utilise aussi les collections:
- `reciters`
- `hadith`
- `notifications`
- `daily_verses`
- `users`

Alors que les regles Firestore du depot n'ouvrent explicitement que:
- `users/{userId}/...`
- `adhkar`
- `seerah`
- `tafsir`

Pour le rapport, tu peux:
- soit presenter l'admin panel comme `module complementaire en cours de finalisation`
- soit verifier/mettre a jour les regles si tu veux affirmer que tout le back-office est totalement operationnel

## 14. Diagrammes deja disponibles dans le depot

Tu as deja plusieurs diagrammes exploitables dans la partie `Conception`:

- `Diagrams/Islam Home _ Use Case Diagram.pdf`
- `Diagrams/Islam Home - Class Diagram.pdf`
- `Diagrams/Islam Home- ERD (Firestore Schema).pdf`
- `Diagrams/Sequence Diagrams/Flow 1 _ User Authentication _ App Initialization.pdf`
- `Diagrams/Sequence Diagrams/Flow 2 _ Prayer Times Fetch _ Azan Notification.pdf`
- `Diagrams/Sequence Diagrams/Flow 3 _ Quran Audio Playback _ Offline Download.pdf`
- `Diagrams/Sequence Diagrams/Flow 4 _ Tasbeeh Session _ Cloud Sync_2.pdf`
- `Diagrams/Sequence Diagrams/Flow 5 _ Admin_ Send Global Push Notification.pdf`

Conseil:
reprends ces diagrammes directement comme figures dans le rapport, au lieu d'en recreer de nouveaux.

## 15. Captures d'ecran deja disponibles

Captures existantes:
- `Screenshots/Arabic/Home.png`
- `Screenshots/Arabic/PrayerTimes.png`
- `Screenshots/Arabic/Qibla.png`
- `Screenshots/Arabic/Quran.png`
- `Screenshots/Arabic/Hadith.png`
- `Screenshots/Arabic/Azkar.png`
- `Screenshots/Arabic/Settings.png`
- `Screenshots/English/Home.png`
- `Screenshots/English/PrayerTimes.png`
- `Screenshots/English/Qibla.png`
- `Screenshots/English/Quran.png`
- `Screenshots/English/Hadith.png`
- `Screenshots/English/Azkar.png`
- `Screenshots/English/Settings.png`

Tu as donc deja `14` captures prêtes a inserer dans la section `Resultats et captures d'ecran`.

## 16. Taille et volume du projet

Mesures relevees avec le script local `count_lines.py`:
- Application Flutter: `188` fichiers Dart, `51957` lignes
- Panneau d'administration: `16` fichiers source, `3001` lignes
- Landing page: `3` fichiers source, `1980` lignes
- Total ecosysteme: `207` fichiers source, `56938` lignes

Ces chiffres sont tres utiles dans le rapport pour montrer l'ampleur du travail.

## 17. Jeux de donnees locaux identifies

- Sourates: `114`
- Fichiers Quran locaux: `12` fichiers JSON dans `assets/data/quran`
- Traductions / tafasir texte locaux: `10` editions
- Villes Habous: `191`
- Images locales de recitateurs: `236`
- Videos locales: `38`
- Etapes de sira locale: `14`
- Nawawi: `42` hadiths
- Qudsi: `40`
- Adhkar locaux: `333`

## 18. Validation et qualite actuelle

### 18.1 Analyse statique

Commande executee:
`flutter analyze`

Resultat:
`No issues found!`

Tu peux donc mentionner dans le rapport que l'analyse statique actuelle du projet Flutter ne remonte aucune erreur ni warning bloquant.

### 18.2 Tests

Etat releve:
- `29` fichiers Dart dans `test/`
- plusieurs fichiers de synthese `.md` de verification

Commande executee:
`flutter test`

Constat:
- la suite complete ne passe pas encore integralement
- le resume de fin indiquait `+97 -11`
- `3` fichiers de test ne contiennent pas de fonction `main()`:
  - `accessible_surah_selector_dynamic_language_update_test.dart`
  - `auto_hide_appbar_animation_triggering_test.dart`
  - `quran_page_overflow_bug_exploration_test.dart`
- `test/widget_test.dart` est encore le test Flutter par defaut de compteur et ne correspond plus a l'application actuelle
- ce test echoue egalement car l'application utilise Hive et demande une initialisation adaptee au contexte de test

Formulation conseillee pour le rapport:

La base de code presente une demarche de test reelle avec un ensemble important de tests unitaires et widget, mais la suite de tests complete necessite encore une consolidation finale avant une validation 100%.

## 19. Environnement de travail et outils

Elements directement observables dans le depot:
- SDK Dart cible: `^3.10.7`
- Flutter avec generation de localisations activee
- Android Gradle avec `Java 17`
- Firebase
- GitHub pour l'artefact de mise a jour et le versioning OTA
- Vite/React pour le back-office

Tu peux presenter l'environnement de travail ainsi:

Le projet a ete developpe dans un environnement moderne base sur Flutter et Dart pour l'application mobile, Firebase pour les services cloud, et React/Vite pour le panneau d'administration. La persistance locale combine Hive et SQLite, tandis que l'integration continue de la qualite s'appuie sur `flutter analyze`, des scripts de tests et plusieurs documents de verification presents dans le depot.

## 20. Scripts et automatisation disponibles

Le dossier `scripts/` contient deja plusieurs utilitaires utiles a mentionner:
- telechargement de donnees Quran
- telechargement de hadith
- telechargement de tafsir
- telechargement de tafsir anglais
- generation de mappings Hizb
- import de donnees adhkar
- recuperation d'images de recitateurs
- scripts de tests

Cela montre que le projet ne se limite pas a l'interface, mais inclut aussi une couche d'automatisation des donnees.

## 21. Proposition de plan de rapport adapte a ton projet

Tu peux reutiliser la structure suivante, tres proche du document exemple:

### Page de garde

- etablissement
- filiere
- titre du projet
- nom de l'etudiant
- annee universitaire

### Remerciements

Partie a personnaliser manuellement.

### Resume du projet

Utilise le texte de la section 2.

### I. Introduction generale

- contexte
- problematique
- objectifs
- methodologie

### II. Presentation du projet

- description generale
- public cible
- vision globale de l'ecosysteme mobile + admin + landing

### III. Analyse des besoins

- besoins fonctionnels
- besoins non fonctionnels
- contraintes

### IV. Conception

- architecture generale du systeme
- diagramme de cas d'utilisation
- diagramme de classes
- schema Firestore / ERD
- flux principaux via diagrammes de sequence

### V. Realisation

- environnement technique
- structure du code
- implementation des modules principaux
- gestion du hors ligne
- synchronisation cloud
- securite et gestion des acces

### VI. Resultats et captures d'ecran

- accueil
- Coran
- horaires de priere
- qibla
- hadith
- adhkar
- parametres
- eventuellement panneau d'administration

### Conclusion generale et perspectives

- bilan du projet
- limites actuelles
- evolutions futures

### Bibliographie

- documentation Flutter
- documentation Riverpod
- documentation Firebase
- documentation Hive
- documentation GoRouter
- documentation Flutter Local Notifications
- documentation Just Audio / Audio Service
- APIs et sources externes utilisees

### Annexes

- scripts
- tests
- captures supplementaires
- versioning

## 22. Bibliographie technique recommandee

Tu peux utiliser cette base:

- Flutter documentation: `https://docs.flutter.dev/`
- Dart documentation: `https://dart.dev/`
- Riverpod documentation: `https://riverpod.dev/`
- Firebase for Flutter: `https://firebase.flutter.dev/`
- Cloud Firestore documentation: `https://firebase.google.com/docs/firestore`
- Firebase Authentication documentation: `https://firebase.google.com/docs/auth`
- Hive documentation: `https://docs.hivedb.dev/`
- GoRouter documentation: `https://pub.dev/packages/go_router`
- Flutter Local Notifications: `https://pub.dev/packages/flutter_local_notifications`
- Just Audio: `https://pub.dev/packages/just_audio`
- Audio Service: `https://pub.dev/packages/audio_service`
- MP3Quran API: `https://mp3quran.net/api/`
- Quran.com API: `https://api-docs.quran.com/`
- AlAdhan API: `https://aladhan.com/prayer-times-api`

## 23. Perspectives d'evolution credibles

Tu peux reutiliser ces pistes dans la conclusion:

- finalisation du francais et ajout d'autres langues
- consolidation complete de la suite de tests
- enrichissement des contenus admin dynamiques
- publication Play Store / App Store
- synchronisation cloud plus large des contenus utilisateur
- amelioration du back-office et des regles Firestore
- personnalisation visuelle plus poussee
- analytics et suivi de l'usage

## 24. Ce qu'il te reste a personnaliser manuellement

- nom exact de l'etablissement, de la filiere et de l'encadrant
- date, promotion et annee universitaire
- remerciements
- ton propre recit de la methodologie projet
- les captures que tu veux mettre en avant
- si tu veux centrer le rapport sur:
  - l'application mobile seule
  - ou l'ecosysteme complet mobile + admin + landing

## 25. Fichiers du depot a citer dans le rapport

Fichiers les plus utiles comme preuves techniques:
- `pubspec.yaml`
- `lib/main.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/quran_mushaf_screen.dart`
- `lib/presentation/screens/prayer_times_screen.dart`
- `lib/data/services/auth_service.dart`
- `lib/data/services/firestore_sync_service.dart`
- `lib/data/services/notification_service.dart`
- `lib/data/services/offline_cache_service.dart`
- `lib/presentation/providers/khatma_v2_provider.dart`
- `lib/presentation/providers/mushaf_riwaya_provider.dart`
- `firestore.rules`
- `admin_panel_v2/src/App.jsx`
- `landing/index.html`

## 26. Phrase de conclusion prete a reutiliser

`Au final, Islam Home depasse le cadre d'une simple application mobile de consultation religieuse. Il s'agit d'une solution numerique modulaire combinant lecture, ecoute, rappel, personnalisation, synchronisation et administration de contenu. Le projet met en avant une vraie richesse fonctionnelle, une architecture evolutive et une orientation utilisateur forte, tout en laissant une marge d'amelioration naturelle sur les tests finaux, l'extension multilingue et la consolidation du back-office cloud.`

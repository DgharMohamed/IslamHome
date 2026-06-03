# 🕋 Islam Home - Rapport de Projet de Fin d'Études

---

## 1. Description de l'Application

**Islam Home (بيت الإسلام)** est une application islamique complète et intégrée fonctionnant sur les plateformes mobiles, développée dans le cadre d'un **projet de fin d'études**. L'application vise à être une plateforme complète répondant aux besoins quotidiens des musulmans en matière de cultes et de connaissances religieuses.

### 1.1 Principales Catégories de l'Application

| Catégorie | Description |
|-----------|-------------|
| **Le Saint Coran** | Lecture du Coran avec calligraphie ottomane et limpide, possibilité d'écouter les famous lecteurs, accès au tafsir et aux traductions |
| **Les Hadiths** | Accès aux principaux livres de hadiths (Bukhari, Muslim, Tirmidhi, Nasai, Ibn Maja, Abu Dawud, Malik, Ahmad, Darimi, Hadith Qudsi) |
| **Les Dikrs et Invocations** | Dikrs du matin et du soir, dikrs après la prière, diverses invocations |
| **La Biographie Prophétique** | Bibliothèque audio de haute qualité de la vie du Prophète en arabe et en anglais |
| **Les Horaires de Prière** | Horaires de prière précis basés sur la localisation géographique |
| **La Qibla** | Boussole intelligente pour déterminer la direction de la Qibla |
| **Le Chapelet Électronique** | Chapelet intelligent avec enregistrement des glorifications |
| **Radio et Télévision** | Diffusion en direct des chaînes et radios islamiques |
| **Lecture de Livres** | Lecture de divers livres et leurs fonctionnalités |

---

## 2. Sources Utilisées pour la Collecte d'Informations

### 2.1 APIs Islamiques

| API | Description | Utilisation |
|-----|-------------|-------------|
| **MP3Quran API** (`mp3quran.net`) | API complet pour les lecteurs, récitations, radios et chaînes | Récupérer la liste des lecteurs, récitations, radios et chaînes |
| **Quran CDN API** (`cdn.jsdelivr.net/gh/fawazahmed0/quran-api`) | Données du Saint Coran | Récupérer les informations des sourates et du tafsir |
| **AlQuran Cloud API** (`api.alquran.cloud`) | API alternatif du Coran | Lecture du Coran et traductions |
| **Quran Foundation API** (`api.quran.com`) | API officiel du Coran | Récupérer les récitations et les lecteurs |
| **Hadith CDN API** (`cdn.jsdelivr.net/gh/fawazahmed0/hadith-api`) | Collection complète de hadiths | Récupérer les différents livres de hadiths |
| **Hadith API Legacy** (`api.hadith.gading.dev`) | API alternatif des hadiths | Récupérer les hadiths complets |
| **AlAdhan API** (`api.aladhan.com`) | Horaires de prière | Récupérer les horaires de prière par ville ou localisation |
| **Islamic Finder API** | Informations islamiques | Recherche de villes et horaires de prière |

### 2.2 Sources Supplémentaires

| Source | Description |
|--------|-------------|
| **Archive.org** | Bibliothèque numérique publique | Obtenir les audios de la biographie prophétique (Cheikh Al-Arifi, Cheikh Al-Hawwini) |
| **YouTube API** | Plateforme YouTube | Lecture des vidéos et conférences |
| **Fichiers JSON Locaux** | Fichiers locaux | Données locales (vidéos, invocations, dikrs) |
| **Firebase Firestore** | Base de données cloud | Stockage des données utilisateurs et favoris |

---

## 3. Technologies Utilisées pour la Création du Projet

### 3.1 Technologies de l'Application Principale (Flutter)

#### ✅ Cadre de Travail et Programmation

| Technologie | Version | Utilisation |
|-------------|---------|-------------|
| **Flutter** | 3.x | Cadre de travail principal pour le développement de l'application |
| **Dart** | 3.x | Langage de programmation |
| **Firebase** | 3.11.0 | Services cloud (Auth, Firestore) |
| **Riverpod** | 3.1.0 | Gestion d'état (State Management) |

#### ✅ Bibliothèques Audio et Média

| Bibliothèque | Utilisation |
|--------------|-------------|
| **just_audio** | Lecteur audio avancé |
| **audio_service** | Lecture audio en arrière-plan |
| **audio_session** | Gestion des sessions audio |
| **video_player** | Lecture vidéo |
| **chewie** | Interface du lecteur vidéo |
| **youtube_player_flutter** | Lecture YouTube |
| **youtube_explode_dart** | Exploration YouTube |

#### ✅ Bases de Données et Stockage

| Bibliothèque | Utilisation |
|--------------|-------------|
| **Hive** | Base de données locale rapide |
| **Hive Flutter** | Intégration Hive avec Flutter |
| **SQLite (sqflite)** | Base de données SQL locale |
| **SharedPreferences** | Stockage des paramètres |
| **path_provider** | Accès aux chemins de fichiers |

#### ✅ Réseau et Communication

| Bibliothèque | Utilisation |
|--------------|-------------|
| **Dio** | Client HTTP avancé |
| **http** | Bibliothèque HTTP basique |
| **cached_network_image** | Mise en cache des images |

#### ✅ Localisation et Cartographie

| Bibliothèque | Utilisation |
|--------------|-------------|
| **geolocator** | Localisation géographique |
| **geocoding** | Conversion des coordonnées en adresses |
| **flutter_compass** | Boussole |
| **flutter_local_notifications** | Notifications locales |

#### ✅ Temps et Calendrier

| Bibliothèque | Utilisation |
|--------------|-------------|
| **adhan** | Calcul des horaires de prière |
| **hijri** | Calendrier hégirien |
| **timezone** | Fuseaux horaires |
| **flutter_timezone** | Intégration des fuseaux horaires |

#### ✅ Interface Utilisateur

| Bibliothèque | Utilisation |
|--------------|-------------|
| **google_fonts** | Polices Google |
| **flutter_svg** | Images SVG |
| **shimmer** | Effet de chargement |
| **smooth_page_indicator** | Indicateurs de pages |
| **scrollable_positioned_list** | Liste défilante avec positionnement |
| **go_router** | Navigation entre pages |
| **url_launcher** | Ouverture des liens |
| **share_plus** | Partage |
| **connectivity_plus** | État de la connexion |

#### ✅ Services en Arrière-Plan

| Bibliothèque | Utilisation |
|--------------|-------------|
| **workmanager** | Tâches en arrière-plan |
| **home_widget** | Widgets de l'écran principal |
| **ota_update** | Mise à jour de l'application |

#### ✅ Authentification

| Bibliothèque | Utilisation |
|--------------|-------------|
| **firebase_auth** | Authentification Firebase |
| **google_sign_in** | Connexion Google |
| **permission_handler** | Gestion des permissions |

#### ✅ Outils de Développement

| Outil | Utilisation |
|-------|-------------|
| **build_runner** | Génération de code |
| **json_serializable** | Sérialisation JSON |
| **json_annotation** | Annotations JSON |
| **hive_generator** | Génération des modèles Hive |

### 3.2 Panneau d'Administration (Admin Panel)

| Technologie | Description |
|-------------|-------------|
| **React 19** | Cadre de travail JavaScript |
| **Vite** | Outils de construction |
| **Firebase** | Base de données et authentification |
| **Tailwind CSS 4** | Conception d'interface |
| **React Router** | Navigation |
| **Recharts** | Graphiques |
| **Lucide React** | Icônes |

---

## 4. Structure du Projet

```
islamic_library_flutter/
├── lib/
│   ├── data/
│   │   ├── models/          # Modèles de données
│   │   ├── services/       # Services (API, base de données)
│   │   ├── repositories/   # Dépôts
│   │   └── database/       # Bases de données locales
│   └── presentation/
│       ├── screens/        # Écrans de l'application
│       ├── widgets/        # Composants d'interface
│       └── providers/      # Fournisseurs d'état (Riverpod)
├── admin_panel_v2/          # Panneau d'administration (React)
├── assets/                  # Fichiers locaux
├── ios/                     # Fichiers iOS
├── android/                 # Fichiers Android
└── windows/                # Fichiers Windows
```

---

## 5. Langues Supportées

- 🇸🇦 Arabe (principale)
- 🇬🇧 Anglais
- 🇫🇷 Français (en cours de développement)

---

## 6. Fonctionnalités Principales de l'Application

### ✅ Fonctionnalités Accomplies

1. **Le Saint Coran**
   - Lecture avec calligraphie ottomane et limpide
   - Écoute des famous lecteurs avec téléchargement des audios
   - Tafsir des versets
   - Traduction des versets en anglais
   - Lecture du Coran complet

2. **Les Hadiths**
   - Accès à tous les principaux livres de hadiths
   - Support arabe et anglais
   - Affichage des grades des hadiths

3. **Les Dikrs et Invocations**
   - Dikrs du matin et du soir
   - Dikrs après la prière
   - Diverses invocations
   - Enregistrement des dikrs favoris

4. **La Biographie Prophétique**
   - Diverses conférences audio
   - Support arabe et anglais

5. **Les Horaires de Prière**
   - Détection automatique de la localisation
   - Saisie manuelle de la ville
   - Calcul automatique des horaires
   - Alertes de prière

6. **La Qibla**
   - Boussole intelligente pour la direction de la Qibla

7. **Le Chapelet Électronique**
   - Comptage des glorifications
   - Enregistrement des glorifications

8. **Radio et Télévision**
   - Diffusion en direct des radios islamiques
   - Regarder les chaînes islamiques

9. **Mode Hors Ligne (Offline)**
   - Fonctionnement sans internet pour la plupart des fonctionnalités
   - Téléchargement du contenu pour consultation ultérieure

---

## 7. Informations du Projet

| Information | Valeur |
|-------------|--------|
| **Nom du Projet** | Islam Home (بيت الإسلام) |
| **Nom de l'Étudiant** | Mohamed Dghar |
| **Type de Projet** | Projet de fin d'études |
| **Plateforme** | Flutter (iOS, Android, Windows) |
| **Version Actuelle** | 1.0.2+3 |

---

## 8. Références et Liens

- **Site du Projet**: https://islamhome.vercel.app
- **MP3Quran API**: https://mp3quran.net
- **Quran API**: https://api.quran.cloud
- **Hadith API**: https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api
- **AlAdhan API**: https://api.aladhan.com

---

> [!NOTE]
> Ce projet représente la première version (Beta), et le travail se poursuit pour en faire l'application islamique la plus complète.
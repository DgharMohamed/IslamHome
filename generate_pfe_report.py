#!/usr/bin/env python3
"""
PFE Report Generator for Islam Home Application
Creates a complete academic PFE report in French
"""

from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import os

# Output path
OUTPUT_PATH = r"C:\Users\Batman\Desktop\Portfolio Projects\IslamicLibraryApp\islamic_library_flutter\PFE_IslamHome_Complete.docx"

def set_cell_shading(cell, fill_color):
    """Set cell background color"""
    shading_elm = OxmlElement('w:shd')
    shading_elm.set(qn('w:fill'), fill_color)
    cell._tc.get_or_add_tcPr().append(shading_elm)

def add_page_break(doc):
    """Add a page break"""
    doc.add_page_break()

def create_cover_page(doc):
    """Create the cover page using PAGE DE GARDE PFE 2026 template format"""
    # Top institution logo area
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("OFFICE DE LA FORMATION PROFESSIONNELLE ET DE LA PROMOTION DU TRAVAIL")
    run.bold = True
    run.font.size = Pt(14)
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("GroupeiKi")
    run.bold = True
    run.font.size = Pt(12)
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("—————————————————————")
    run.font.color.rgb = RGBColor(0, 112, 192)
    
    # Add spacing
    for _ in range(3):
        doc.add_paragraph()
    
    # Title
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("RAPPORT DE PROJET DE FIN D'ÉTUDES")
    run.bold = True
    run.font.size = Pt(22)
    run.font.color.rgb = RGBColor(31, 73, 125)
    
    for _ in range(2):
        doc.add_paragraph()
    
    # Project title
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("Islam Home")
    run.bold = True
    run.font.size = Pt(28)
    run.font.color.rgb = RGBColor(0, 112, 192)
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("بيت الإسلام")
    run.bold = True
    run.font.size = Pt(24)
    
    for _ in range(2):
        doc.add_paragraph()
    
    # Subtitle
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("Application Islamique Complète - Flutter / Firebase")
    run.font.size = Pt(14)
    run.italic = True
    
    for _ in range(5):
        doc.add_paragraph()
    
    # Student info
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = p.add_run("Présenté par : ")
    run.bold = True
    run = p.add_run("Mohamed Dghar")
    
    doc.add_paragraph()
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = p.add_run("Encadré par : ")
    run.bold = True
    run = p.add_run("M. Ait Hammou Hatim")
    
    doc.add_paragraph()
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = p.add_run("Filière : ")
    run.bold = True
    run = p.add_run("2ème Année Technicien Spécialisé en Développement Informatique (TSDI)")
    
    doc.add_paragraph()
    
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = p.add_run("Société : ")
    run.bold = True
    run = p.add_run("GroupeiKi / OFPPT")
    
    for _ in range(4):
        doc.add_paragraph()
    
    # Promotion
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run("Promotion 2025-2026")
    run.bold = True
    run.font.size = Pt(16)
    run.font.color.rgb = RGBColor(31, 73, 125)
    
    add_page_break(doc)

def add_remerciements(doc):
    """Add acknowledgments section"""
    p = doc.add_heading("Remerciements", level=1)
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    text = """Au terme de ce travail, je tiens à exprimer ma profonde gratitude envers toutes les personnes qui ont contribué, de près ou de loin, à la réalisation de ce projet de fin d'études.

Je remercie avant tout DIEU le Tout-Puissant de m'avoir donné la force et le courage pour accomplir ce travail.

Je tiens à exprimer ma sincère reconnaissance à mon encadreur M. Ait Hammou Hatim pour sa disponibilité, ses précieux conseils et son soutien tout au long de ce projet.

Mes remerciements s'adressent également à tout le corps enseignant de l'OFPPT - GroupeiKi, pour la qualité de la formation dispensée qui m'a permis d'acquérir les compétences nécessaires.

Enfin, je remercie tous ceux qui ont contribué à l'aboutissement de ce travail, directement ou indirectement."""
    
    doc.add_paragraph(text)
    add_page_break(doc)

def add_resume(doc):
    """Add abstract in French and English"""
    doc.add_heading("Résumé", level=1)
    
    resume_text = """Ce rapport présente le développement de l'application mobile "Islam Home" (بيت الإسلام), une plateforme islamique complète conçue comme projet de fin d'études. L'application offre un accès centralisé aux ressources islamiques essentielles : le Saint Coran avec audio multi-récitants, les Hadiths authentiques, les Adhkar du matin et du soir, les horaires de prière basés sur la géolocalisation, la boussole Qibla, la Sira prophétique, ainsi que la radio et TV islamiques en streaming.

L'application a été développée avec Flutter pour assurer une compatibilité multiplateforme (Android/iOS) et utilise Firebase pourl'authentification et la synchronisation des données. Elle intègre également un mode hors ligne complet permettant aux utilisateurs d'accéder au contenu sans connexion Internet.

Mots-clés : Application mobile, Islam, Flutter, Firebase, Coran, Hadith, Flutter, PFE"""
    
    doc.add_paragraph(resume_text)
    
    doc.add_heading("Abstract", level=1)
    
    abstract_text = """This report presents the development of the mobile application "Islam Home" (بيت الإسلام), a comprehensive Islamic platform designed as a graduation project. The application provides centralized access to essential Islamic resources: the Holy Quran with multi-reciter audio, authentic Hadiths, morning and evening Adhkar (remembrances), GPS-based prayer times, Qibla compass, prophetic biography (Sira), and Islamic radio and TV streaming.

The application was developed using Flutter for cross-platform compatibility (Android/iOS) and Firebase for authentication and data synchronization. It also includes a complete offline mode allowing users to access content without an Internet connection.

Keywords: Mobile Application, Islam, Flutter, Firebase, Quran, Hadith, PFE, Graduation Project"""
    
    doc.add_paragraph(abstract_text)
    add_page_break(doc)

def add_introduction_generale(doc):
    """Add introduction section"""
    doc.add_heading("Introduction Générale", level=1)
    
    intro_text = """Dans un monde de plus en plus connecté, les applications mobiles sont devenues des outils essentiels dans notre vie quotidienne. Le domaine religieux ne fait pas exception à cette règle, car les المسلمين nécessitent un accès facile et permanent aux textes sacrés, aux horaires de prière et aux différentes ressources spirituelles.

La pratique religieuse quotidienne nécessite traditionnellement plusieurs sources différentes : livres physiques pour le Coran et les Hadiths, applications distinctes pour les horaires de prière, etc. Cette fragmentation représente une contrainte significative pour les fidèles желающих avoir un accès unifié à leur ressources spirituelles.

L'application Islam Home (بيت الإسلام) a été conçue pour répondre à ce besoin croissant. Elle offre une plateforme complète regroupant le Saint Coran avec audio de plusieurs récitateurs célèbres, les Hadiths de Sahih Bukhari et de Nawawi, les Adhkar du matin et du soir, les horaires de prière précis basés sur la géolocalisation, la Boussole Qibla pour l'orientation vers La Mecque, la Sira (السيرة النبوية) du Prophète Muhammad ﷺ, la radio et les chaînes TV islamiques en direct, ainsi qu'un mode hors ligne complet.

Ce rapport présente le développement complet de cette application, depuis l'analyse des besoins jusqu'à la réalisation technique, en utilisant les technologies modernes Flutter et Firebase. Nous aborderons dans un premier temps le cadre du projet et l'étude de l'existant, puis l'analyse et la spécification des besoins, la conception de la solution, et enfin la réalisation et la mise en œuvre."""
    
    doc.add_paragraph(intro_text)
    add_page_break(doc)

def add_chapitre1(doc):
    """Add Chapter 1: Project Framework"""
    doc.add_heading("Chapitre 1 : Cadre du Projet et Étude de l'Existant", level=1)
    
    # 1.1 Presentation
    doc.add_heading("1.1 Présentation du Projet", level=2)
    
    p1_text = """Islam Home est une application mobile développée dans le cadre du projet de fin d'études (PFE) pour l'obtention du diplôme de Technicien Spécialisé en Développement Informatique (TSDI) au sein de l'OFPPT - GroupeiKi. Ce projet représente une opportunité de mettre en pratique les connaissances acquises durant la formation tout en répondant à un besoin réel de la communauté musulmane."""
    doc.add_paragraph(p1_text)
    
    # 1.2 Objectifs
    doc.add_heading("1.2 Objectifs du Projet", level=2)
    
    obj_text = """L'objectif principal de ce projet est de créer une application islamique complète et intuitive qui permet aux المستخدمين d'accéder facilement à l'ensemble des ressources religieuses dont ils ont besoin dans leur vie quotidienne. Plus spécifiquement, le projet vise à :"""
    doc.add_paragraph(obj_text)
    
    objectives = [
        "Offrir un accès centralisé à toutes les ressources islamiques dans une seule application",
        "Proposer une lecture du Coran avec plusieurs récits audio de récitatateurs célèbre",
        "Permettre la consultation des Hadiths authentiques de Sahih Bukhari et des 40 de Nawawi",
        "Fournir des horaires de prière précis basés sur la localisation GPS de l'utilisateur",
        "Inclure une boussole Qibla fonctionnelle pour l'orientation vers La Mecque",
        "Proposer un accès à la Sira (السيرة النبوية) du Prophète Muhammad ﷺ",
        "Supporter le mode hors ligne pour toutes les fonctionnalités principales",
        "Offrir une interface multilingue (Arabe, Anglais, Français)"
    ]
    
    for obj in objectives:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(obj)
    
    # 1.3 Etude de l'existant
    doc.add_heading("1.3 Étude de l'Existant", level=2)
    
    etude_text = """Plusieurs applications islamiques existent actuellement sur le marché, chacune offrant des fonctionnalités spécifiques. Parmi les plus conhecidas, on peut citer :"""
    doc.add_paragraph(etude_text)
    
    apps = [
        "Muslim Pro : Application populaire pour les horaires de prière et le Coran",
        "Al-Moazin : Horaires de prière sans connexion",
        "Sahih Bukhari : Recueil de hadiths complet",
        "Athan : Alertes pour les prières"
    ]
    
    for app in apps:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(app)
    
    doc.add_paragraph("""Cependant, ces applications présentent généralement les limitations suivantes :""")
    
    limitations = [
        "Fragmentation des contenus : Différentes applications nécessaires pour différentes fonctionnalités",
        "Présence de publicités intrusives qui perturbent l'expérience utilisateur",
        "Interfaces utilisateur peu intuitives ou dépassées",
        "Absence de mode hors ligne complet pour toutes les fonctionnalités",
        "Manque de support multilingue satisfaisant (Arabe, Anglais, Français)"
    ]
    
    for lim in limitations:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(lim)
    
    # 1.4 Solution proposee
    doc.add_heading("1.4 Solution Proposée", level=2)
    
    sol_text = """Islam Home se distingue par son approche tout-en-un qui regroupe toutes les fonctionnalités islamiques dans une seule application élégante et performante. Les principaux avantages de notre solution sont :"""
    doc.add_paragraph(sol_text)
    
    avantages = [
        "Application tout-en-un : Un seul téléchargement pour accéder à toutes les ressources",
        "Interface moderne : Design élégant respectant les guidelines Material Design",
        "Mode hors ligne complet : Accès sans connexion Internet à toutes les fonctionnalités principales",
        "Support multilingue : Interface complète en Arabe, Anglais et Français",
        "Audio de qualité : Plusieurs récits famous avec possibilité de téléchargement",
        "Notifications intelligentes : Rappels pour les prières et les Adhkar"
    ]
    
    for av in avantages:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(av)
    
    add_page_break(doc)

def add_chapitre2(doc):
    """Add Chapter 2: Requirements Analysis"""
    doc.add_heading("Chapitre 2 : Analyse et Spécification des Besoins", level=1)
    
    # 2.1 Besoins fonctionnels
    doc.add_heading("2.1 Besoins Fonctionnels", level=2)
    
    bf_text = """L'application Islam Home doit permettre les fonctionnalités fonctionnelles suivantes :"""
    doc.add_paragraph(bf_text)
    
    # Create table for functional requirements
    table = doc.add_table(rows=13, cols=3)
    table.style = 'Table Grid'
    
    # Header row
    header_cells = table.rows[0].cells
    header_cells[0].text = "Code"
    header_cells[1].text = "Description"
    header_cells[2].text = "Priorité"
    
    for cell in header_cells:
        set_cell_shading(cell, "2F5496")
        for paragraph in cell.paragraphs:
            for run in paragraph.runs:
                run.font.color.rgb = RGBColor(255, 255, 255)
                run.bold = True
    
    requirements = [
        ("FF-01", "Consultation du Coran avec navigation par sourates et pages du mushaf", "Haute"),
        ("FF-02", "Écoute audio du Coran avec plusieurs récits célèbre", "Haute"),
        ("FF-03", "Accès aux traductions anglaises et tafsir des versets", "Moyenne"),
        ("FF-04", "Consultation des hadiths de Sahih Bukhari et des 40 Nawawi", "Haute"),
        ("FF-05", "Catégories d'Adhkar avec favoris et notifications", "Haute"),
        ("FF-06", "Calcul des horaires de prière selon plusieurs méthodes", "Haute"),
        ("FF-07", "Boussole Qibla avec direction précise", "Moyenne"),
        ("FF-08", "Audio de la Sira prophétique", "Moyenne"),
        ("FF-09", "Radio islamique et streaming TV en direct", "Basse"),
        ("FF-10", "Téléchargement du contenu pour usage hors ligne", "Haute"),
        ("FF-11", "Authentification utilisateur via Firebase", "Moyenne"),
        ("FF-12", "Support multilingue (Arabe, Anglais, Français)", "Haute")
    ]
    
    for i, (code, desc, prio) in enumerate(requirements):
        row = table.rows[i + 1]
        row.cells[0].text = code
        row.cells[1].text = desc
        row.cells[2].text = prio
    
    doc.add_paragraph()  # spacing
    
    # 2.2 Besoins non fonctionnels
    doc.add_heading("2.2Besoins Non Fonctionnels", level=2)
    
    bnf_text = """Au-delà des fonctionnalités, l'application doit respecter les exigences non fonctionnelles suivantes :"""
    doc.add_paragraph(bnf_text)
    
    bnf_items = [
        ("Performance", "Temps de chargement initial inférieur à 3 secondes, navigation fluide entre les écrans"),
        ("Sécurité", "Authentification Firebase sécurisée, chiffrement des données sensibles"),
        ("Ergonomie", "Interface intuitive conforme aux guidelines Material Design 3"),
        ("Compatibilité", "Support Android 5.0+ (API 21) et iOS 12.0+"),
        ("Accessibilité", "Support complet RTL pour la langue arabe"),
        ("Fiabilité", "Mode hors ligne stable avec synchronisation automatique")
    ]
    
    for title, desc in bnf_items:
        p = doc.add_paragraph()
        run = p.add_run(f"{title} : ")
        run.bold = True
        p.add_run(desc)
    
    # 2.3 Diagramme de cas d'utilisation
    doc.add_heading("2.3 Diagramme de Cas d'Utilisation", level=2)
    
    uc_text = """Le diagramme de cas d'utilisation ci-dessous présente les principaux acteurs et leurs interactions avec le système Islam Home."""
    doc.add_paragraph(uc_text)
    
    doc.add_paragraph("""Acteurs :
• Utilisateur : Personne utilisant l'application pour accéder aux ressources islamiques
• Administrateur : Personne gérant le contenu et les utilisateurs (via Firebase Console)

Cas d'utilisation principaux :
• Consulter le Coran (lecture et écoute)
• Naviguer dans les sourates et pages du mushaf
• Lire un hadith
• Consulter les Adhkar
• Voir les horaires de prière
• Utiliser la boussole Qibla
• Écouter la Sira
• Gérer son profil utilisateur
• Télécharger du contenu pour usage hors ligne
• Partager du contenu sur les réseaux sociaux""")
    
    add_page_break(doc)

def add_chapitre3(doc):
    """Add Chapter 3: Design"""
    doc.add_heading("Chapitre 3 : Conception de la Solution", level=1)
    
    # 3.1 Architecture
    doc.add_heading("3.1 Architecture Logicielle", level=2)
    
    arch_text = """L'application Islam Home adopte une architecture Clean Architecture avec une séparation claire des responsabilités. Cette approche permet de maintenir un code propre, testable et évolutif."""
    doc.add_paragraph(arch_text)
    
    doc.add_paragraph("""Structure du projet (lib/) :

• core/ : Configuration centrale de l'application
  - theme/ : Définition des thèmes et styles
  - utils/ : Utilitaires et fonctions helpers
  - services/ : Services communs (connectivité, mise à jour)

• data/ : Couche de données
  - models/ : Classes de données avec sérialisation JSON
  - services/ : Logique métier et appels API
  - repositories/ : Pattern repository pour l'accès aux données
  - database/ : Configuration de la base de données locale Hive

• presentation/ : Couche de présentation
  - screens/ : Écrans principaux de l'application
  - widgets/ : Composants UI réutilisables
  - providers/ : Gestion d'état avec Riverpod

• l10n/ : Fichiers de localisation""")
    
    # 3.2 Technologies
    doc.add_heading("3.2 Technologies et Outils Utilisés", level=2)
    
    tech_text = """L'application a été développée en utilisant les technologies suivantes :"""
    doc.add_paragraph(tech_text)
    
    # Technology table
    table = doc.add_table(rows=12, cols=3)
    table.style = 'Table Grid'
    
    header_cells = table.rows[0].cells
    header_cells[0].text = "Technologie"
    header_cells[1].text = "Version"
    header_cells[2].text = "Description"
    
    for cell in header_cells:
        set_cell_shading(cell, "2F5496")
        for paragraph in cell.paragraphs:
            for run in paragraph.runs:
                run.font.color.rgb = RGBColor(255, 255, 255)
                run.bold = True
    
    technologies = [
        ("Flutter", "3.x", "Framework UI multiplateforme"),
        ("Dart", "3.x", "Langage de programmation"),
        ("Firebase", "11.x", "Backend as a Service (Auth, Firestore)"),
        ("Riverpod", "3.x", "State management réactif"),
        ("just_audio", "0.9.x", "Lecture audio avancée"),
        ("geolocator", "13.x", "Services de localisation GPS"),
        ("adhan", "2.x", "Calcul des horaires de prière"),
        ("Hive", "2.x", "Base de données locale NoSQL"),
        ("go_router", "17.x", "Navigation déclarative"),
        ("flutter_riverpod", "3.x", "State management"),
        ("firebase_core", "3.x", "Intégration Firebase")
    ]
    
    for i, (tech, ver, desc) in enumerate(technologies):
        row = table.rows[i + 1]
        row.cells[0].text = tech
        row.cells[1].text = ver
        row.cells[2].text = desc
    
    doc.add_paragraph()
    
    # 3.3 Conception de la base de donnees
    doc.add_heading("3.3 Conception de la Base de Données", level=2)
    
    db_text = """L'application utilise deux types de stockage de données complémentaires :"""
    doc.add_paragraph(db_text)
    
    doc.add_paragraph("""Firestore (Firebase Cloud Firestore) :
• Authentification des utilisateurs (Firebase Auth)
• Stockage des préférences utilisateur synchronisées
• Données de Khatma (suivi de lecture du Coran)
• Configuration système à distance

Base de données Hive (locale) :
• Cache des données du Coran
• Collection d'Adhkar et Hadiths
• Paramètres utilisateur locaux
• Historique Tasbeeh
• État de téléchargement du contenu""")
    
    add_page_break(doc)

def add_chapitre4(doc):
    """Add Chapter 4: Implementation"""
    doc.add_heading("Chapitre 4 : Réalisation et Mise en Œuvre", level=1)
    
    # 4.1 Environnement
    doc.add_heading("4.1 Environnement de Travail", level=2)
    
    env_table = doc.add_table(rows=7, cols=2)
    env_table.style = 'Table Grid'
    
    env_data = [
        ("Composant", "Spécification"),
        ("IDE", "VS Code, Android Studio"),
        ("Système d'exploitation", "Windows 11"),
        ("Flutter SDK", "3.x"),
        ("Dart SDK", "3.x"),
        ("Android SDK", "API 21+"),
        ("Base de données", "Firebase Firestore, Hive")
    ]
    
    for i, (comp, spec) in enumerate(env_data):
        row = env_table.rows[i]
        row.cells[0].text = comp
        row.cells[1].text = spec
        if i == 0:
            for cell in row.cells:
                set_cell_shading(cell, "2F5496")
                for paragraph in cell.paragraphs:
                    for run in paragraph.runs:
                        run.font.color.rgb = RGBColor(255, 255, 255)
                        run.bold = True
    
    doc.add_paragraph()
    
    # 4.2 Modules developpes
    doc.add_heading("4.2 Modules Développés", level=2)
    
    modules_text = """Les principaux modules fonctionnels développés dans l'application :"""
    doc.add_paragraph(modules_text)
    
    modules = [
        ("Module Quran (القرآن الكريم)", "Interface mushaf interactive, navigation par sourates et pages, audio multi-récitants ( Mishary Alafasy, Abdul Basit, etc.), traductions anglaise et française, tafsir, support des différentes rijāḥ (Uthmanic Hafs, Warsh)"),
        ("Module Adhkar (الأذكار)", "Catégories complètes (matin, soir, sommeil, réveil), liste de favoris, notifications programmées, compteur de tasbeeh intégré"),
        ("Module Hadith (الحديث)", "Sahih Bukhari complet, 40 Nawawi, 40 Qudsi, possibilité de partage sur les réseaux sociaux"),
        ("Module Horaires de Prière (مواقيت الصلاة)", "Calcul précis basé sur la localisation GPS, plusieurs méthodes de calcul (MWL, ISNA, Égypte), paramètres ajustables"),
        ("Module Qibla (القبلة)", "Boussole interactive avec animation, direction précise vers La Mecque"),
        ("Module Sira (السيرة النبوية)", "Contenu audio biographique du Prophète Muhammad ﷺ"),
        ("Module Radio/TV", "Streaming de stations radio islamiques, chaînes TV en direct"),
        ("Module Authentification", "Inscription/connexion via Firebase Auth, Google Sign-In"),
        ("Module Téléchargement", "Téléchargement du contenu audio pour usage hors ligne, gestion des fichiers")
    ]
    
    for title, desc in modules:
        p = doc.add_paragraph()
        run = p.add_run(f"• {title}")
        run.bold = True
        doc.add_paragraph(f"  {desc}")
    
    # 4.3 Capture d'ecran
    doc.add_heading("4.3 Captures d'Écran", level=2)
    
    ss_text = """Les figures suivantes présentent les principales interfaces de l'application Islam Home :"""
    doc.add_paragraph(ss_text)
    
    ss_list = [
        "Figure 1 : Page d'accueil - Écran principal avec accès à toutes les fonctionnalités",
        "Figure 2 : Module Quran - Lecture du Coran avec options de navigation",
        "Figure 3 : Liste des récitateurs - Sélection du récitateur pour l'écoute audio",
        "Figure 4 : Module Adhkar - Catégories et comptage du tasbeeh",
        "Figure 5 : Sira prophétique - Contenu audio de la biographie du Prophète ﷺ",
        "Figure 6 : Profil utilisateur - Gestion du compte et préférences"
    ]
    
    for ss in ss_list:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(ss)
    
    add_page_break(doc)

def add_conclusion(doc):
    """Add general conclusion"""
    doc.add_heading("Conclusion Générale", level=1)
    
    conc_text = """Le projet Islam Home représente une contribution significative au domaine des applications islamiques mobiles. L'application combine richesse fonctionnelle, qualité d'expérience utilisateur et performance technique."""
    doc.add_paragraph(conc_text)
    
    # Bilan
    doc.add_heading("Bilan du Travail", level=2)
    
    bilan_text = """Ce projet a permis de mettre en pratique les connaissances acquises durant la formation TSDI, notamment en :
• Développement d'applications mobiles avec Flutter
• Architecture logicielle propre (Clean Architecture)
• Gestion d'état avec Riverpod
• Intégration Firebase
• Stockage local avec Hive
• Conception d'interfaces utilisateur
• Tests et validation"""
    doc.add_paragraph(bilan_text)
    
    # Difficultes
    doc.add_heading("Difficultés Rencontrées", level=2)
    
    difficulties = [
        "Gestion de la complexité du contenu Coranique avec support de plusieurs rijāḥ",
        "Synchronisation hors ligne avec la base de données locale Hive",
        "Calcul précis des horaires de prière selon les différentes écoles jurisprudentielles",
        "Support RTL complet pour l'interface arabe avec mix LTR/RTL",
        "Intégration des flux audio et vidéo en streaming"
    ]
    
    for d in difficulties:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(d)
    
    # Perspectives
    doc.add_heading("Perspectives d'Évolution", level=2)
    
    perspectives = [
        "Ajout de nouvelles langues (Turc, Indonésien, Ourdou)",
        "Fonctionnalité de Khatma collaborative entre utilisateurs",
        "Intégration de contenu éducatif adapté aux enfants",
        "Mode sombre/clair complet avecPersonnalisation",
        "Widget d'écran d'accueil pour les horaires de prière",
        "Notifications push pour les rappel de prières et Adhkar"
    ]
    
    for p_item in perspectives:
        p = doc.add_paragraph(style='List Bullet')
        p.add_run(p_item)
    
    add_page_break(doc)

def add_bibliographie(doc):
    """Add references"""
    doc.add_heading("Références", level=1)
    
    refs = [
        "[1] Flutter Documentation. https://docs.flutter.dev",
        "[2] Firebase Documentation. https://firebase.google.com/docs",
        "[3] Riverpod Documentation. https://riverpod.dev",
        "[4] Adhan Dart Library. https://github.com/astronoid/adhan-dart",
        "[5] Quran.com API. https://api.quran.com",
        "[6] Al-Quran Cloud API. https://alquran.cloud/api",
        "[7] Hive Database. https://docs.hivedb.dev",
        "[8] just_audio Package. https://pub.dev/packages/just_audio"
    ]
    
    for ref in refs:
        doc.add_paragraph(ref)
    
    add_page_break(doc)

def create_pfe_report():
    """Main function to create the complete PFE report"""
    doc = Document()
    
    # Set default font for the document
    style = doc.styles['Normal']
    font = style.font
    font.name = 'Times New Roman'
    font.size = Pt(12)
    
    # Set page margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Cm(2.5)
        section.bottom_margin = Cm(2.5)
        section.left_margin = Cm(2.5)
        section.right_margin = Cm(2.5)
    
    # Create cover page
    create_cover_page(doc)
    
    # Add preliminary pages
    add_remerciements(doc)
    add_resume(doc)
    
    # Add main content
    add_introduction_generale(doc)
    add_chapitre1(doc)
    add_chapitre2(doc)
    add_chapitre3(doc)
    add_chapitre4(doc)
    
    # Add conclusion
    add_conclusion(doc)
    
    # Add bibliography
    add_bibliographie(doc)
    
    # Save document
    doc.save(OUTPUT_PATH)
    print(f"Report created successfully: {OUTPUT_PATH}")
    return OUTPUT_PATH

if __name__ == "__main__":
    create_pfe_report()
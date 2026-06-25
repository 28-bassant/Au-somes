"""
Generate comprehensive graduation project documentation for Au-somes Flutter app.
Output: docs/Au-somes_Software_Documentation_Report.docx
"""

import os
from datetime import datetime

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
from docx import Document
from docx.shared import Inches, Pt, RGBColor, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
DOCS_DIR = os.path.join(PROJECT_ROOT, "docs")
DIAGRAMS_DIR = os.path.join(DOCS_DIR, "diagrams")
OUTPUT_FILE = os.path.join(DOCS_DIR, "Au-somes_Software_Documentation_Report.docx")

os.makedirs(DIAGRAMS_DIR, exist_ok=True)


def set_cell_shading(cell, color_hex):
    shading = OxmlElement("w:shd")
    shading.set(qn("w:fill"), color_hex)
    cell._tc.get_or_add_tcPr().append(shading)


def add_table(doc, headers, rows, header_color="2E5C8A"):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_cells = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr_cells[i].text = h
        set_cell_shading(hdr_cells[i], header_color)
        for p in hdr_cells[i].paragraphs:
            for run in p.runs:
                run.font.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
                run.font.size = Pt(10)
    for r_idx, row in enumerate(rows):
        row_cells = table.rows[r_idx + 1].cells
        for c_idx, val in enumerate(row):
            row_cells[c_idx].text = str(val)
            for p in row_cells[c_idx].paragraphs:
                for run in p.runs:
                    run.font.size = Pt(9)
    doc.add_paragraph()
    return table


def add_heading(doc, text, level=1):
    h = doc.add_heading(text, level=level)
    for run in h.runs:
        run.font.color.rgb = RGBColor(46, 92, 138)
    return h


def add_body(doc, text):
    p = doc.add_paragraph(text)
    p.paragraph_format.space_after = Pt(8)
    p.paragraph_format.line_spacing = 1.15
    return p


def create_architecture_diagram():
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis("off")
    ax.set_title("Au-somes System Architecture", fontsize=14, fontweight="bold", pad=15)

    layers = [
        (1, 6.5, 10, 1.2, "#E8F4FD", "Presentation Layer (Flutter UI)"),
        (1, 4.8, 10, 1.2, "#D4EDDA", "State & Local Storage Layer"),
        (1, 3.1, 10, 1.2, "#FFF3CD", "Service Layer (API Manager)"),
        (1, 1.4, 10, 1.2, "#F8D7DA", "Backend API (ASP.NET)"),
    ]
    for x, y, w, h, color, label in layers:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.05", facecolor=color, edgecolor="#333", linewidth=1.5)
        ax.add_patch(box)
        ax.text(x + w / 2, y + h / 2, label, ha="center", va="center", fontsize=11, fontweight="bold")

    components = [
        (1.5, 6.7, "Auth Screens"),
        (3.5, 6.7, "Parent Module"),
        (5.5, 6.7, "Child Activities"),
        (7.5, 6.7, "Localization"),
        (9.5, 6.7, "Custom Widgets"),
        (2, 5.0, "Provider\n(AppLanguage)"),
        (4.5, 5.0, "SharedPreferences\n(Tokens, Chat, Routine)"),
        (7, 5.0, "StatefulWidget\n(Local UI State)"),
        (9.5, 5.0, "RouteObserver"),
        (3, 3.3, "ApiManager"),
        (6, 3.3, "TokenUtils"),
        (9, 3.3, "HTTP Client"),
        (3, 1.6, "Auth API"),
        (5.5, 1.6, "Activity API"),
        (8, 1.6, "Chat API"),
        (10, 1.6, "Profile API"),
    ]
    for x, y, text in components:
        ax.text(x, y, text, ha="center", va="center", fontsize=8, bbox=dict(boxstyle="round,pad=0.3", facecolor="white", edgecolor="#666"))

    for y_start, y_end in [(6.5, 6.0), (4.8, 4.3), (3.1, 2.6)]:
        ax.annotate("", xy=(6, y_end), xytext=(6, y_start), arrowprops=dict(arrowstyle="->", color="#555", lw=2))

    path = os.path.join(DIAGRAMS_DIR, "architecture.png")
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close()
    return path


def create_auth_flow_diagram():
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis("off")
    ax.set_title("Authentication Flow", fontsize=14, fontweight="bold", pad=15)

    boxes = [
        (3.5, 9, "App Launch"),
        (3.5, 7.5, "Splash Screen\n(Token Check)"),
        (0.5, 6, "No Token\n→ Login"),
        (6.5, 6, "Valid Token\n→ Child Screen"),
        (3.5, 4.5, "Token Expired?\n→ Refresh"),
        (0.5, 3, "Refresh Failed\n→ Login"),
        (6.5, 3, "Refresh OK\n→ Child Screen"),
        (3.5, 1.5, "Login / Register\n→ Save JWT"),
    ]
    for x, y, text in boxes:
        box = FancyBboxPatch((x, y), 3, 0.9, boxstyle="round,pad=0.05", facecolor="#E8F4FD", edgecolor="#2E5C8A", linewidth=1.5)
        ax.add_patch(box)
        ax.text(x + 1.5, y + 0.45, text, ha="center", va="center", fontsize=8)

    arrows = [
        ((5, 9), (5, 8.4)),
        ((5, 7.5), (2, 6.9)),
        ((5, 7.5), (8, 6.9)),
        ((5, 7.5), (5, 5.4)),
        ((5, 4.5), (2, 3.9)),
        ((5, 4.5), (8, 3.9)),
        ((2, 6), (5, 2.4)),
        ((8, 6), (5, 2.4)),
    ]
    for start, end in arrows:
        ax.annotate("", xy=end, xytext=start, arrowprops=dict(arrowstyle="->", color="#333", lw=1.5))

    path = os.path.join(DIAGRAMS_DIR, "auth_flow.png")
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close()
    return path


def create_user_flow_diagram():
    fig, ax = plt.subplots(figsize=(12, 9))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis("off")
    ax.set_title("User Flow Diagram", fontsize=14, fontweight="bold", pad=15)

    def box(x, y, w, h, text, color="#E8F4FD"):
        b = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.05", facecolor=color, edgecolor="#2E5C8A", linewidth=1.2)
        ax.add_patch(b)
        ax.text(x + w / 2, y + h / 2, text, ha="center", va="center", fontsize=7.5)

    box(4.5, 9, 3, 0.7, "Select Screen\n(Parent / Child)")
    box(1, 7.2, 4, 0.8, "Parent Dashboard", "#D4EDDA")
    box(7, 7.2, 4, 0.8, "Child Dashboard", "#FFF3CD")

    parent_items = ["Home Tab", "Notifications", "Search Centers", "Profile"]
    for i, item in enumerate(parent_items):
        box(0.5 + i * 2.8, 5.5, 2.4, 0.7, item, "#D4EDDA")

    child_items = ["Spatial Concepts", "Spatial Relations", "Visual Spatial\nPerception"]
    for i, item in enumerate(child_items):
        box(6.5 + i * 1.8, 5.5, 1.6, 0.9, item, "#FFF3CD")

    home_features = ["Chatbot", "Progress", "Daily Tips", "Daily Routine"]
    for i, item in enumerate(home_features):
        box(0.3 + i * 2.5, 3.5, 2.2, 0.6, item)

    concepts = ["Up/Down", "Front/Back", "Inside/Outside", "Right/Left", "Near/Far", "Between"]
    for i, item in enumerate(concepts):
        box(5.5 + (i % 3) * 2, 3.5 - (i // 3) * 1.2, 1.8, 0.6, item, "#FFF3CD")

    ax.annotate("", xy=(6, 8.4), xytext=(6, 9), arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.annotate("", xy=(3, 8), xytext=(5.5, 8.9), arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.annotate("", xy=(9, 8), xytext=(6.5, 8.9), arrowprops=dict(arrowstyle="->", lw=1.5))

    path = os.path.join(DIAGRAMS_DIR, "user_flow.png")
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close()
    return path


def create_data_flow_diagram():
    fig, ax = plt.subplots(figsize=(11, 6))
    ax.set_xlim(0, 11)
    ax.set_ylim(0, 6)
    ax.axis("off")
    ax.set_title("Activity Data Flow", fontsize=14, fontweight="bold", pad=15)

    entities = [
        (0.5, 2.5, 2.5, 1.5, "Child Activity\nScreen", "#E8F4FD"),
        (4, 2.5, 2.5, 1.5, "ApiManager\n.getActivity()", "#FFF3CD"),
        (7.5, 2.5, 2.5, 1.5, "Backend API\n(Activity Service)", "#F8D7DA"),
        (0.5, 0.3, 2.5, 1.2, "ActivityResponse\nModel", "#D4EDDA"),
        (4, 0.3, 2.5, 1.2, "ActivityElement\n(Drag & Drop UI)", "#D4EDDA"),
        (7.5, 0.3, 2.5, 1.2, "Audio + Images\n+ Positions", "#D4EDDA"),
    ]
    for x, y, w, h, label, color in entities:
        box = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.05", facecolor=color, edgecolor="#333", linewidth=1.2)
        ax.add_patch(box)
        ax.text(x + w / 2, y + h / 2, label, ha="center", va="center", fontsize=9)

    ax.annotate("activityId, level, stage", xy=(4, 3.25), xytext=(3, 3.25), arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.annotate("JSON Response", xy=(7.5, 3.25), xytext=(6.5, 3.25), arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.annotate("Parse & Render", xy=(1.75, 1.5), xytext=(1.75, 2.5), arrowprops=dict(arrowstyle="->", lw=1.5))

    path = os.path.join(DIAGRAMS_DIR, "data_flow.png")
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close()
    return path


def create_folder_structure_diagram():
    fig, ax = plt.subplots(figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis("off")
    ax.set_title("Project Folder Structure (lib/)", fontsize=14, fontweight="bold", pad=15)

    structure = """Au-somes/
├── lib/
│   ├── main.dart
│   ├── api/              (API constants, endpoints, manager)
│   ├── core/cache/       (SharedPreferences, JWT tokens)
│   ├── custom_widgets/   (Reusable UI components)
│   ├── l10n/             (English & Arabic localization)
│   ├── models/           (Data models & DTOs)
│   ├── providers/        (AppLanguageProvider)
│   ├── splash_screen/
│   ├── ui/
│   │   ├── auth/         (Login, Register, Forgot Password)
│   │   ├── select_screen/
│   │   ├── parent_screen/  (Home, Notifications, Search, Profile)
│   │   └── child_screen/     (150+ therapeutic activities)
│   └── utils/            (Routes, theme, styles, assets)
├── assets/
│   ├── images/
│   ├── sounds/
│   └── data/centers.json
├── android/ | ios/ | web/ | windows/
└── pubspec.yaml"""

    ax.text(0.5, 9.5, structure, fontsize=9, family="monospace", va="top",
            bbox=dict(boxstyle="round,pad=0.5", facecolor="#F5F5F5", edgecolor="#2E5C8A"))

    path = os.path.join(DIAGRAMS_DIR, "folder_structure.png")
    plt.tight_layout()
    plt.savefig(path, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close()
    return path


def build_document():
    doc = Document()

    # Title page
    title = doc.add_heading("Au-somes", 0)
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    for run in title.runs:
        run.font.color.rgb = RGBColor(46, 92, 138)
        run.font.size = Pt(36)

    subtitle = doc.add_paragraph("Comprehensive Software Documentation Report")
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    subtitle.runs[0].font.size = Pt(18)
    subtitle.runs[0].font.bold = True

    desc = doc.add_paragraph(
        "An Electronic Application for Developing Visual-Spatial Perception Skills\n"
        "for Children with Mild Autism and Asperger Syndrome"
    )
    desc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    desc.runs[0].font.size = Pt(12)
    desc.runs[0].italic = True

    meta = doc.add_paragraph(f"\nGraduation Project Documentation\nGenerated: {datetime.now().strftime('%B %d, %Y')}")
    meta.alignment = WD_ALIGN_PARAGRAPH.CENTER
    meta.runs[0].font.size = Pt(11)

    doc.add_page_break()

    # Table of Contents placeholder
    add_heading(doc, "Table of Contents", 1)
    toc_items = [
        "1. Project Introduction", "2. Problem Statement", "3. Solution Overview",
        "4. Project Architecture", "5. Folder Structure", "6. Packages and Dependencies",
        "7. Authentication System", "8. User Roles", "9. Features",
        "10. Screen-by-Screen Explanation", "11. API Integration",
        "12. Models and Data Structures", "13. Localization System",
        "14. State Management", "15. Notifications", "16. Google Maps Integration",
        "17. User Flow", "18. Future Enhancements",
    ]
    for item in toc_items:
        doc.add_paragraph(item, style="List Number")

    doc.add_page_break()

    # Generate diagrams
    arch_img = create_architecture_diagram()
    auth_img = create_auth_flow_diagram()
    user_img = create_user_flow_diagram()
    data_img = create_data_flow_diagram()
    folder_img = create_folder_structure_diagram()

    # 1. Project Introduction
    add_heading(doc, "1. Project Introduction", 1)
    add_body(doc,
        "Au-somes (au_somes) is a cross-platform mobile application developed using the Flutter framework. "
        "The application is designed as a therapeutic and educational tool targeting children diagnosed with "
        "mild autism spectrum disorder (ASD) and Asperger syndrome. Its primary objective is to develop and "
        "strengthen visual-spatial perception skills through structured, interactive, gamified activities."
    )
    add_body(doc,
        "The application serves two distinct user personas: parents/caregivers who need guidance, resources, "
        "and progress tracking tools; and children who engage directly with spatial learning activities. "
        "The app supports bilingual operation in both English and Arabic, making it accessible to a broad "
        "audience in the Middle East and internationally."
    )
    add_body(doc,
        "Technical stack: Flutter (Dart SDK ^3.8.1), Provider for global state, REST API backend hosted at "
        "http://au-somes.runasp.net (ASP.NET), SharedPreferences for local persistence, and Flutter's "
        "built-in internationalization (ARB) system for localization."
    )

    add_table(doc, ["Attribute", "Value"], [
        ["Project Name", "au_somes (Au-somes)"],
        ["Version", "1.0.0+1"],
        ["Platform", "Android, iOS, Web, Windows, Linux, macOS"],
        ["Backend URL", "http://au-somes.runasp.net"],
        ["Languages", "English (en), Arabic (ar)"],
        ["Source Files", "~232 Dart files in lib/"],
        ["Target Users", "Children (4–12) with mild ASD/Asperger; Parents/Caregivers"],
    ])

    # 2. Problem Statement
    add_heading(doc, "2. Problem Statement", 1)
    add_body(doc,
        "Children with mild autism and Asperger syndrome frequently experience deficits in visual-spatial "
        "perception — the ability to understand and mentally manipulate objects in space. These deficits "
        "can affect daily functioning including navigation, object placement, understanding spatial "
        "relationships (above/below, inside/outside, near/far), and completing academic tasks requiring "
        "spatial reasoning."
    )
    add_body(doc,
        "Traditional therapeutic interventions for spatial skills often require in-person sessions with "
        "specialized therapists, which can be costly, geographically limited, and difficult to sustain "
        "consistently at home. Parents and caregivers frequently lack accessible, structured tools to "
        "reinforce therapeutic exercises between professional sessions."
    )
    add_body(doc,
        "Key challenges addressed by Au-somes:"
    )
    challenges = [
        "Limited access to specialized spatial perception therapy resources",
        "Lack of engaging, child-friendly digital tools tailored for ASD learners",
        "Absence of parent support features (guidance, routines, center finder)",
        "Need for bilingual (Arabic/English) therapeutic content",
        "Difficulty tracking child progress in spatial skill development",
        "Geographic barriers to finding nearby autism support centers",
    ]
    for c in challenges:
        doc.add_paragraph(c, style="List Bullet")

    # 3. Solution Overview
    add_heading(doc, "3. Solution Overview", 1)
    add_body(doc,
        "Au-somes provides a comprehensive digital solution combining therapeutic child activities with "
        "a parent support portal. The child module delivers over 150 interactive drag-and-drop activities "
        "organized into three major skill domains: Spatial Concepts, Spatial Relations, and Visual Spatial "
        "Perception. Activities are dynamically loaded from a backend API, ensuring content can be updated "
        "without app redeployment."
    )
    add_body(doc,
        "The parent module offers an AI-powered chatbot for autism-related Q&A, daily behavioral tips, "
        "structured daily routines with checklists, progress tracking dashboards, a directory of autism "
        "support centers with distance-based filtering, and profile management. Positive reinforcement "
        "mechanisms (confetti animations, audio feedback, 'Well Done' overlays) motivate children during "
        "activity completion."
    )

    add_table(doc, ["Module", "Purpose", "Key Technology"], [
        ["Child Activities", "Therapeutic spatial skill training", "REST API + Drag-and-Drop UI"],
        ["Parent Portal", "Caregiver support and resources", "Chatbot API + Local JSON"],
        ["Authentication", "Secure account management", "JWT + Refresh Tokens"],
        ["Localization", "Bilingual accessibility", "Flutter ARB + Provider"],
        ["Center Finder", "Locate nearby autism centers", "Geolocator + Google Maps URL"],
    ])

    # 4. Project Architecture
    add_heading(doc, "4. Project Architecture", 1)
    add_body(doc,
        "The application follows a layered, feature-based architecture. The presentation layer contains "
        "all UI screens organized by feature modules (auth, parent, child). The state layer combines "
        "Provider (global language state) with StatefulWidget local state and SharedPreferences persistence. "
        "The service layer centralizes all HTTP communication through a static ApiManager class. The backend "
        "layer is a RESTful ASP.NET API providing authentication, activity content, and chatbot services."
    )
    doc.add_picture(arch_img, width=Inches(6.5))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_body(doc, "Figure 1: System Architecture Diagram")

    add_table(doc, ["Layer", "Components", "Responsibility"], [
        ["Presentation", "Screens, Widgets, Custom Widgets", "UI rendering and user interaction"],
        ["State", "Provider, setState, SharedPreferences", "App state and local data persistence"],
        ["Service", "ApiManager, TokenUtils", "API calls, token management, data parsing"],
        ["Data", "Models (LoginResponse, ActivityResponse, etc.)", "JSON serialization/deserialization"],
        ["Backend", "ASP.NET REST API", "Business logic, data storage, AI chatbot"],
    ])

    # 5. Folder Structure
    add_heading(doc, "5. Folder Structure", 1)
    add_body(doc,
        "The project uses a feature-folder organization within lib/, separating concerns into api, core, "
        "models, providers, ui, and utils directories. The child_screen module is the largest, containing "
        "approximately 150+ activity stage files across spatial concepts, spatial relations, and visual "
        "spatial perception sub-modules."
    )
    doc.add_picture(folder_img, width=Inches(5.5))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_body(doc, "Figure 2: Project Folder Structure")

    add_table(doc, ["Directory", "Description", "File Count (approx.)"], [
        ["lib/api/", "API constants, endpoints, HTTP manager", "3"],
        ["lib/core/cache/", "SharedPreferences wrapper, JWT utilities", "2"],
        ["lib/custom_widgets/", "Reusable buttons, text fields, language toggle", "3"],
        ["lib/l10n/", "ARB source files + generated localizations", "5"],
        ["lib/models/", "API response models and data classes", "5"],
        ["lib/providers/", "AppLanguageProvider (ChangeNotifier)", "1"],
        ["lib/ui/auth/", "Login, register, forgot password screens", "6"],
        ["lib/ui/parent_screen/", "Parent dashboard and 4 tabs + features", "~15"],
        ["lib/ui/child_screen/", "Child hub + 150+ activity stages", "~180"],
        ["lib/utils/", "Routes, theme, colors, styles, assets", "9"],
        ["assets/images/", "UI images, icons, center logos", "50+"],
        ["assets/sounds/", "Activity feedback audio", "1"],
        ["assets/data/", "centers.json (autism center directory)", "1"],
    ])

    # 6. Packages and Dependencies
    add_heading(doc, "6. Packages and Dependencies", 1)
    add_body(doc, "The following table lists all runtime and development dependencies declared in pubspec.yaml:")

    add_table(doc, ["Package", "Version", "Category", "Purpose"], [
        ["flutter", "SDK", "Framework", "Core UI framework"],
        ["cupertino_icons", "^1.0.8", "UI", "iOS-style icons"],
        ["google_fonts", "^6.3.2", "UI", "Custom typography"],
        ["flutter_localizations", "SDK", "i18n", "Material/Cupertino localization"],
        ["intl", "any", "i18n", "Date/number formatting"],
        ["provider", "^6.1.5+1", "State", "ChangeNotifier state management"],
        ["shared_preferences", "^2.5.3", "Storage", "Key-value local persistence"],
        ["pin_code_fields", "^8.0.1", "UI", "OTP code input (password reset)"],
        ["http", "^1.6.0", "Network", "REST API HTTP client"],
        ["flutter_image_slideshow", "^0.1.6", "UI", "Home tab image carousel"],
        ["fluttertoast", "^9.0.0", "UI", "Toast notification messages"],
        ["percent_indicator", "^4.2.5", "UI", "Circular progress indicators"],
        ["audioplayers", "^6.5.1", "Media", "Activity sound effects"],
        ["expandable_text", "^2.3.0", "UI", "Collapsible text content"],
        ["confetti", "^0.7.0", "UI", "Celebration animation on correct answers"],
        ["url_launcher", "^6.3.0", "Utility", "Open URLs, phone, Google Maps"],
        ["geolocator", "^14.0.2", "Location", "GPS positioning for center distance"],
        ["flutter_lints", "^5.0.0", "Dev", "Dart/Flutter lint rules"],
        ["flutter_launcher_icons", "^0.14.4", "Dev", "App icon generation"],
    ])

    add_body(doc, "Notable absences: google_maps_flutter (maps opened externally), firebase_messaging "
             "(no push notifications), bloc/riverpod/getx (Provider used instead).")

    # 7. Authentication System
    add_heading(doc, "7. Authentication System", 1)
    add_body(doc,
        "Au-somes implements JWT-based authentication with refresh token support. Upon successful login "
        "or registration, access and refresh tokens are stored in SharedPreferences along with child "
        "profile information (name, age) and parent email. Token expiry is extracted from the JWT payload "
        "'exp' claim with a fallback to the expiresIn field."
    )
    doc.add_picture(auth_img, width=Inches(5))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_body(doc, "Figure 3: Authentication Flow Diagram")

    add_table(doc, ["Feature", "Implementation", "Storage Key"], [
        ["Registration", "POST /author/register", "token, refreshToken, childName, childAge, email"],
        ["Login", "POST /author", "token, refreshToken, tokenExpiry"],
        ["Token Refresh", "POST /author/refresh", "Updated token pair"],
        ["Forgot Password", "3-step: email → OTP → new password", "Temporary (in-memory)"],
        ["Profile Update", "PUT /Account/update-profile (Bearer)", "Updated child info"],
        ["Logout", "TokenUtils.clearTokens()", "All keys removed"],
        ["Splash Gate", "Token validation on app launch", "Reads existing tokens"],
    ])

    add_body(doc,
        "Security notes: Google Sign-In button exists in the login UI but is not implemented (onPressed is empty). "
        "There are no route guards — Parent and Child screens are accessible from SelectScreen without authentication. "
        "The SplashScreen auth gate routes directly to ChildScreen (not SelectScreen) when a valid token exists."
    )

    # 8. User Roles
    add_heading(doc, "8. User Roles", 1)
    add_body(doc,
        "The application does not implement backend role-based access control (RBAC). Instead, it uses "
        "UI personas selected manually on the Select Screen. A single registered account is associated "
        "with one child profile (childName, childAge) and one parent email."
    )

    add_table(doc, ["Persona", "Access Level", "Entry Point", "Features"], [
        ["Parent/Caregiver", "Parent module (no auth required)", "Select Screen → Parent", "Home, Notifications, Search, Profile, Chatbot, Tips, Routine"],
        ["Child", "Child activity module", "Select Screen → Child", "Spatial Concepts, Spatial Relations, Visual Spatial Perception"],
        ["Registered User", "Account with JWT", "Login/Register", "Token persistence, profile edit, splash auto-login"],
    ])

    add_body(doc,
        "Activity element roles (game logic, not user roles): Anchor, Actor, and Shadow — used in "
        "ActivityElement.role to define interactive element behavior in drag-and-drop activities."
    )

    # 9. Features
    add_heading(doc, "9. Features", 1)

    add_heading(doc, "9.1 Authentication Features", 2)
    auth_features = [
        "Email/password registration with child profile creation",
        "Email/password login with JWT token storage",
        "Automatic token refresh on expiry",
        "Three-step password recovery (email → 5-digit OTP → new password)",
        "Profile editing (email, child name, child age)",
        "Logout with complete token clearance",
    ]
    for f in auth_features:
        doc.add_paragraph(f, style="List Bullet")

    add_heading(doc, "9.2 Parent Module Features", 2)
    parent_features = [
        "Home tab with promotional image slideshow (language-aware)",
        "AI Chatbot for autism-related questions (backend-powered)",
        "Progress Level dashboard with activity completion indicators",
        "Daily Tips: behavioral, communication, and sensory guidance with external article links",
        "Daily Routine: morning (7 tasks), afternoon (3), evening (4) checklists with daily auto-reset",
        "Notification feed (static placeholder data)",
        "Autism center search with nearest/distance sorting from local JSON",
        "Center actions: phone call, Facebook, website, Google Maps navigation",
        "Profile management with FAQ, About, Review placeholders",
    ]
    for f in parent_features:
        doc.add_paragraph(f, style="List Bullet")

    add_heading(doc, "9.3 Child Module Features", 2)
    child_features = [
        "Spatial Concepts: 8 categories (Up/Down, Front/Back, Between, Inside/Outside, Right/Left, Near/Far)",
        "Spatial Relations: 7 activity groups with ~27 sequential stages",
        "Visual Spatial Perception: 6 sub-modules (Shape & Shadow, Visual Closure, Tower Building, Room Arrangement, Mental Cutting, Geoboard)",
        "API-driven activity content (images, audio instructions, element positions)",
        "Drag-and-drop interactive gameplay with correct/incorrect feedback",
        "Positive reinforcement: confetti, 'Well Done' overlay, correct/wrong sound effects",
        "Multi-level, multi-stage progression within each activity category",
        "Bilingual UI with in-screen language toggle",
    ]
    for f in child_features:
        doc.add_paragraph(f, style="List Bullet")

    # 10. Screen-by-Screen Explanation
    add_heading(doc, "10. Screen-by-Screen Explanation", 1)

    add_heading(doc, "10.1 Onboarding & Authentication Screens", 2)
    add_table(doc, ["Screen", "Route Name", "Description"], [
        ["SplashScreen", "splash_screen", "Animated logo splash; validates JWT token and routes to Login, Child, or token refresh"],
        ["SelectScreen", "select_screen", "Initial route; user chooses Parent or Child persona (no auth check)"],
        ["LoginScreen", "login_screen", "Email/password login; links to register and forgot password; Google button (UI only)"],
        ["RegisterScreen", "register_screen", "Creates account with childName, childAge, email, password; saves tokens on success"],
        ["ForgetPasswordScreen1", "forget_password_screen1", "Enter email to receive 5-digit verification code"],
        ["ForgetPasswordScreen2", "forget_password_screen2", "Enter OTP code via pin_code_fields widget"],
        ["ForgetPasswordScreen3", "forget_password_screen3", "Set new password and confirm; redirects to login"],
    ])

    add_heading(doc, "10.2 Parent Module Screens", 2)
    add_table(doc, ["Screen", "Route / Tab", "Description"], [
        ["ParentScreen", "parent_screen", "Main parent dashboard with custom bottom navigation (4 tabs)"],
        ["HomeTab", "Tab 0", "Image slideshow + grid of 4 features: Chatbot, Progress, Daily Tips, Daily Routine"],
        ["NotificationTab", "Tab 1", "Static notification list grouped by Today/Yesterday"],
        ["SearchTab", "Tab 2", "Autism center directory with filter nearest, sort by distance, reset"],
        ["ProfileTab", "Tab 3", "Child info display, edit profile, reset password, FAQ, logout"],
        ["ChatbotScreen", "chatbot_screen", "AI chat interface; persists history in SharedPreferences"],
        ["ProgressLevelScreen", "progress_level_screen", "Overall progress (12%) and per-activity completion bars"],
        ["DailyTipsScreen", "daily_tips_screen", "Categorized tips with expandable text and external links"],
        ["DailyRoutineScreen", "daily_routine_screen", "Time-based checklist (morning/afternoon/evening) with daily reset"],
        ["EditProfileScreen", "edit_profile_screen", "Update email, child name, and age via API"],
    ])

    add_heading(doc, "10.3 Child Module Screens", 2)
    add_table(doc, ["Screen", "Route Name", "Description"], [
        ["ChildScreen", "child_screen", "Activity hub; greets child by name; 3 module cards"],
        ["SpatialConceptsScreen", "spatial_concepts_screen", "Lists 8 spatial concept categories with lock/unlock icons"],
        ["UpBaseActivityScreen", "up_base_activity_screen", "Sequential up/down concept activities"],
        ["DownBaseActivityScreen", "down_base_activity_screen", "Down concept activity stages"],
        ["FrontBackBaseActivityScreen", "front_back_base_activity_screen", "Front and back spatial activities"],
        ["BetweenBaseActivityScreen", "between_base_activity_screen", "Between concept activities"],
        ["InsideBaseActivityScreen", "inside_base_activity_screen", "Inside spatial concept stages"],
        ["OutsideBaseActivityScreen", "outside_base_activity_screen", "Outside spatial concept stages"],
        ["RightLeftBaseActivityScreen", "right_left_base_activity_screen", "Right/left directional activities"],
        ["NearFarBaseActivityScreen", "near_far_base_activity_screen", "Near/far distance concept activities"],
        ["SpatialRelationsBaseScreen", "spatial_relations_base_activity_screen", "27-stage spatial relations pipeline"],
        ["VisualSpatialPerceptionBaseScreen", "visual_spatial_perception_screen", "20-stage VSP activities across 6 sub-modules"],
        ["MentalCuttingLevel3Stage2", "mental_cutting32_activity_screen", "Standalone mental cutting advanced stage"],
    ])

    add_body(doc,
        "Note: Individual activity stages (150+ files) are not separate routes. They are embedded within "
        "Base Activity Screens using indexed widget lists and GlobalKey-based stage progression."
    )

    # 11. API Integration
    add_heading(doc, "11. API Integration", 1)
    add_body(doc,
        "All API communication is handled by the static ApiManager class using the http package. "
        "The base URL is http://au-somes.runasp.net. Error handling parses ASP.NET validation "
        "error responses from both List and Map formatted error bodies."
    )
    doc.add_picture(data_img, width=Inches(5.5))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_body(doc, "Figure 4: Activity Data Flow Diagram")

    add_table(doc, ["Method", "Endpoint", "Auth", "Request Body / Params", "Response"], [
        ["POST", "/author/register", "No", "childName, email, password, confirmPassword, childAge", "RegisterResponse + JWT"],
        ["POST", "/author", "No", "email, password", "LoginResponse + JWT"],
        ["POST", "/author/refresh", "No", "refreshToken", "New LoginResponse"],
        ["POST", "/author/forget-password", "No", "email", "204 No Content"],
        ["POST", "/Author/verify-code", "No", "email, code (5 digits)", "200/204 or error"],
        ["POST", "/Author/reset-password", "No", "email, code, newPassword, confirmPassword", "200/204 or error"],
        ["GET", "/api/Activity/get-activity/{id}/{p1}/{p2}", "No", "activityId, level, stage", "ActivityResponse JSON"],
        ["PUT", "/Account/update-profile", "Bearer JWT", "email, childName, childAge", "200/204"],
        ["POST", "/api/Chat/ask", "No", "Prompt (string)", "answer (string)"],
    ])

    add_heading(doc, "11.1 Activity IDs", 2)
    add_table(doc, ["Constant Name", "UUID", "Module"], [
        ["front_back_activityId", "b53c1f0b-1fed-46d2-ba7e-61f6c949bf77", "Spatial Concepts"],
        ["up_down_activityId", "810ce01d-1dfa-4f58-81e7-868efc7d9de0", "Spatial Concepts"],
        ["between_activityId", "6b84f943-6b7a-4489-9ed1-d81806eef1c9", "Spatial Concepts"],
        ["inside_outside_activityId", "5d42f9bd-4cc2-40de-b6c6-7b59cdd676cd", "Spatial Concepts"],
        ["right_left_activityId", "8a0f50f0-2b45-4ae0-b9ef-a3f228cd49a5", "Spatial Concepts"],
        ["near_far_activityId", "b0f2db92-bd18-490a-8689-7501357f7ae9", "Spatial Concepts"],
        ["sr_near_far_activityId", "0579433f-06e8-47fc-bf9a-5357cff30ec4", "Spatial Relations"],
        ["sr_between_activityId", "e650075f-d074-4b64-812b-da8b0f85d86f", "Spatial Relations"],
        ["sr_front_back_activityId", "f479d29d-da80-4c28-992d-6cb4632ee99d", "Spatial Relations"],
        ["sr_right_left_activityId", "c27a80fb-f89c-4b3d-918d-05c843395fae", "Spatial Relations"],
        ["sr_up_down_activityId", "352f25f7-3502-472a-8542-f6d4e4634242", "Spatial Relations"],
        ["sr_inside_outside_activityId", "8bf22ea6-e8cd-415d-bc35-2048604a894c", "Spatial Relations"],
        ["room_arrangement_activityId", "db245739-b9a2-4f1b-a2af-bccb23a4fbd8", "Visual Spatial"],
        ["tower_building_activityId", "664189bb-3817-4ed8-96a6-c1c532a01885", "Visual Spatial"],
        ["shape_and_shadow_activityId", "c7ae48ac-b9bb-4ff8-a1e0-7c6d805b1e99", "Visual Spatial"],
        ["mental_cutting_activityId", "98bd481f-fdef-4c8a-bf44-cfea7c979ab2", "Visual Spatial"],
        ["visual_closure_activityId", "c4aacb0a-a8f5-4788-b944-1395b570c015", "Visual Spatial"],
        ["geoboard_activityId", "37865779-f465-4034-9707-8e01d0a89446", "Visual Spatial"],
    ])

    # 12. Models and Data Structures
    add_heading(doc, "12. Models and Data Structures", 1)

    add_heading(doc, "12.1 LoginResponse / RegisterResponse", 2)
    add_table(doc, ["Field", "Type", "Description"], [
        ["id", "String?", "User account identifier"],
        ["email", "String?", "Parent email address"],
        ["childName", "String?", "Registered child's name"],
        ["childAge", "int?", "Registered child's age"],
        ["token", "String?", "JWT access token"],
        ["expiresIn", "int?", "Token lifetime in seconds"],
        ["refreshToken", "String?", "Refresh token for session renewal"],
        ["refreshTokenExpiration", "String?", "Refresh token expiry timestamp"],
    ])

    add_heading(doc, "12.2 ActivityResponse", 2)
    add_table(doc, ["Field", "Type", "Description"], [
        ["phaseId", "String?", "Activity phase identifier"],
        ["name", "String?", "Activity display name"],
        ["audioUrl", "String?", "URL to instruction audio file"],
        ["deceptionInstructions", "List<String>?", "Step-by-step activity instructions"],
        ["elements", "List<ActivityElement>?", "Interactive UI elements"],
    ])

    add_heading(doc, "12.3 ActivityElement", 2)
    add_table(doc, ["Field", "Type", "Description"], [
        ["id", "String?", "Element unique identifier"],
        ["imageUrl", "String?", "Element image URL from backend"],
        ["x", "int?", "Horizontal position coordinate"],
        ["y", "int?", "Vertical position coordinate"],
        ["role", "String?", "Element role: Anchor, Actor, or Shadow"],
        ["isCorrect", "bool?", "Whether this is the correct answer target"],
        ["targetedZoneId", "dynamic", "Drop zone identifier for drag-and-drop"],
    ])

    add_heading(doc, "12.4 CenterModel", 2)
    add_table(doc, ["Field", "Type", "Description"], [
        ["name", "String", "Center name"],
        ["phone", "String", "Contact phone number"],
        ["address", "String", "Physical address"],
        ["locationName", "String", "Location display name"],
        ["latitude", "double", "GPS latitude"],
        ["longitude", "double", "GPS longitude"],
        ["facebookName / facebookLink", "String", "Social media presence"],
        ["websiteName / websiteLink", "String", "Official website"],
        ["image", "String", "Center logo image asset path"],
    ])

    # 13. Localization System
    add_heading(doc, "13. Localization System", 1)
    add_body(doc,
        "Au-somes uses Flutter's official internationalization (gen-l10n) system with ARB (Application "
        "Resource Bundle) files. Configuration is defined in l10n.yaml at the project root."
    )

    add_table(doc, ["Component", "File / Class", "Description"], [
        ["Config", "l10n.yaml", "ARB directory, template file, output file settings"],
        ["English", "lib/l10n/app_en.arb", "Template ARB with ~237 localization keys"],
        ["Arabic", "lib/l10n/app_ar.arb", "Arabic translations for all keys"],
        ["Generated", "app_localizations.dart", "Auto-generated localization delegate"],
        ["Provider", "AppLanguageProvider", "ChangeNotifier managing active locale"],
        ["Widget", "CustomLanguageWidget", "EN/AR toggle button on screens"],
        ["Persistence", "SharedPrefsKeys.languageKey", "Saves selected language preference"],
    ])

    add_body(doc,
        "Usage pattern: AppLocalizations.of(context)!.keyName throughout all UI screens. "
        "RTL support is implemented conditionally via languageProvider.isArabic() for arrow directions, "
        "message alignment, and progress indicator orientation. "
        "Note: AppLanguageProvider.getLanguage() exists but is not called during app initialization, "
        "so saved language preference may not restore on cold start."
    )

    # 14. State Management
    add_heading(doc, "14. State Management", 1)
    add_body(doc,
        "The application uses a hybrid state management approach rather than a single global solution. "
        "This is appropriate for the project's scale where most state is screen-local."
    )

    add_table(doc, ["Pattern", "Scope", "Used For"], [
        ["Provider (ChangeNotifier)", "Global", "App language/locale switching"],
        ["StatefulWidget + setState", "Screen-local", "Form inputs, tab selection, activity stages"],
        ["SharedPreferences", "Persistent", "JWT tokens, chat history, daily routine progress, language"],
        ["GlobalKey", "Widget control", "Stage progression in base activity screens"],
        ["RouteObserver", "Navigation", "Route lifecycle awareness (registered, lightly used)"],
    ])

    add_body(doc,
        "Provider setup in main.dart: MultiProvider wraps MyApp with a single ChangeNotifierProvider "
        "for AppLanguageProvider. MyApp reads appLanguage to set MaterialApp locale. "
        "Not used: Bloc, Riverpod, GetX, MobX, or Redux."
    )

    # 15. Notifications
    add_heading(doc, "15. Notifications", 1)
    add_body(doc,
        "The notification system is currently implemented as a UI prototype with static mock data. "
        "There is no integration with Firebase Cloud Messaging (FCM), flutter_local_notifications, "
        "or any backend notification service."
    )

    add_table(doc, ["Aspect", "Current Implementation", "Planned / Missing"], [
        ["Data Source", "Hardcoded static list", "Backend push notification API"],
        ["Grouping", "Today / Yesterday sections", "Dynamic date-based grouping"],
        ["Types", "Reminders, daily tips, chatbot prompts", "Activity completion, routine reminders"],
        ["Push Delivery", "Not implemented", "FCM or local scheduled notifications"],
        ["User Actions", "Display only (no tap actions)", "Deep linking to relevant screens"],
        ["Persistence", "None", "Notification history storage"],
    ])

    add_body(doc,
        "The NotificationTab displays 5 sample notifications using the NotificationItem widget with "
        "icons for time, reminder, tips, and chatbot categories. All text content is localized via ARB keys."
    )

    # 16. Google Maps Integration
    add_heading(doc, "16. Google Maps Integration", 1)
    add_body(doc,
        "Au-somes does not embed an in-app Google Maps widget. Instead, it integrates with Google Maps "
        "externally via the url_launcher package and uses geolocator for location-based distance calculations."
    )

    add_table(doc, ["Feature", "Implementation", "Package"], [
        ["Open Center Location", "Launches Google Maps search URL with lat/lng", "url_launcher"],
        ["Distance Calculation", "Haversine formula on center coordinates", "Built-in (dart:math)"],
        ["GPS Positioning", "getNearestCenter() with permission request", "geolocator"],
        ["Filter Nearest", "Sorts centers by distance from user location", "SearchTab logic"],
        ["Fixed Reference Point", "Cairo coordinates (30.0444, 31.2357) used in SearchTab", "Hardcoded"],
    ])

    add_body(doc,
        "Google Maps URL format: https://www.google.com/maps/search/?api=1&query={lat},{lng} "
        "opened via LaunchMode.externalApplication. Center data is loaded from assets/data/centers.json "
        "rather than a remote API. The geolocator-based getNearestCenter() function exists in center_data.dart "
        "but SearchTab currently uses fixed Cairo coordinates instead of live GPS."
    )

    # 17. User Flow
    add_heading(doc, "17. User Flow", 1)
    doc.add_picture(user_img, width=Inches(6))
    doc.paragraphs[-1].alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_body(doc, "Figure 5: User Flow Diagram")

    add_heading(doc, "17.1 New User Flow", 2)
    new_user_steps = [
        "Launch app → Select Screen (initial route)",
        "Navigate to Register Screen → Create account with child info",
        "Tokens saved → Redirected to Select Screen",
        "Choose Parent → Access caregiver features OR Choose Child → Access activities",
    ]
    for i, step in enumerate(new_user_steps, 1):
        doc.add_paragraph(f"{i}. {step}")

    add_heading(doc, "17.2 Returning User Flow (via Splash)", 2)
    returning_steps = [
        "Launch app → Splash Screen (if configured as initial route)",
        "Valid JWT found → Direct to Child Screen",
        "Expired JWT → Attempt refresh → Child Screen or Login",
        "No token → Login Screen",
    ]
    for i, step in enumerate(returning_steps, 1):
        doc.add_paragraph(f"{i}. {step}")

    add_heading(doc, "17.3 Child Activity Flow", 2)
    activity_steps = [
        "Child Screen → Select module (Spatial Concepts / Relations / VSP)",
        "Module Screen → Select activity category",
        "Base Activity Screen → Sequential stages with API-loaded content",
        "Complete stage → Reinforcement (confetti, sound, overlay) → Next stage",
        "Complete all stages → Return to module or child hub",
    ]
    for i, step in enumerate(activity_steps, 1):
        doc.add_paragraph(f"{i}. {step}")

    # 18. Future Enhancements
    add_heading(doc, "18. Future Enhancements", 1)
    add_body(doc,
        "Based on the current codebase analysis, the following enhancements are recommended for "
        "future development iterations:"
    )

    add_table(doc, ["Priority", "Enhancement", "Rationale"], [
        ["High", "Implement route guards / auth middleware", "Parent/Child screens accessible without login"],
        ["High", "Real-time progress tracking via API", "Progress screen uses static mock data (12%)"],
        ["High", "Push notifications (FCM)", "Notification tab is UI-only placeholder"],
        ["High", "Google Sign-In integration", "Button exists but onPressed is empty"],
        ["Medium", "Embedded Google Maps widget", "Better UX than external URL launch"],
        ["Medium", "Live GPS in SearchTab", "geolocator available but unused in search"],
        ["Medium", "Restore saved language on startup", "getLanguage() not called in main()"],
        ["Medium", "Activity unlock progression system", "Lock icons present but not enforced"],
        ["Medium", "Offline activity caching", "Activities require network for each stage"],
        ["Low", "Dark mode theme support", "Only light theme (AppTheme.lightTheme) exists"],
        ["Low", "Accessibility improvements", "Screen reader, larger touch targets for ASD users"],
        ["Low", "Analytics and reporting dashboard", "Parent insights on child performance trends"],
        ["Low", "Multi-child profile support", "Currently single child per account"],
        ["Low", "Centers API migration", "Move centers.json to backend for dynamic updates"],
    ])

    # Conclusion
    doc.add_page_break()
    add_heading(doc, "Conclusion", 1)
    add_body(doc,
        "Au-somes represents a comprehensive graduation project that successfully combines therapeutic "
        "educational content for children with autism spectrum disorders and a supportive parent portal. "
        "With approximately 232 Dart source files and 150+ interactive activity stages, the application "
        "demonstrates significant development effort in both UI/UX design and backend integration."
    )
    add_body(doc,
        "The architecture is well-organized using feature-based folder structure, REST API integration, "
        "JWT authentication, and bilingual localization. Key areas for improvement include implementing "
        "proper authentication guards, real-time progress tracking, push notifications, and completing "
        "placeholder features (Google Sign-In, dynamic notifications, live GPS)."
    )
    add_body(doc,
        "This documentation report provides a complete technical reference for the Au-somes Flutter "
        "application as submitted for graduation project evaluation."
    )

    doc.save(OUTPUT_FILE)
    print(f"Report generated: {OUTPUT_FILE}")
    return OUTPUT_FILE


if __name__ == "__main__":
    build_document()

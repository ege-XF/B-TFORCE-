# Graph Report - B-TFORCE-  (2026-10-27)

## Corpus Check
- 62 files · ~11,855 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 62 file(s) not represented in the graph (top: (none) 18, .xcconfig 8, .xml 7)

## Summary
- 493 nodes · 631 edges · 36 communities (18 shown, 18 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `a901875f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- main.dart
- main.py
- win32_window.cpp
- AppDelegate
- my_application.cc
- utils.cpp
- StatelessWidget
- FlutterWindow
- pubspec.yaml
- announcement.dart
- academic_repository.dart
- akademik_scraper.py
- api_constants.dart
- manifest.json
- academic_staff.dart
- GroupsPage
- html_utils.dart
- analysis_options.yaml
- widget_test.dart
- FlutterActivity
- LaunchImage.imageset/README.md
- frontend/README.md

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `SchoolRepository` - 11 edges
3. `FlutterWindow` - 10 edges
4. `_otomatik_bot_dizisi()` - 8 edges
5. `OkulScraperService` - 7 edges
6. `_MyApplication` - 7 edges
7. `WindowClassRegistrar` - 7 edges
8. `DuyuruCreate` - 5 edges
9. `HaberCreate` - 5 edges
10. `get_supabase_client()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  frontend/windows/runner/main.cpp → frontend/windows/runner/utils.cpp
- `SchoolRepository` --uses--> `DuyuruCreate`  [INFERRED]
  bitforce--backend/src/Infrastructure/Persistence/repository.py → bitforce--backend/src/Core/Application/dtos/schemas.py
- `SchoolRepository` --uses--> `HaberCreate`  [INFERRED]
  bitforce--backend/src/Infrastructure/Persistence/repository.py → bitforce--backend/src/Core/Application/dtos/schemas.py
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  frontend/linux/runner/my_application.cc → frontend/linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  frontend/linux/runner/main.cc → frontend/linux/runner/my_application.cc

## Import Cycles
- None detected.

## Communities (36 total, 18 thin omitted)

### Community 0 - "main.dart"
Cohesion: 0.02
Nodes (90): a, _academicGuide, _academicRepository, accent, accentDeep, active, amber, AppColors (+82 more)

### Community 1 - "main.py"
Cohesion: 0.06
Nodes (17): Settings, lifespan(), _otomatik_bot_dizisi(), root(), DuyuruBase, DuyuruCreate, DuyuruResponse, Config (+9 more)

### Community 2 - "win32_window.cpp"
Cohesion: 0.07
Nodes (18): RegisterPlugins(), EnableFullDpiSupportIfAvailable(), EnableNonClientDpiScaling, Point, x, y, Scale(), Size (+10 more)

### Community 3 - "AppDelegate"
Cohesion: 0.06
Nodes (13): Cocoa, Flutter, FlutterMacOS, Foundation, AppDelegate, SceneDelegate, RunnerTests, RegisterGeneratedPlugins() (+5 more)

### Community 4 - "my_application.cc"
Cohesion: 0.09
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 5 - "utils.cpp"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 6 - "StatelessWidget"
Cohesion: 0.09
Nodes (21): _AcademicTile, _AnnouncementCard, AppBackground, AtuObsApp, CategoryTag, _ChatButton, FilterBar, FilterChipX (+13 more)

### Community 7 - "FlutterWindow"
Cohesion: 0.11
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 8 - "pubspec.yaml"
Cohesion: 0.11
Nodes (18): dependencies, cupertino_icons, flutter, google_fonts, http, description, dev_dependencies, flutter_lints (+10 more)

### Community 9 - "announcement.dart"
Cohesion: 0.13
Nodes (11): Announcement, body, category, CategoryType, day, _emptyDetail, fromJson, month (+3 more)

### Community 10 - "academic_repository.dart"
Cohesion: 0.18
Nodes (5): AcademicRepository, _fallbackStaff, fetchAcademicStaff, FeedRepository, fetchLiveFeed

### Community 11 - "akademik_scraper.py"
Cohesion: 0.25
Nodes (3): scrape_akademik_kadro(), get_akademisyenler(), AkademisyenSchema

### Community 12 - "api_constants.dart"
Cohesion: 0.18
Nodes (6): akademisyenlerEndpoint, ApiConstants, duyurularEndpoint, feedEndpoint, haberlerEndpoint, _localIp

### Community 13 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 14 - "academic_staff.dart"
Cohesion: 0.22
Nodes (8): AcademicStaff, department, email, fromJson, name, phone, room, title

### Community 15 - "GroupsPage"
Cohesion: 0.32
Nodes (6): GroupsPage, _GroupsPageState, HomePage, _HomePageState, HomeShell, _HomeShellState

### Community 16 - "html_utils.dart"
Cohesion: 0.29
Nodes (5): Announcement, exp, fromJson, replaceAll, stripHtml

### Community 17 - "analysis_options.yaml"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

## Knowledge Gaps
- **138 isolated node(s):** `ApiConstants`, `_localIp`, `feedEndpoint`, `duyurularEndpoint`, `haberlerEndpoint` (+133 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 286 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `FeedRepository` connect `academic_repository.dart` to `main.dart`?**
  _High betweenness centrality (0.017) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `SchoolRepository` (e.g. with `DuyuruCreate` and `HaberCreate`) actually correct?**
  _`SchoolRepository` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ApiConstants`, `_localIp`, `feedEndpoint` to the rest of the system?**
  _138 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `main.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.017699115044247787 - nodes in this community are weakly interconnected._
- **Why does `AcademicStaff` connect `academic_staff.dart` to `main.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `_otomatik_bot_dizisi()` (e.g. with `lifespan()` and `.scrape_all()`) actually correct?**
  _`_otomatik_bot_dizisi()` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Should `main.py` be split into smaller, more focused modules?**
  _Cohesion score 0.06390977443609022 - nodes in this community are weakly interconnected._
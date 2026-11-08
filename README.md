# MagnetoLab

Náučná hra o magnetizme – tímová semestrálna práca z predmetu **Multimediálne systémy** (UCM Trnava).

---

## 1. O projekte

**MagnetoLab** je izometrická 2.5D hádanková (logická) hra s pohľadom zhora. Hráč prechádza
miestnosťami laboratória, v každej nájde kľúč a otvorí dvere. Hádanky sa riešia magnetmi –
hlavne magnetickou rukavicou, ktorá priťahuje a odpudzuje predmety.

Hra je určená pre **4. ročník ZŠ, prírodoveda** (tematický celok *Neživá príroda a skúmanie
prírodných javov*). Pokrýva celý výkonový štandard podľa inovovaného ŠVP – každý bod má vlastnú
miestnosť a otázku v záverečnom teste:

| # | Žiak na konci 4. ročníka vie / dokáže | Miestnosť |
|---|---|---|
| 1 | že magnet je predmet, ktorý priťahuje niektoré kovové predmety a nepriťahuje žiadne nekovové predmety | A1, A2 |
| 2 | skúmaním zistiť, že magnet pôsobí do určitej vzdialenosti – má okolo seba tzv. magnetické pole | A4 |
| 3 | navrhnúť postup, pomocou ktorého porovná veľkosť (odmeria) magnetického poľa dvoch magnetov | A5 |
| 4 | vysvetliť, ako sa k sebe správajú dva magnety | A3 |
| 5 | ako sa používa kompas | A6 |

Obsahový štandard: magnet, magnetické pole, kompas. Podrobný návrh miestností je v GDD v Notione.

V každej miestnosti sa postupuje ako vo vede: **odhadni → vyskúšaj → kartička „Čo si zistil“**.

### Príbeh
Chlapec **Kubo** (10 rokov) zaspí pred testom z magnetizmu. V sne sa ocitne v laboratóriu
**profesora Magnetóna**. Profesor sa mu prihovára z obrazoviek na stenách – kladie otázky,
dáva nápovedy a vysvetľuje, čo Kubo zistil. Na konci sa Kubo zobudí a píše test.

**Miro mapa projektu:** [DOPLNIŤ – odkaz na Miro]

---

## 2. Stav projektu

### ✅ Hotové (prototyp)
- **Mriežka a izometria** – herná logika beží na políčkach, `GridManager` vie, čo je na ktorom políčku.
- **Hráč** – pohyb po mriežke (WASD / šípky), otočenie na mieste, krok po krátkej pauze.
- **Bedne** podľa materiálu: drevo, železo, hliník, meď, plast; železná bedňa môže byť magnet s pólom S/J.
  Rukou sa dá tlačiť len drevená bedňa, pri kovovej Magnetón povie, že je príliš ťažká.
- **Magnetická rukavica** – vypnutá / S / J (medzerník, Q). Pôsobí na prvý objekt v smere pohľadu,
  priťahuje železo oboma pólmi, magnety priťahuje alebo odpudzuje podľa pólov. Dosah 4 políčka,
  políčka v dosahu sa po zapnutí jemne zvýraznia.
- **Magnet na podlahe** s nastaviteľným dosahom (pripravený pre A5).
- **Malé predmety** (kľúč, drevená kocka, plastová fľaša) – železné preletia k hráčovi do **inventára (6 slotov)**.
- **Priepasť** – nedá sa na ňu vstúpiť, lúč rukavice cez ňu prejde.
- **Dvere s kľúčom** (E), **tabuľa** (E), **spúšťacie oblasti** (dialóg pri vstupe).
- **Dialógové okno** s portrétom Magnetóna (neutral / happy / surprised), otázky s možnosťami (1–3 alebo myš).
- **HUD** s panelom inventára.
- **Level A1 „Železo alebo nie?“** – celý bádateľský postup (otázka, spätná väzba po pokuse, kartička po otvorení dverí).
- **R** = reštart miestnosti, **Esc** = späť do hlavného menu.
- **Hlavné menu** – Pokračovať, Hrať (spustí A1), Výber miestnosti, Nastavenia, Autori, Ukončiť; ovláda sa myšou aj klávesnicou.
- **Ukladanie** (`SaveManager`) – postup a nastavenia v `user://save.cfg`. Po dokončení A1 sa odomkne A2.
- **Jednotný vzhľad UI** – `resources/ui_theme.tres`.
- Grafika je zatiaľ **dočasná** (farebné tvary a placeholdery v `art/placeholders/`).

### 🔧 Robí sa
- [DOPLNIŤ – čo sa práve robí, napr. podľa GitHub Issues]

### 📋 Ďalej
1. **MVP:** miestnosti A2–A6 – A2 „Prekvapivé kovy“, A3 „Dva magnety“, A4 „Kam až siaha magnet?“,
   A5 „Ktorý magnet je silnejší?“, A6 „Tmavá miestnosť s kompasom“; držanie pritiahnutej bedne rukavicou,
   tlačidlá na podlahe, kompas, železné piliny, stupnica a železná sponka na meranie dosahu magnetu, pauza,
   finálna grafika a zvuky, export do `.exe`.
2. **Záverečný test** – otázka ku každému bodu výkonového štandardu (overenie učenia), úvodná a záverečná scéna,
   testovanie s deťmi.
3. **Bonusy:** strážny robot, denník bádateľa, cutscény.

---

## 3. Tím a úlohy

| Člen | Rola | Na čom robí |
|---|---|---|
| Lubo | programátor | [DOPLNIŤ] |
| Matej | programátor | [DOPLNIŤ] |
| Katka | grafika | [DOPLNIŤ] |
| Roberta | grafika | [DOPLNIŤ] |

**Úlohy a chyby** evidujeme v **GitHub Issues**: <https://github.com/UCM-MS/Magnetolab/issues>

- Nová úloha alebo nájdená chyba = nový Issue (krátky názov, čo sa stalo, ako to zopakovať).
- Kto na úlohe robí, priradí si ju (Assignees).

---

## 4. Pre programátorov

### Inštalácia
1. **Godot 4.7.2 – štandardná verzia** (nie .NET/C#). Stiahnuť z
   <https://godotengine.org/download/archive/> → 4.7.2 → Windows, *Standard*. Je to jeden `.exe`,
   netreba inštalovať – stačí ho rozbaliť napr. do `C:\Godot\`.
   ⚠️ Používajte všetci **presne rovnakú verziu**, inak Godot mení súbory scén a vznikajú konflikty.
2. **Git** – <https://git-scm.com/download/win> (pri inštalácii stačia predvolené voľby).
3. Prvé nastavenie Gitu (raz, v termináli):
   ```
   git config --global user.name "Meno Priezvisko"
   git config --global user.email "tvoj@email.sk"
   ```

### Naklonovanie a otvorenie
```
git clone https://github.com/UCM-MS/Magnetolab.git
```
1. Spusti Godot → **Import** → vyber súbor `project.godot` v naklonovanom priečinku → **Import & Edit**.
2. Prvé otvorenie chvíľu trvá (Godot si vytvára priečinok `.godot/`).
3. **F5** spustí hru (hlavná scéna je `scenes/ui/main_menu.tscn`), **F6** spustí práve otvorenú scénu.
4. Po spustení skontroluj spodný panel **Output / Debugger** – nesmú tam byť chyby.

### Ovládanie v hre
| Kláves | Akcia |
|---|---|
| WASD / šípky | pohyb (iný smer = najprv len otočenie) |
| Medzerník | rukavica zap / vyp |
| Q | prepnúť pól S / J |
| E | interakcia (dvere, tabuľa), v dialógu pokračovať |
| Enter | v dialógu pokračovať |
| 1–3 | výber odpovede |
| R | reštart miestnosti |
| Esc | späť do hlavného menu |
| Šípky + Enter | ovládanie menu (funguje aj myš) |

### Čo si prečítať ako prvé
1. **Dokumentácia v Notione (GDD a TDD)** – pravidlá hry, fyziky a kódu. Pred zmenami v hernej logike si ju prečítaj.
2. **Architektúra mriežky** – hra nepoužíva fyzikálny engine. Každý objekt má pozíciu `Vector2i`
   (políčko), izometria je len vykreslenie. Pohyb je animovaný cez `Tween`.
3. **`scripts/grid_manager.gd`** (autoload `GridManager`) – jediný zdroj pravdy: čo stojí na ktorom
   políčku, čo je stena / priepasť, prevod políčko ↔ pixely, hľadanie prvého objektu v rade (lúč).
4. **`scripts/grid_object.gd`** (`GridObject`) – spoločný základ všetkých objektov na mriežke
   (hráč, bedňa, predmet, dvere, tabuľa).
5. **`scripts/level.gd`** (`Level`) – spoločný skript miestnosti: načíta mriežku, umiestni objekty,
   pospája signály (inventár → HUD, dvere → kartička, bádateľský postup).
6. **`scripts/magnetism.gd`** – všetky fyzikálne pravidlá magnetizmu na jednom mieste.
7. **`scripts/save_manager.gd`** (autoload `SaveManager`) – postup hráča a nastavenia v `user://save.cfg`.
8. **`scenes/ui/main_menu.gd`** – hlavné menu, podobrazovky sú panely v jednej scéne.

### Štruktúra priečinkov
```
art/            grafika od grafikov (placeholders/ = dočasné obrázky)
audio/          zvuky a hudba
resources/      .tres – dáta: levely, dialógy, predmety, tileset, spoločné texty
  characters/   magneton.tres (meno a portréty profesora)
  items/        druhy malých predmetov (ItemData)
  level_a1/     dáta a dialógy levelu A1
scenes/
  levels/       level_a1.tscn, test_room.tscn (skúšobná miestnosť)
  objects/      player, box, item, door, info_sign, trigger_zone (+ ich skripty .gd)
  ui/           main_menu, dialog_box, hud
scripts/        spoločné skripty: GridManager, SaveManager, GridObject, Level, Magnetism, dátové triedy
```

### Vzhľad UI (Theme)
Vzhľad tlačidiel, panelov a textu je na jednom mieste, v `resources/ui_theme.tres`, a platí pre celú hru
(`Project Settings → GUI → Theme → Custom`). Do scén preto nepíšeme vlastné farby ani štýly.

Výmena dočasného vzhľadu za obrázky z `art/ui/`:
1. Otvor `ui_theme.tres` a vyber štýl (napr. `Button → normal`).
2. Namiesto `StyleBoxFlat` zvoľ **New StyleBoxTexture**, vlož obrázok a do `Texture Margins` zadaj veľkosť rohov.
3. Do `Content Margins` zadaj rovnaké okraje textu, aké mal pôvodný štýl (tlačidlo: 16 a 8).

Pri `focus` (výber klávesnicou) použi `button_hover.png` – kreslí sa cez bežné tlačidlo. Pozadie a nadpis
sú v `main_menu.tscn` (`Background`, `Title`) a ikonu zámku nastavíš v `Lock Icon` na uzle `MainMenu`.

### Konvencie kódu
- GDScript so **statickým typovaním**: `var speed: float = 2.0`, `func move(dir: Vector2i) -> void`.
- `snake_case` pre súbory, premenné a funkcie, `PascalCase` pre `class_name`.
- Krátke komentáre **po slovensky**, malé jasné funkcie, žiadne „magické čísla“ (pomenované konštanty).
- `@export` pre veci, ktoré sa nastavujú v editore (materiál, pól...).
- Objekty spolu komunikujú cez **signály**, nie cez pevné cesty k uzlom.
- Texty pre hráča **nikdy natvrdo v kóde** – patria do `.tres` súborov.
- Viac v TDD v Notione.

### Ako sa robí nový level
1. Skopíruj priečinok dát (napr. `resources/level_a1/` → `resources/level_a2/`) a uprav texty:
   - `level_a2.tres` (`LevelData`) – názov, `guess_check_item` (predmet, ktorého prvé pritiahnutie je pokus),
     `guess_feedback` (spätná väzba pre každú možnosť, index od 0), `info_card` (kartička „Čo si zistil“),
   - dialógy `DialogData` (otázka „odhadni“ je strana s `options`).
2. Vytvor scénu `scenes/levels/level_a2.tscn` s rovnakou stavbou ako `level_a1.tscn`:
   koreňový `Node2D` so skriptom `level.gd`, pod ním `Room` (TileMapLayer s tilesetom),
   `Objects` (hráč a objekty, Y Sort), `Triggers`, `Camera2D`, `HUD`.
3. V koreňovom uzle nastav v Inspectore `room_layer`, `player`, `hud` a `level_data`.
4. Podlahu, steny a priepasti nakresli do `Room`; objekty vlož ako inštancie scén z `scenes/objects/`.
5. V `LevelData` nastav `next_level_id` (miestnosť, ktorá sa po dokončení odomkne). Výber miestnosti
   hľadá scénu podľa názvu: `A2` → `scenes/levels/level_a2.tscn`.
6. Spusti scénu (F6) a skontroluj, či v konzole nie sú chyby.

Po otvorení dverí a zatvorení kartičky sa hráč vráti do menu. Priamy prechod do ďalšej miestnosti zatiaľ neexistuje. [DOPLNIŤ, keď bude hotový]

### Práca s AI asistentom
- Zadávaj malé kroky (jeden objekt / jedna funkcia), potom hru spusti a over.
- Pred commitom si prečítaj, čo AI zmenila (`git diff`). Pozri aj časť [Použitie AI](#8-použitie-ai).

---

## 5. Pre grafikov

### Štýl a technické pravidlá
- **Izometria 2:1** – jedna dlaždica podlahy je kosoštvorec **64 × 32 px** (2 px do šírky, 1 px do výšky).
- **Formát: PNG s priehľadným pozadím** (bez bieleho pozadia okolo predmetu).
- Pohľad zhora-zboku, rovnaký uhol pre všetky objekty. Svetlo [DOPLNIŤ – odkiaľ, napr. zľava hore].
- Kresli v skutočnej veľkosti alebo v presnom násobku (2×, 4×) – dohodnúť s programátormi. [DOPLNIŤ]
- Farebná paleta / štýl (kreslený, pixel art...): [DOPLNIŤ]

### Čo treba nakresliť

| Čo | Rozmery | Pravidlá |
|---|---|---|
| **Dlaždice podlahy** | 64 × 32 px | kosoštvorec presne na hranu, vzor musí nadväzovať na susedné dlaždice |
| **Steny** | šírka 64 px, výška [DOPLNIŤ] | zatiaľ je stena len plochá dlaždica; výšku a tvar steny dohodnúť |
| **Priepasť** | 64 × 32 px | musí byť jasne odlíšená od podlahy (hráč na ňu nemôže vstúpiť) |
| **Bedne** | šírka do 64 px, výška [DOPLNIŤ] | stoja na jednom políčku, spodok sedí na kosoštvorci 64 × 32 |
| **Kubo** | šírka do 64 px, výška [DOPLNIŤ] | 4 diagonálne smery (pozri nižšie) |
| **Kľúč a malé predmety** | 32 × 32 px | ten istý obrázok sa použije na zemi aj v inventári |
| **Dvere** | šírka 64 px, výška [DOPLNIŤ] | 2 stavy: zatvorené (so zámkou) a otvorené |
| **Portréty Magnetóna** | 128 × 128 px | 3 výrazy: neutral, happy, surprised |
| **Ikony HUD / inventára** | 32 × 32 px (slot má 48 × 48) | čitateľné aj v malej veľkosti |
| **Stavy rukavice** | [DOPLNIŤ] | vypnutá, zapnutá S, zapnutá J |

**Bedne podľa materiálu** – musia sa dať na prvý pohľad rozlíšiť (hráč podľa toho rieši hádanky):
- drevo (dá sa tlačiť rukou), železo, **magnet S**, **magnet J**, hliník, meď,
  prípadne plast (v kóde existuje).
- Póly: dohodnutá farba **S = červená, J = modrá** (tak sú aj v kóde) + písmeno S / J na bedni.
- Hliník (svetlosivý) a železo (tmavosivé) sa nesmú pliesť – [DOPLNIŤ, čím ich odlíšime].

**Kubo v 4 diagonálnych smeroch** – hráč sa na mriežke hýbe v 4 smeroch, ktoré na obrazovke
vyzerajú šikmo: hore-vpravo, dole-vpravo, dole-vľavo, hore-vľavo. Každý smer = jeden obrázok
(neskôr prípadne animácia chôdze – [DOPLNIŤ počet snímok]).

**Malé predmety, ktoré už sú v hre:** železný kľúč, drevená kocka, plastová fľaša.
Pripravujú sa aj oceľové mince (1, 2, 5 centov).

### Kam ukladať a ako pomenovať
Názvy súborov: **malé písmená, bez diakritiky a medzier, slová oddelené podčiarkovníkom** (`snake_case`).

```
art/
  tiles/        floor.png, wall.png, abyss.png
  objects/      box_wood.png, box_iron.png, box_magnet_s.png, box_magnet_j.png,
                box_aluminium.png, box_copper.png, door_closed.png, door_open.png
  characters/   kubo_up_right.png, kubo_down_right.png, kubo_down_left.png, kubo_up_left.png
  items/        item_key.png, item_wood_cube.png, item_bottle.png, item_coin_1.png ...
  portraits/    magneton_neutral.png, magneton_happy.png, magneton_surprised.png
  ui/           glove_off.png, glove_s.png, glove_j.png, inventory_slot.png, grafika menu (pozri nižšie) ...
  placeholders/ dočasné obrázky – postupne ich nahradíte, potom sa zmažú
```
Ak nevieš, kam niečo patrí, opýtaj sa v chate. Obrázky do hry zapojí programátor
(alebo stačí povedať, ktorý placeholder má nový obrázok nahradiť).

### Odporúčanie: nainštalujte si Godot
Stiahnite si **Godot 4.7.2** (pozri [Inštalácia](#inštalácia)) a otvorte projekt. Po uložení PNG do
priečinka `art/` ho Godot sám načíta a uvidíte, ako kresba vyzerá v hre (F5).
Godot pri tom vytvorí súbor `.import` (napr. `box_iron.png.import`) – ten **commitnite spolu s obrázkom**,
ale nič v ňom neupravujte.

### Zvuky
- Formát **OGG** (hudba, dlhšie zvuky) alebo **WAV** (krátke efekty).
- Priečinok `audio/`, pomenovanie tiež `snake_case` (napr. `glove_on.wav`, `door_open.ogg`).
- Zoznam potrebných zvukov: [DOPLNIŤ]

---

## Grafika menu

Menu má zatiaľ dočasný vzhľad. Keď dodáte tieto súbory do `art/ui/`, programátor ich zapojí bez zmeny kódu.

| Súbor | Čo to je | Odporúčaný rozmer | Poznámka |
|---|---|---|---|
| `menu_background.png` | pozadie menu | 1280 × 720 px | stred nechaj pokojný, budú na ňom tlačidlá |
| `logo.png` | logo MagnetoLab | približne 640 × 200 px | priehľadné pozadie |
| `button_normal.png` | tlačidlo – bežný stav | 64 × 64 px | NinePatch, rohy 16 px |
| `button_hover.png` | tlačidlo – vybrané | 64 × 64 px | NinePatch, rohy 16 px |
| `button_pressed.png` | tlačidlo – stlačené | 64 × 64 px | NinePatch, rohy 16 px |
| `button_disabled.png` | tlačidlo – neaktívne | 64 × 64 px | NinePatch, rohy 16 px |
| `panel.png` | panel / okno | 96 × 96 px | NinePatch, rohy 24 px |
| `inventory_slot.png` | políčko inventára | 64 × 64 px | NinePatch, rohy 12 px |
| `icon_lock.png` | ikona zámku na zamknutej miestnosti | 32 × 32 px | priehľadné pozadie |
| `game_font.ttf` (alebo `.otf`) | písmo hry | – | musí mať slovenskú diakritiku (ľ, š, č, ť, ž, ý, á, í, é, ô, ä, ň, ď, ĺ, ŕ) |

Ak písmo alebo iný súbor nie je vaše vlastné dielo, zapíšte ho do [`CREDITS.md`](CREDITS.md).

### Ako kresliť tlačidlá a panely (NinePatch)

Tlačidlá a panely v hre majú rôzne veľkosti (krátke „OK“, dlhé „Výber miestnosti“, veľké okno s textom). Aby sme nemuseli kresliť každé zvlášť, používame **NinePatch**: nakreslíš **jeden malý obrázok** a hra ho natiahne na akúkoľvek veľkosť bez toho, aby sa rozmazali rohy.

Obrázok sa pomyselne rozdelí na **9 častí**:

```
+------+----------------+------+
| roh  |  horný okraj   | roh  |
+------+----------------+------+
| ľavý |                | pravý|
|okraj |     stred      |okraj |
+------+----------------+------+
| roh  |  dolný okraj   | roh  |
+------+----------------+------+
```

- **Rohy** sa nikdy nenaťahujú, zostávajú presne tak, ako ich nakreslíš.
- **Horný a dolný okraj** sa naťahujú len do šírky.
- **Ľavý a pravý okraj** sa naťahujú len do výšky.
- **Stred** sa naťahuje oboma smermi.

#### Pravidlá kreslenia
1. **Ozdoby a detaily patria len do rohov.** Čokoľvek v okrajoch alebo strede sa roztiahne a zdeformuje.
2. **Okraje a stred musia byť jednoliate:** rovnaká farba alebo vzor, ktorý sa opakuje v smere naťahovania (žiadny prechod farieb z jednej strany na druhú, žiadne písmená ani ikony).
3. **Všetky rohy rovnako veľké.** Odporúčame **16 px**. Ak potrebuješ inú veľkosť, napíš ju do tabuľky nižšie, programátor ju nastaví.
4. **Text na tlačidlo nekresli**, ten dopĺňa hra (kvôli rôznym nápisom a jazykom).
5. Formát **PNG s priehľadným pozadím**.

#### Odporúčané rozmery

| Prvok | Rozmer obrázka | Rohy |
|---|---|---|
| Tlačidlo | 64 × 64 px | 16 px |
| Panel / okno (dialógy, nastavenia) | 96 × 96 px | 24 px |
| Políčko inventára | 64 × 64 px | 12 px |

#### Stavy tlačidla
Každé tlačidlo potrebuje 4 verzie v **rovnakom rozmere a s rovnakými rohmi**:

| Súbor | Kedy sa zobrazí |
|---|---|
| `button_normal.png` | bežný stav |
| `button_hover.png` | myš je nad tlačidlom alebo je vybrané klávesnicou (napr. svetlejšie) |
| `button_pressed.png` | tlačidlo je stlačené (napr. tmavšie, mierne „zatlačené“) |
| `button_disabled.png` | tlačidlo nejde stlačiť (napr. sivé) |

Všetko ukladaj do `art/ui/`.

#### Ako si to vyskúšať (voliteľné)
V Godote pridaj do akejkoľvek scény uzol **NinePatchRect**, vlož mu svoj obrázok do `Texture` a v `Patch Margin` nastav veľkosť rohov (napr. 16 na všetkých stranách). Potom ho ťahaj za okraje. Ak sa rohy nedeformujú a okraje vyzerajú dobre, obrázok je správne nakreslený.

---

## 6. Zdroje a licencie
- Používame **len vlastné diela** alebo diela **voľne použiteľné** (ideálne licencia **CC0**).
- Každý cudzí asset (obrázok, zvuk, písmo, hudba) **hneď zapíš do [`CREDITS.md`](CREDITS.md)**:
  názov, autor, odkaz, licencia.
- Nepoužívame obrázky z Google vyhľadávania ani nič, pri čom nevieme, kto je autor a aká je licencia.

---

## 7. Práca s Gitom a GitHubom

### Pravidlá (pre všetkých)
1. **Pred prácou vždy stiahni zmeny** (pull).
2. **Po práci commit a push** – nenechávaj zmeny len u seba.
3. **Malé commity s jasnou správou**, napr. `Pridana bedna box_iron.png` alebo `Level A2: rozmiestnenie objektov`.
4. **Na jednej scéne `.tscn` naraz pracuje len jeden človek.** Kto ide upravovať scénu, napíše to
   do chatu ([DOPLNIŤ – názov skupiny / kanála]) a po pushnutí ju „uvoľní“.
5. **Nikdy necommituj priečinok `.godot/`** (je v `.gitignore`, Godot si ho vytvára sám).
6. **Pri konflikte nič neprepisuj ani nemaž** – zastav sa a ozvi sa v chate, vyriešime to spolu.

### Programátori – príkazy v termináli
```
git pull                         # stiahni zmeny ostatných (vždy pred prácou)
git status                       # čo som zmenil
git diff                         # ako presne som to zmenil
git add scenes/objects/door.gd   # pridaj konkrétne súbory (alebo: git add .)
git commit -m "Dvere: zvuk pri otvoreni"
git push                         # pošli zmeny na GitHub
```
Pred `git add .` skontroluj `git status`, aby si necommitol niečo navyše.

### Grafici – GitHub Desktop
1. Nainštaluj **GitHub Desktop**: <https://desktop.github.com/> a prihlás sa svojím GitHub účtom.
2. **File → Clone repository → URL** → `https://github.com/UCM-MS/Magnetolab.git` → vyber priečinok → **Clone**.
3. **Pred prácou:** hore klikni **Fetch origin** a potom **Pull origin**.
4. Ulož obrázky do správneho priečinka v `art/`.
5. V GitHub Desktop vľavo uvidíš zmenené súbory. Dole napíš krátku správu (napr. `Pridane bedne`)
   a klikni **Commit to main**.
6. Hore klikni **Push origin**.
7. Ak sa objaví hláška o **konflikte**, nič neklikaj „naslepo“ – napíš do chatu.

---

## 8. Použitie AI
- Pri programovaní môžeme používať AI asistenta.
- **Každý člen musí rozumieť kódu, ktorý commitne** – na obhajobe ho musíme vedieť vysvetliť.
- Kód od AI si pred commitom prečítaj, spusti hru a over, že funguje. Ak niečomu nerozumieš,
  nechaj si to vysvetliť (alebo sa opýtaj kolegu) skôr, než to commitneš.
- Fyzika v hre musí byť správna – ak AI navrhne niečo, čo nesedí s učivom, oprav to.

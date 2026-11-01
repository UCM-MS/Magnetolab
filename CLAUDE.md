# MagnetoLab – náučná hra o magnetizme

Tímová semestrálna práca (predmet Multimediálne systémy, UCM Trnava). Tím: 2 programátori, 2 grafici.
Kód musíme vedieť vysvetliť na obhajobe: píš čitateľne, s krátkymi komentármi v slovenčine a po každej
väčšej zmene stručne vysvetli, čo a prečo si spravil.

## Hra v skratke
- Izometrická 2.5D logická hra s pohľadom zhora. Hráč prechádza miestnosťami laboratória,
  v každej nájde kľúč a otvorí dvere. Hádanky sa riešia magnetmi.
- Dva varianty (výber na začiatku hry):
  - **Variant A – 4. ročník, prírodoveda:** čo magnet priťahuje, póly, magnetické pole, kompas.
  - **Variant B – 9. ročník, fyzika:** Zem ako magnet, pole vodiča a cievky s prúdom, elektromagnet.
- Bádateľský postup v každej miestnosti: odhadni → vyskúšaj → kartička „Čo si zistil“.

## Príbeh
- Hráč je chlapec **Kubo** (10 rokov). Zaspí pred testom z magnetizmu a v sne sa ocitne
  v laboratóriu **profesora Magnetóna**.
- Magnetón sa mu prihovára z obrazoviek na stenách: dáva otázky (odhadni), nápovedy,
  spätnú väzbu a kartičky „Čo si zistil“.
- Povaha Magnetóna: priateľský, nadšený vedec. Hovorí **krátko a jednoducho**,
  Kuba **oslovuje menom**. Takto píš všetky texty pre hráča.
- Na konci hry sa Kubo zobudí a píše test (záverečný kvíz) – zatiaľ sa nerobí.
- Všetko, čo Magnetón hovorí, sa zobrazuje cez jednotné dialógové okno
  (`scenes/ui/dialog_box.tscn`): portrét vľavo (výraz neutral / happy / surprised),
  meno, text, pokračovanie klávesom E alebo medzerníkom.

## Technológia
- Godot 4, **GDScript**, renderer **Compatibility**, cieľová platforma **Windows (.exe)**.
- Izometria: `TileMapLayer` s TileSetom `Tile Shape = Isometric`, dlaždice 2:1 (64 × 32 px).
- Prekrývanie objektov: **Y Sort** na uzle s hráčom a objektmi.

## Architektúra (dôležité)
- **Herná logika beží na mriežke**, nie na fyzike. Pozície objektov sú `Vector2i` (políčka).
  Izometria je len vykreslenie: prevod cez `TileMapLayer.map_to_local()` / `local_to_map()`.
- Nepoužívaj `RigidBody2D` ani fyzikálny engine na hernú logiku. Pohyb je po políčkach,
  animovaný cez `Tween`.
- Jeden zdroj pravdy o obsadenosti políčok (napr. `GridManager` / autoload), ktorý vie,
  čo stojí na ktorom políčku a či je políčko priechodné.
- Každý herný objekt je samostatná scéna (`.tscn`) so skriptom, ktorú sa dá vložiť do levelu.
- Komunikácia medzi objektmi cez **signály** (napr. tlačidlo → dvere), nie cez pevné cesty k uzlom.
- Texty kartičiek a údaje o leveloch drž v `Resource` súboroch (`.tres`), nie natvrdo v kóde.

## Pravidlá mechaník
### Magnetická rukavica (elektromagnet)
- Stavy: **vypnutá / zapnutá S / zapnutá J**. Medzerník = zapnúť/vypnúť, Q = prepnúť pól.
- Pôsobí **v smere, ktorým sa hráč pozerá**, na **prvý magnetický objekt v rade**
  (nemagnetický objekt v ceste lúč zastaví).
- Priťahovanie: objekt sa posúva k hráčovi, kým nie je na susednom políčku alebo nenarazí.
- Odpudzovanie: objekt sa posúva od hráča, kým nenarazí na prekážku.
- Zapnutá rukavica drží pritiahnutý objekt pri hráčovi (hráč ho nesie); vypnutím ho pustí.

### Materiály a póly – FYZIKÁLNA SPRÁVNOSŤ JE POVINNÁ
- **Železo** (bedne, kľúče, oceľové mince 1, 2, 5 centov) je priťahované **oboma pólmi**.
  Železo sa NIKDY neodpudzuje – ani pri prepnutí pólu.
- **Permanentné magnety** (bedne s pólmi S/J, magnetický kotúč): opačné póly sa priťahujú,
  rovnaké odpudzujú.
- **Drevo, plast, hliník, meď** na magnet nereagujú.

### Tlačenie rukou
- Tlačiť rukou (o 1 políčko, ak je za bedňou voľno) sa dajú **iba drevené bedne**.
- Kovové bedne (železo, magnety s pólom, hliník, meď) sú príliš ťažké, rukou sa nepohnú:
  - železné bedne a bedne s pólom sa dajú posúvať **len rukavicou**,
  - hliníkové a medené bedne sa nedajú pohnúť vôbec (pevná prekážka).
- Pri pokuse tlačiť kovovú bedňu sa zobrazí hláška „Je príliš ťažká, skús magnet“
  (len prvýkrát v leveli).
- Elektromagnet funguje len so zapnutým prúdom; smer prúdu určuje póly; sila rastie
  s počtom závitov, prúdom a železným jadrom.
- Ak si pri nejakej mechanike nie si istý fyzikou, opýtaj sa, nevymýšľaj.

### Priepasť
- Samostatná dlaždica (príznak `abyss` v TileSete). Nedá sa na ňu vstúpiť ani na ňu posunúť
  objekt (bedňa sa zastaví na okraji), ale **lúč rukavice cez ňu prechádza**.

### Malé predmety (kľúč, mince...)
- Údaje o druhu predmetu (meno, materiál, ikona, či je to kľúč) sú v `ItemData` (.tres).
- Kým leží, zaberá políčko a zastaví lúč ako každý objekt.
- Železný malý predmet, ktorý rukavica pritiahne (**oboma pólmi**, je to železo), **preletí
  k hráčovi** (aj ponad priepasť) a uloží sa do **inventára**. Rukavica predmety nedrží.
- Inventár (`Inventory`, uzol pod hráčom) má 6 slotov a pamätá si druhy predmetov (`ItemData`).
  HUD ukazuje panel inventára so slotmi a ikonami. Keď je inventár plný, predmet ostane ležať.
- Predmety z inventára používajú iné objekty (napr. dvere si vezmú kľúč).

### Dvere
- Zamknuté dvere otvorí hráč, ktorý má kľúč v inventári: stojí pred dverami, pozerá sa
  na ne a stlačí **E**. Kľúč sa z inventára odstráni. Bez kľúča Magnetón povie, že treba kľúč.
- Po otvorení dverí sa ukáže kartička „Čo si zistil“ – len zhrnutie, bez hodnotenia tipu.

### Bádateľský postup v leveli (rovnako vo všetkých leveloch)
1. **Odhadni:** pri vstupe do miestnosti s pokusom Magnetón položí otázku s možnosťami
   (strana `DialogPage` s `options`). Level si zapamätá zvolenú možnosť.
2. **Vyskúšaj:** hráč urobí pokus. V `LevelData.guess_check_item` je predmet, ktorého
   **prvé pritiahnutie** je pokusom.
3. **Spätná väzba hneď po pokuse:** Magnetón povie text z `LevelData.guess_feedback`
   podľa zvolenej možnosti (index = číslo možnosti od 0). Ukáže sa len raz.
4. **Kartička „Čo si zistil“** (`LevelData.info_card`) po otvorení dverí – len zhrnutie.

### Texty, spúšťacie oblasti, tabule
- Všetky texty pre hráča sú v Resource súboroch a zobrazujú sa cez `DialogBox`
  (hovorí profesor Magnetón, `resources/characters/magneton.tres`):
  - dialógy `DialogData` = strany `DialogPage` (nadpis, text, výraz portrétu `mood`;
    strana môže byť otázka s možnosťami),
  - spätná väzba k tipu a kartička „Čo si zistil“ v `LevelData` (resources/level_xx/level_xx.tres),
  - spoločné reakcie (ťažká bedňa, zamknuté dvere...) v `resources/ui_texts.tres`.
- Spúšťacia oblasť (`TriggerZone`) = obdĺžnik políčok; pri prvom vstupe hráča ukáže dialóg.
  Nezaberá políčko.
- Tabuľa (`InfoSign`) ukáže dialóg po stlačení E.
- Kým je otvorený dialóg alebo kartička, hra stojí. Odpoveď na otázku sa vyberá klávesmi 1–3
  alebo myšou.

### Ďalšie prvky
- Tlačidlá na podlahe (aktivuje ich bedňa alebo hráč), dvere s kľúčom, kompas,
  železné piliny (zobrazia siločiary skrytých magnetov).
- Variant B: vodič s prúdom a vypínač, elektromagnety, pohyblivé platformy so železným
  podvozkom, sekvencia elektromagnetov (zapnutý magnet ťahá platformu k sebe).
- Bonus (až po MVP): strážny robot, ktorého vypne zásah magnetickým kotúčom.

## Ovládanie
- WASD / šípky – pohyb po mriežke (pri izometrii namapovať na diagonály mapy)
  - Stlačenie smeru, ktorým sa hráč nepozerá, ho len **otočí na mieste** (zmení facing, bez pohybu).
    Krok vykoná, až keď sa už pozerá daným smerom.
  - Pri podržaní klávesu sa po otočení začne pohybovať po krátkej pauze (~0,15 s).
- Medzerník – rukavica zap/vyp, Q – pól, E – interakcia (s objektom, na ktorý sa hráč pozerá),
  R – reštart miestnosti
- V dialógu: E / Enter – pokračovať, 1–3 – výber odpovede

## Štruktúra priečinkov
```
res://
  scenes/
    levels/        # level_a1.tscn, level_b1.tscn ...
    objects/       # player.tscn, iron_box.tscn, magnet_box.tscn, door.tscn, key.tscn ...
    ui/            # main_menu.tscn, hud.tscn, info_card.tscn ...
  scripts/         # spoločné skripty a autoloady (grid_manager.gd, game_state.gd)
  resources/       # .tres – dáta levelov a kartičiek
  art/             # sprity a tilesety od grafikov (nemeň ich obsah)
  audio/
```

## Konvencie kódu
- GDScript so **statickým typovaním** (`var speed: float = 2.0`, `func move(dir: Vector2i) -> void`).
- `snake_case` pre súbory, premenné a funkcie, `PascalCase` pre `class_name`.
- Exportované premenné (`@export`) pre veci, ktoré sa nastavujú v editore (napr. materiál, pól).
- Malé, jasné funkcie. Žiadne „magické čísla“ – konštanty pomenuj.

## Pracovný postup
- Rob malé kroky: jedna funkcia alebo jeden objekt naraz, potom spusti projekt a over,
  či nie sú chyby v konzole.
- Nemeň obsah priečinka `.godot/` ani súbory `.import` – generuje ich Godot.
- Pred väčšou zmenou štruktúry (presun súborov, premenovanie scén) sa najprv opýtaj.
- Nemaž súbory bez potvrdenia.

## Rozsah
- **MVP:** variant A (6 miestností A1–A6), spoločné mechaniky, kartičky.
- **Plná verzia:** variant B (B1–B7).
- **Bonus:** strážny robot, denník bádateľa, cutscény.

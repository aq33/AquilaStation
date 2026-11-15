"""Wspólne tablice zamienników przy konwersji map Shiptesta (ruiny i greeble planet) na nasz kod.
Pierwotnie z portu ruin planety wulkanicznej (AQ#639). Każdy typ planety dopisuje własny moduł w tym folderze
(mappings/<typ>.py) i woła rep()/TURFS/AREAS/TR, zamiast zmieniać ten plik, chyba że zamiennik jest ogólny.
Wartość w R: None = pomiń, 'ścieżka', (ścieżka, {zmienne}).
"""
import collections

LAVA_GAS = '"o2=14;n2=5;co2=13;TEMP=300"'

# ---------------------------------------------------------------- tłumaczenia (nazwy i opisy edytowane na mapie)
TR = {
    'Window Shutters': 'rolety okienne',
    "It doesn't look very healthy...": 'Nie wygląda zbyt zdrowo...',
    'potted plant': 'roślina doniczkowa',
    'Bathroom': 'Łazienka',
    'bathroom': 'łazienka',
    'Engineering': 'Inżynieria',
    'Shattered Mirror': 'rozbite lustro',
    'Alcohol Closet': 'szafka z alkoholem',
    'Medbay': 'Ambulatorium',
    'Dormitories': 'Sypialnie',
    'distribution output pump': 'pompa wyjścia dystrybucji',
    'Syndiemoth plushie': 'pluszowa ćma Syndykatu',
    'ammunition locker': 'szafka z amunicją',
    'tactical swivel chair': 'taktyczny fotel obrotowy',
    'Blast Shutters': 'rolety przeciwwybuchowe',
    'armory locker': 'szafka zbrojowni',
    'engine fuel pump': 'pompa paliwa silnika',
    'Engine Access': 'Dostęp do silnika',
    'pepper': 'Papryczka',
    'Bridge lockdown': 'blokada mostka',
    'Window Lockdown': 'blokada okien',
    'cargo shutters': 'rolety ładowni',
    'It looks incredibly comfy, and expensive. Theres a little note on the side, explaining how its made of %100 real cow skin.':
        'Wygląda na niesamowicie wygodny i drogi. Na boku jest karteczka z zapewnieniem, że to 100% prawdziwa skóra krowia.',
    'Cowskin chair': 'fotel z krowiej skóry',
    'uniform closet': 'szafa z mundurami',
    'Warehouse Alpha': 'Magazyn Alfa',
    'Helm': 'Ster',
    'Bravo Turret': 'Wieżyczka Bravo',
    'Alpha Turret': 'Wieżyczka Alfa',
    'Mess Hall': 'Mesa',
    'shutter control': 'sterowanie roletami',
    'Exterior Shutters': 'rolety zewnętrzne',
    'Sierra Cell': 'cela Sierra',
    'refrigerator': 'lodówka',
    "Sergeant's closet": 'szafa sierżanta',
    "pilot's closet": 'szafa pilota',
    "Sergeant's Quarters": 'Kwatera sierżanta',
    'Epsilon Cell': 'cela Epsilon',
    "Sergeant's Bedroom": 'Sypialnia sierżanta',
    'Resupply': 'Zaopatrzenie',
    'Call the Sergeant': 'wezwij sierżanta',
    'bathroom lock': 'zamek łazienki',
    'Ms. Viscerator': 'Pani Wypruwacz',
    'Damaged Verdict Turret': 'uszkodzona wieżyczka Werdykt',
    'Headquarters': 'Kwatera główna',
    'Barracks': 'Koszary',
    'leaking high-capacity water tank': 'cieknący zbiornik wody o dużej pojemności',
    'What was once a highly pressurized non-potable water tank made to hold gargantuan amounts of water. A gash along its side released its torrential volume upon the floor.':
        'Kiedyś był to ciśnieniowy zbiornik na ogromne ilości wody niezdatnej do picia. Rozcięcie w boku wylało całą jego zawartość na podłogę.',
    "Men's Restroom": 'Toaleta męska',
    'Warehouse Entry': 'Wejście do magazynu',
    "Women's Restroom": 'Toaleta damska',
    "Sergeant's Office": 'Gabinet sierżanta',
    "mechanic's closet": 'szafka mechanika',
    'Unisex Shower': 'Prysznic koedukacyjny',
    'armoring locker': 'szafka z pancerzami',
    'Zulu Turret': 'Wieżyczka Zulu',
    'Telecommunications': 'Telekomunikacja',
    'Warehouse Beta': 'Magazyn Beta',
    'shower lock': 'zamek prysznica',
    'Gamma Cell': 'cela Gamma',
    'kitchen cabinet': 'szafka kuchenna',
    'Damaged Acquittal Turret': 'uszkodzona wieżyczka Uniewinnienie',
    'Yankee Turret': 'Wieżyczka Yankee',
    'Privacy Shutters': 'rolety prywatności',
    'Kitchen': 'Kuchnia',
    "folder- 'SUPPLY LOGS'": "teczka – „DZIENNIKI ZAOPATRZENIA”",
    'Ramzi Clique Coach': 'trener Kliki Ramziego',
    'A deserter from the Gorlex Marauders turned pirate. They hold a clean and razor-sharp knife, and hold a small red flag.':
        'Dezerter z Maruderów Gorlex, który został piratem. Trzyma czysty, ostry jak brzytwa nóż i małą czerwoną flagę.',
    'Ramzi Clique Foreman': 'brygadzista Kliki Ramziego',
    'Documentation': 'Dokumentacja',
    'Washroom': 'Umywalnia',
    'equipment locker': 'szafka ze sprzętem',
    'Ramzi Clique Houndmaster': 'psiarz Kliki Ramziego',
    'armor locker': 'szafka z pancerzami',
    'Dissection': 'Sekcja',
    'Dorm': 'Sypialnia',
    'fuel crate': 'skrzynia z paliwem',
    'Ramzi Clique Ballmaster': 'piłkarz Kliki Ramziego',
    'Showers': 'Prysznice',
    'Excavation Gear': 'Sprzęt wykopaliskowy',
    'Office Lockdown': 'blokada biura',
    'Security Lockdown': 'blokada ochrony',
    'An issue of The Griffon from 497 FS, a newspaper often found circulating aboard Makosso-Warra Space Stations. Most of the articles have been ripped out.':
        'Numer „The Griffon” z 497 FS, gazety krążącej po stacjach kosmicznych Makosso-Warra. Większość artykułów wyrwano.',
    'torn up newspaper': 'podarta gazeta',
    "A worn out photo. You can barely make out a few figures. They're all smiling.":
        'Wytarte zdjęcie. Ledwo widać na nim kilka postaci. Wszystkie się uśmiechają.',
    'worn out photo': 'wytarte zdjęcie',
    'ripley crate': 'skrzynia z Ripleyem',
    'Manager': 'kierownik',
    'Warehouse': 'Magazyn',
    'Malfunctioning Presser': 'zepsuta prasa',
    'Warehouse Shutters': 'rolety magazynu',
    'broken windoor': 'zepsute drzwi okienne',
    'Restroom': 'Toaleta',
    'mining crate': 'skrzynia górnicza',
    'Door Buzzer': 'dzwonek do drzwi',
    'shower locker': 'szafka przy prysznicu',
}
EN = {}  # polski -> angielski (en_strings.json)


DECISIONS = collections.OrderedDict()  # ścieżka shiptest -> opis

# ---------------------------------------------------------------- mapowanie ścieżek
# wartość: None = pomiń; 'ścieżka'; albo (ścieżka, {zmienne}); albo funkcja(path, vars, ctx) -> lista atomów
R = {}
def rep(old, new, note=None):
    R[old] = new
    if note:
        DECISIONS[old] = note

# --- moby
for p, n in {
    '/mob/living/basic/human/ramzi': '/mob/living/basic/trooper/syndicate/melee',
    '/mob/living/basic/human/ramzi/civilian/towel': '/mob/living/basic/trooper/syndicate/melee',
    '/mob/living/basic/human/ramzi/melee': '/mob/living/basic/trooper/syndicate/melee',
    '/mob/living/basic/human/ramzi/melee/sawbones': '/mob/living/basic/trooper/syndicate/melee',
    '/mob/living/basic/human/ramzi/melee/sledge': '/mob/living/basic/trooper/syndicate/melee/sword',
    '/mob/living/basic/human/ramzi/melee/sledge/engi': '/mob/living/basic/trooper/syndicate/melee/sword',
    '/mob/living/basic/human/ramzi/melee/space/machete': '/mob/living/basic/trooper/syndicate/melee/space',
    '/mob/living/basic/human/ramzi/melee/space/sledge': '/mob/living/basic/trooper/syndicate/melee/sword/space',
    '/mob/living/basic/human/ramzi/melee/space/stormtrooper/commander': '/mob/living/basic/trooper/syndicate/melee/sword/space/stormtrooper',
    '/mob/living/basic/human/ramzi/ranged': '/mob/living/basic/trooper/syndicate/ranged',
    '/mob/living/basic/human/ramzi/ranged/cottonmouth': '/mob/living/basic/trooper/syndicate/ranged/smg',
    '/mob/living/basic/human/ramzi/ranged/hydra': '/mob/living/basic/trooper/syndicate/ranged/smg',
    '/mob/living/basic/human/ramzi/ranged/hydra/dmr/sentry/ballistic': '/mob/living/basic/trooper/syndicate/ranged',
    '/mob/living/basic/human/ramzi/ranged/officer': '/mob/living/basic/trooper/syndicate/ranged',
    '/mob/living/basic/human/ramzi/ranged/officer/asp': '/mob/living/basic/trooper/syndicate/ranged',
    '/mob/living/basic/human/ramzi/ranged/runt': '/mob/living/basic/trooper/syndicate/ranged',
    '/mob/living/basic/human/ramzi/ranged/shotgun': '/mob/living/basic/trooper/syndicate/ranged/shotgun',
    '/mob/living/basic/human/ramzi/ranged/smg': '/mob/living/basic/trooper/syndicate/ranged/smg',
    '/mob/living/basic/human/ramzi/ranged/space': '/mob/living/basic/trooper/syndicate/ranged/space',
    '/mob/living/basic/human/ramzi/ranged/space/shotgun': '/mob/living/basic/trooper/syndicate/ranged/shotgun/space',
    '/mob/living/basic/human/ramzi/ranged/space/smg': '/mob/living/basic/trooper/syndicate/ranged/smg/space',
    '/mob/living/basic/human/ramzi/ranged/space/smg/sidewinder': '/mob/living/basic/trooper/syndicate/ranged/smg/space',
    '/mob/living/basic/human/ramzi/ranged/space/sniper/sentry': '/mob/living/basic/trooper/syndicate/ranged/space',
    '/mob/living/basic/human/ramzi/ranged/space/stormtrooper/shotgun': '/mob/living/basic/trooper/syndicate/ranged/shotgun/space/stormtrooper',
    '/mob/living/basic/human/ramzi/ranged/space/stormtrooper/smg': '/mob/living/basic/trooper/syndicate/ranged/smg/space/stormtrooper',
}.items():
    rep(p, n)
DECISIONS['/mob/living/basic/human/ramzi/*'] = 'Klika Ramziego -> nasi żołnierze Syndykatu (basic trooper) według broni'
rep('/mob/living/basic/human/warra/elite', '/mob/living/basic/trooper/nanotrasen/ranged/smg', 'Vigilitas -> żołnierz NT (frakcja nanotrasenprivate)')
rep('/mob/living/simple_animal/hostile/asteroid/goliath/beast', '/mob/living/basic/mining/goliath')
rep('/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient/crystal', '/mob/living/basic/mining/goliath/crystal')
rep('/mob/living/simple_animal/hostile/asteroid/goliath/pup', '/mob/living/basic/mining/goliath', 'szczenię goliata -> goliat')
rep('/mob/living/simple_animal/hostile/asteroid/hivelord/legion', '/mob/living/basic/mining/legion')
rep('/mob/living/simple_animal/hostile/asteroid/hivelord/legion/crystal', '/mob/living/basic/mining/legion/crystal')
rep('/mob/living/simple_animal/hostile/asteroid/wolf/hound/ramzi', '/mob/living/basic/mining/ramzi_hound', 'PORT: rajzehund (basic mob)')
rep('/mob/living/simple_animal/hostile/automated/bipedal', ('/mob/living/basic/hivebot/range', {'faction': 'list("Syndicate")'}), 'platforma szturmowa -> hivebot strzelający, frakcja Syndykatu')
rep('/mob/living/simple_animal/hostile/automated/rover', ('/mob/living/basic/hivebot/rapid', {'faction': 'list("nanotrasenprivate")'}), 'łazik Vigilitas -> szybki hivebot, frakcja jak żołnierze NT')

# --- zwłoki
for p, n in {
    '/obj/effect/mob_spawn/human/corpse/clip/captain': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
    '/obj/effect/mob_spawn/human/corpse/clip/minuteman': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
    '/obj/effect/mob_spawn/human/corpse/clip/researcher': '/obj/effect/mob_spawn/human/corpse/assistant',
    '/obj/effect/mob_spawn/human/corpse/frontier': '/obj/effect/mob_spawn/human/corpse/pirate',
    '/obj/effect/mob_spawn/human/corpse/frontier/ranged/officer': '/obj/effect/mob_spawn/human/corpse/pirate/ranged',
    '/obj/effect/mob_spawn/human/corpse/hardliner/mechanic': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
    '/obj/effect/mob_spawn/human/corpse/hardliner/sergeant/holdout': '/obj/effect/mob_spawn/human/corpse/syndicatecommando',
    '/obj/effect/mob_spawn/human/corpse/hardliner/trooper/holdout1': ('/obj/effect/mob_spawn/human/corpse/syndicatesoldier', {'brute_damage': '252', 'mob_species': '/datum/species/lizard'}),
    '/obj/effect/mob_spawn/human/corpse/hardliner/trooper/holdout2': ('/obj/effect/mob_spawn/human/corpse/syndicatesoldier', {'mob_gender': '"female"', 'mob_name': '"Marianne Tchaikovski"', 'mob_species': '/datum/species/human'}),
    '/obj/effect/mob_spawn/human/corpse/pgf/downed_pilot': '/obj/effect/mob_spawn/human/corpse/damaged',
    '/obj/effect/mob_spawn/human/corpse/pgf/skeleton_marine': '/obj/effect/mob_spawn/human/corpse/charredskeleton',
    '/obj/effect/mob_spawn/human/corpse/ramzi': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
    '/obj/effect/mob_spawn/human/corpse/ramzi/engi': '/obj/effect/mob_spawn/human/corpse/syndicatesoldier',
    '/obj/effect/mob_spawn/human/corpse/ramzi/towel': '/obj/effect/mob_spawn/human/corpse/assistant',
    '/obj/effect/mob_spawn/human/corpse/vigilitas_private': '/obj/effect/mob_spawn/human/corpse/nanotrasensoldier',
}.items():
    rep(p, n)
DECISIONS['/obj/effect/mob_spawn/human/corpse/*'] = 'zwłoki frakcji Shiptesta -> nasze zwłoki (Syndykat, NT, pirat, asystent)'

# --- efekty i spawnery
rep('/obj/effect/decal/cleanable/blood/squirt', '/obj/effect/decal/cleanable/blood/splatter')
rep('/obj/effect/decal/cleanable/garbage', '/obj/effect/decal/cleanable/dirt')
rep('/obj/effect/decal/cleanable/plastic', '/obj/effect/decal/cleanable/dirt')
rep('/obj/effect/decal/cleanable/wrapping', None)
rep('/obj/effect/landmark/subship', None, 'pominięty: lądowisko podstatku (mechanika statków Shiptesta)')
rep('/obj/effect/mapping_helpers/chair/tim_buckley', None)
rep('/obj/effect/spawner/bunk_bed', '/obj/structure/bed', 'łóżko piętrowe -> zwykłe łóżko')
rep('/obj/effect/spawner/random/bedsheet', '/obj/item/bedsheet/random')
rep('/obj/effect/spawner/random/decoration/glowstick', '/obj/effect/spawner/lootdrop/glowstick')
rep('/obj/effect/spawner/random/food_or_drink/ration', '/obj/item/food/donkpocket', 'racja żywnościowa -> donkpocket')
rep('/obj/effect/spawner/random/maintenance', '/obj/effect/spawner/lootdrop/maintenance')
rep('/obj/effect/spawner/random/trash/decal', '/obj/effect/decal/cleanable/dirt')
rep('/obj/effect/spawner/random/vending/snack', '/obj/machinery/vending/snack/random')
rep('/obj/effect/spawner/structure/window/plasma/reinforced/plastitanium', '/obj/effect/spawner/structure/window/plastitanium')

# --- amunicja i broń (bez nowych typów: najbliższe nasze)
EMPTY = {'start_empty': '1'}
for p, n in {
    '/obj/item/ammo_box/magazine/co9mm': '/obj/item/ammo_box/magazine/pistolm9mm',
    '/obj/item/ammo_box/magazine/f90': '/obj/item/ammo_box/magazine/m556',
    '/obj/item/ammo_box/magazine/g12/empty': ('/obj/item/ammo_box/magazine/m12g', EMPTY),
    '/obj/item/ammo_box/magazine/m10mm_ringneck': '/obj/item/ammo_box/magazine/m10mm',
    '/obj/item/ammo_box/magazine/m22lr_himehabu': '/obj/item/ammo_box/magazine/m10mm',
    '/obj/item/ammo_box/magazine/m556_42_hydra/extended/empty': ('/obj/item/ammo_box/magazine/m556', EMPTY),
    '/obj/item/ammo_box/magazine/m57_39_sidewinder': '/obj/item/ammo_box/magazine/wt550m9',
    '/obj/item/ammo_box/magazine/m57_39_sidewinder/empty': ('/obj/item/ammo_box/magazine/wt550m9', EMPTY),
    '/obj/item/ammo_box/magazine/m9mm_expedition/empty': ('/obj/item/ammo_box/magazine/smgm9mm', EMPTY),
    '/obj/item/ammo_box/magazine/m9mm_rattlesnake/empty': ('/obj/item/ammo_box/magazine/pistolm9mm', EMPTY),
    '/obj/item/ammo_casing/spent/pistol_brass': '/obj/item/ammo_casing/spent',
    '/obj/item/ammo_casing/spent/pistol_steel': '/obj/item/ammo_casing/spent',
    '/obj/item/ammo_casing/spent/rifle_brass': '/obj/item/ammo_casing/spent',
    '/obj/item/ammo_casing/spent/rifle_steel': '/obj/item/ammo_casing/spent',
    '/obj/item/ammo_casing/spent/slug/buck': '/obj/item/ammo_casing/spent',
    '/obj/item/gun/ballistic/automatic/pistol/challenger/no_mag': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
    '/obj/item/gun/ballistic/automatic/pistol/himehabu': '/obj/item/gun/ballistic/automatic/pistol',
    '/obj/item/gun/ballistic/automatic/pistol/rattlesnake': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
    '/obj/item/gun/ballistic/automatic/pistol/ringneck': '/obj/item/gun/ballistic/automatic/pistol',
    '/obj/item/gun/ballistic/automatic/pistol/ringneck/no_mag': '/obj/item/gun/ballistic/automatic/pistol/no_mag',
    '/obj/item/gun/ballistic/automatic/smg/expedition/no_mag': ('/obj/item/gun/ballistic/automatic/wt550', {'spawnwithmagazine': '0'}),
    '/obj/item/gun/ballistic/automatic/smg/sidewinder/no_mag': ('/obj/item/gun/ballistic/automatic/wt550', {'spawnwithmagazine': '0'}),
    '/obj/item/gun/energy/sharplite/ohm': '/obj/item/gun/energy/e_gun/mini',
    '/obj/item/gun/energy/sharplite/volt': '/obj/item/gun/energy/laser/retro',
    '/obj/item/stock_parts/cell/gun/sharplite/empty': '/obj/item/stock_parts/cell/empty',
    '/obj/item/stock_parts/cell/gun/sharplite/heavy/plus': '/obj/item/stock_parts/cell/high/plus',
    '/obj/item/stock_parts/cell/gun/sharplite/mini': '/obj/item/stock_parts/cell',
    '/obj/item/storage/box/ammo/a12g_buckshot': '/obj/item/storage/box/lethalshot',
    '/obj/item/storage/box/ammo/a65clip': '/obj/item/ammo_box/a762',
    '/obj/item/storage/box/ammo/c10mm': '/obj/item/ammo_box/c10mm',
    '/obj/item/storage/box/ammo/c10mm_surplus': '/obj/item/ammo_box/c10mm',
    '/obj/item/storage/box/ammo/c57x39/ap': '/obj/item/ammo_box/c9mm',
    '/obj/item/storage/box/ammo/c9mm': '/obj/item/ammo_box/c9mm',
    '/obj/item/grenade/c4': '/obj/item/grenade/plastic/c4',
    '/obj/item/grenade/firecracker/dynamite': '/obj/item/grenade/iedcasing',
    '/obj/item/storage/box/smokebombs': '/obj/item/grenade/smokebomb',
    '/obj/item/melee/energy/sword/saber/pirate/yellow': '/obj/item/melee/transforming/energy/sword/pirate',
    '/obj/item/melee/knife/butcher': '/obj/item/kitchen/knife/butcher',
    '/obj/item/melee/knife/hunting': '/obj/item/kitchen/knife/hunting',
    '/obj/item/melee/knife/kitchen': '/obj/item/kitchen/knife',
    '/obj/item/melee/knife/shiv': '/obj/item/kitchen/knife',
    '/obj/item/melee/knife/survival': '/obj/item/kitchen/knife/combat/survival',
    '/obj/item/melee/sledgehammer/gorlex': '/obj/item/melee/sledgehammer',
    '/obj/item/melee/spear': '/obj/item/spear',
    '/obj/item/mine/pressure/explosive/fire/live': '/obj/effect/mine/explosive',
    '/obj/item/mine/pressure/explosive/shrapnel': '/obj/effect/mine/shrapnel',
}.items():
    rep(p, n)
DECISIONS['broń i amunicja'] = 'bronie Shiptesta -> najbliższe nasze (pistolet, WT-550, mini e-gun, retro laser), magazynki pustymi wersjami przez start_empty'
DECISIONS['/obj/item/grenade/firecracker/dynamite'] = 'dynamit -> nasz IED (iedcasing)'
DECISIONS['/obj/item/mine/pressure/*'] = 'miny naciskowe -> nasze uzbrojone miny /obj/effect/mine'

# --- ubrania
for p, n in {
    '/obj/item/clothing/glasses/hud/security/sunglasses/hardliners': '/obj/item/clothing/glasses/hud/security/sunglasses',
    '/obj/item/clothing/glasses/hud/security/sunglasses/ramzi': '/obj/item/clothing/glasses/hud/security/sunglasses',
    '/obj/item/clothing/gloves/color/captain/warra': '/obj/item/clothing/gloves/color/black',
    '/obj/item/clothing/gloves/nitrile': '/obj/item/clothing/gloves/color/latex/nitrile',
    '/obj/item/clothing/gloves/nitrile/evil': '/obj/item/clothing/gloves/color/latex/nitrile',
    '/obj/item/clothing/head/beret/qm': '/obj/item/clothing/head/beret/supply',
    '/obj/item/clothing/head/beret/sec/frontier': '/obj/item/clothing/head/beret/black',
    '/obj/item/clothing/head/beret/sec/frontier/officer': '/obj/item/clothing/head/beret/black',
    '/obj/item/clothing/head/hardhat/hardliners': '/obj/item/clothing/head/hardhat/red',
    '/obj/item/clothing/head/helmet/bulletproof/x11/frontier': '/obj/item/clothing/head/helmet/alt',
    '/obj/item/clothing/head/helmet/bulletproof/x11/ramzi': '/obj/item/clothing/head/helmet/alt',
    '/obj/item/clothing/head/helmet/hardliners': '/obj/item/clothing/head/helmet/sec',
    '/obj/item/clothing/head/helmet/m10': '/obj/item/clothing/head/helmet',
    '/obj/item/clothing/head/helmet/m10/ramzi': '/obj/item/clothing/head/helmet',
    '/obj/item/clothing/head/helmet/space/syndicate/ramzi/surplus': '/obj/item/clothing/head/helmet/space/syndicate/black/red',
    '/obj/item/clothing/head/helmet/space/syndicate/surplus': '/obj/item/clothing/head/helmet/space/syndicate',
    '/obj/item/clothing/head/helmet/space/syndicate/white_red': '/obj/item/clothing/head/helmet/space/syndicate',
    '/obj/item/clothing/head/ramzi/beret': '/obj/item/clothing/head/HoS/beret/syndicate',
    '/obj/item/clothing/head/ramzi/flap': '/obj/item/clothing/head/soft/black',
    '/obj/item/clothing/head/soft/cybersun': '/obj/item/clothing/head/soft/black',
    '/obj/item/clothing/mask/gas/ramzi': '/obj/item/clothing/mask/gas/syndicate',
    '/obj/item/clothing/neck/shemagh/ramzi': '/obj/item/clothing/mask/bandana/red',
    '/obj/item/clothing/suit/armor/hardliners': '/obj/item/clothing/suit/armor/vest',
    '/obj/item/clothing/suit/armor/hardliners/sergeant': '/obj/item/clothing/suit/armor/vest/alt',
    '/obj/item/clothing/suit/armor/ramzi': '/obj/item/clothing/suit/armor/vest',
    '/obj/item/clothing/suit/armor/ramzi/bulletproof': '/obj/item/clothing/suit/armor/bulletproof',
    '/obj/item/clothing/suit/armor/vest/frontier': '/obj/item/clothing/suit/armor/vest/alt',
    '/obj/item/clothing/suit/cybersun': '/obj/item/clothing/suit/toggle/labcoat',
    '/obj/item/clothing/suit/hazardvest/hardliners': '/obj/item/clothing/suit/hazardvest',
    '/obj/item/clothing/suit/hooded/wintercoat/security/hardliners': '/obj/item/clothing/suit/hooded/wintercoat/security',
    '/obj/item/clothing/suit/space/hardsuit/mining/clip': '/obj/item/clothing/suit/space/hardsuit/mining',
    '/obj/item/clothing/suit/space/hardsuit/mining/heavy': '/obj/item/clothing/suit/space/hardsuit/mining',
    '/obj/item/clothing/suit/space/syndicate/ramzi/surplus': '/obj/item/clothing/suit/space/syndicate/black/red',
    '/obj/item/clothing/suit/space/syndicate/surplus': '/obj/item/clothing/suit/space/syndicate',
    '/obj/item/clothing/suit/space/syndicate/white_red': '/obj/item/clothing/suit/space/syndicate',
    '/obj/item/clothing/under/clip': '/obj/item/clothing/under/rank/rnd/scientist',
    '/obj/item/clothing/under/clip/minutemen': '/obj/item/clothing/under/syndicate/camo',
    '/obj/item/clothing/under/frontiersmen/officer': '/obj/item/clothing/under/syndicate/camo',
    '/obj/item/clothing/under/rank/cargo/qm': '/obj/item/clothing/under/rank/cargo/quartermaster',
    '/obj/item/clothing/under/syndicate/gec': '/obj/item/clothing/under/syndicate',
    '/obj/item/clothing/under/syndicate/hardliners': '/obj/item/clothing/under/syndicate/combat',
    '/obj/item/clothing/under/syndicate/hardliners/jumpsuit': '/obj/item/clothing/under/syndicate',
    '/obj/item/clothing/under/syndicate/ramzi': '/obj/item/clothing/under/syndicate',
    '/obj/item/clothing/under/syndicate/ramzi/officer': '/obj/item/clothing/under/syndicate/combat',
    '/obj/item/clothing/under/warra/captain/skirt': '/obj/item/clothing/under/rank/captain/skirt',
    '/obj/item/storage/backpack/satchel/sec/clip': '/obj/item/storage/backpack/satchel/sec',
    '/obj/item/storage/belt/security/webbing/hardliners': '/obj/item/storage/belt/military',
    '/obj/item/storage/belt/security/webbing/hardliners/alt': '/obj/item/storage/belt/military',
    '/obj/item/storage/belt/security/webbing/ramzi/alt': '/obj/item/storage/belt/military',
}.items():
    rep(p, n)
DECISIONS['ubrania frakcji'] = 'stroje Ramziego, Twardogłowych, CLIP, Frontiersmen, Warra -> nasze stroje Syndykatu, ochrony, naukowca, kwatermistrza'

# --- jedzenie, napoje, chemia
for p, n in {
    '/obj/item/food/homemade_jerky': '/obj/item/food/sosjerky',
    '/obj/item/food/ration': '/obj/item/food/donkpocket',
    '/obj/item/food/soup/mushroom': '/obj/item/food/soup/wish',
    '/obj/item/reagent_containers/condiment/bbqsauce': '/obj/item/reagent_containers/food/condiment/bbqsauce',
    '/obj/item/reagent_containers/condiment/flour': '/obj/item/reagent_containers/food/condiment/flour',
    '/obj/item/reagent_containers/condiment/milk': '/obj/item/reagent_containers/food/condiment/milk',
    '/obj/item/reagent_containers/condiment/peppermill': '/obj/item/reagent_containers/food/condiment/peppermill',
    '/obj/item/reagent_containers/condiment/rice': '/obj/item/reagent_containers/food/condiment/rice',
    '/obj/item/reagent_containers/condiment/saltshaker': '/obj/item/reagent_containers/food/condiment/saltshaker',
    '/obj/item/reagent_containers/condiment/soymilk': '/obj/item/reagent_containers/food/condiment/soymilk',
    '/obj/item/reagent_containers/food/drinks/colocup': '/obj/item/reagent_containers/food/drinks/sillycup',
    '/obj/item/reagent_containers/food/drinks/drinkingglass/filled/bridge_bunny': '/obj/item/reagent_containers/food/drinks/drinkingglass',
    '/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/commemorative': '/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass',
    '/obj/item/reagent_containers/food/drinks/mead': '/obj/item/reagent_containers/food/drinks/bottle/ale',
    '/obj/item/reagent_containers/food/drinks/molotov/full': '/obj/item/reagent_containers/food/drinks/bottle/molotov',
    '/obj/item/reagent_containers/food/drinks/waterbottle/empty': '/obj/item/reagent_containers/glass/waterbottle/empty',
    '/obj/item/reagent_containers/food/drinks/waterbottle/large': '/obj/item/reagent_containers/glass/waterbottle/large',
    '/obj/item/reagent_containers/glass/bottle/nitroglycerin': '/obj/item/reagent_containers/glass/bottle/nitroglycerin',
    '/obj/item/reagent_containers/hypospray/medipen/stimpack/crisis': '/obj/item/reagent_containers/hypospray/medipen',
    '/obj/item/reagent_containers/syringe/contraband': '/obj/item/reagent_containers/syringe',
    '/obj/item/reagent_containers/syringe/stasis': '/obj/item/reagent_containers/syringe',
    '/obj/item/storage/cans/sixbeer': '/obj/item/reagent_containers/food/drinks/beer',
    '/obj/item/stack/medical/bruise_pack': '/obj/item/stack/medical/suture',
    '/obj/item/stack/medical/bruise_pack/herb': '/obj/item/stack/medical/suture',
    '/obj/item/stack/medical/gauze/improvised': '/obj/item/stack/medical/bandage',
    '/obj/item/stack/medical/ointment': '/obj/item/stack/medical/mesh',
    '/obj/item/storage/fancy/cigarettes/derringer/gold': '/obj/item/storage/fancy/cigarettes',
    '/obj/item/storage/bag/tray/cafeteria': '/obj/item/storage/bag/tray',
}.items():
    rep(p, n)
DECISIONS['/obj/item/reagent_containers/glass/bottle/nitroglycerin'] = 'PORT: butelka nitrogliceryny (30 j. naszej nitrogliceryny)'

# --- złom (salvage) -> nasza ruda
for metal, ore in {'scrapmetal': 'iron', 'scrapgold': 'gold', 'scrapsilver': 'silver', 'scrapplasma': 'plasma',
                   'scraptitanium': 'titanium', 'scrapuranium': 'uranium', 'scrapbluespace': 'bluespace_crystal'}.items():
    rep(f'/obj/item/stack/ore/salvage/{metal}', f'/obj/item/stack/ore/{ore}')
    rep(f'/obj/item/stack/ore/salvage/{metal}/five', (f'/obj/item/stack/ore/{ore}', {'amount': '5'}))
    rep(f'/obj/item/stack/ore/salvage/{metal}/ten', (f'/obj/item/stack/ore/{ore}', {'amount': '10'}))
DECISIONS['/obj/item/stack/ore/salvage/*'] = 'złom Shiptesta -> nasza ruda tego metalu (ilość zachowana)'

# --- pozostałe przedmioty
for p, n in {
    '/obj/item/attachment/ammo_counter': None,
    '/obj/item/blackmarket_uplink': None,
    '/obj/item/brass_knuckles': None,
    '/obj/item/broken_missile': None,
    '/obj/item/chisel': None,
    '/obj/item/cutting_board': None,
    '/obj/item/desk_flag/trans': None,
    '/obj/item/folder/documents/syndicate/blue': '/obj/item/folder/blue',
    '/obj/item/folder/documents/syndicate/cybersun': '/obj/item/folder/blue',
    '/obj/item/folder/documents/syndicate/red': '/obj/item/folder/red',
    '/obj/item/gem/phoron': '/obj/item/stack/ore/plasma',
    '/obj/item/gun_maint_kit': None,
    '/obj/item/mob_trophy/goliath_crystal': None,
    '/obj/item/modular_computer/laptop/preset/civilian/rilena': '/obj/item/modular_computer/laptop/preset/civillian',
    '/obj/item/paper/fluff/ruins/holdout/besieged': '/obj/item/paper/fluff/ruins/planet_lava/holdout/besieged',
    '/obj/item/paper/fluff/ruins/holdout/goodbye': '/obj/item/paper/fluff/ruins/planet_lava/holdout/goodbye',
    '/obj/item/paper/fluff/ruins/holdout/hurrah': '/obj/item/paper/fluff/ruins/planet_lava/holdout/hurrah',
    '/obj/item/photo/old': '/obj/item/photo',
    '/obj/item/rack_parts/shelf': '/obj/item/rack_parts',
    '/obj/item/radio/intercom/table': '/obj/item/radio/off',
    '/obj/item/radio/old': '/obj/item/radio/off',
    '/obj/item/ration_heater': None,
    '/obj/item/rcl/pre_loaded': '/obj/item/stack/cable_coil',
    '/obj/item/reagent_containers/glass/concrete_bag': None,
    '/obj/item/soap/warra': '/obj/item/soap/nanotrasen',
    '/obj/item/spacecash/bundle/c1000': '/obj/item/stack/spacecash/c1000',
    '/obj/item/spacecash/bundle/c500': '/obj/item/stack/spacecash/c500',
    '/obj/item/spacecash/bundle/loadsamoney': '/obj/item/stack/spacecash/c1000',
    '/obj/item/sparkler': None,
    '/obj/item/stack/arcadeticket': None,
    '/obj/item/stack/circuit_stack': None,
    '/obj/item/stack/sheet/glass/twenty': ('/obj/item/stack/sheet/glass', {'amount': '20'}),
    '/obj/item/stack/sheet/metal': '/obj/item/stack/sheet/iron',
    '/obj/item/stack/sheet/metal/fifty': '/obj/item/stack/sheet/iron/fifty',
    '/obj/item/stack/sheet/metal/twenty': '/obj/item/stack/sheet/iron/twenty',
    '/obj/item/stamp/cybersun': '/obj/item/stamp',
    '/obj/item/stamp/hardliners': '/obj/item/stamp',
    '/obj/item/stamp/warra/captain': '/obj/item/stamp',
    '/obj/item/stamp/warra/ns/supply': '/obj/item/stamp/quartermaster',
    '/obj/item/stamp/warra/vigilitas': '/obj/item/stamp',
    '/obj/item/storage/box/flares': '/obj/item/flashlight/flare',
    '/obj/item/storage/box/shipping': '/obj/item/storage/box',
    '/obj/item/table_bell': None,
    '/obj/item/towel': None,
    '/obj/item/toy/cards/deck/tarot': '/obj/item/toy/cards/deck',
    '/obj/item/toy/figure/head_of_personnel': '/obj/item/toy/figure/hop',
    '/obj/item/toy/figure/tali': None,
    '/obj/item/toy/plush/among': None,
    '/obj/item/toy/plush/kari': '/obj/item/toy/plush/lizardplushie',
    '/obj/item/toy/plush/sharai': '/obj/item/toy/plush/lizardplushie',
    '/obj/item/trash/can/food': '/obj/item/trash/canned',
    '/obj/item/trash/can/food/beans': '/obj/item/trash/canned/beans',
    '/obj/item/trash/can/food/beefbroth': '/obj/item/trash/canned/beefbroth',
    '/obj/item/trash/channelercandy': '/obj/item/trash/candy',
    '/obj/item/trash/dote': '/obj/item/trash/chips',
    '/obj/item/trash/gummycarps': '/obj/item/trash/candy',
    '/obj/item/trash/lifosa': '/obj/item/trash/syndi_cakes',
    '/obj/item/trash/mirastin': '/obj/item/trash/energybar',
    '/obj/item/trench_tool': '/obj/item/shovel',
    '/obj/item/stack/cable_coil/cut/random': '/obj/item/stack/cable_coil/cut',
}.items():
    rep(p, n)
for c in ['blue', 'green', 'orange', 'pink', 'red', 'white', 'yellow']:
    rep(f'/obj/item/stack/cable_coil/cut/{c}', '/obj/item/stack/cable_coil/cut')
DECISIONS['pominięte przedmioty'] = 'licznik amunicji, uplink czarnego rynku, kastet, rakieta, dłuto, deska do krojenia, flaga, zestaw konserwacji broni, trofeum, podgrzewacz racji, worki betonu, zimne ognie, bilety, płytki, dzwonek, ręczniki, figurka Tali, pluszak among'

# --- maszyny
for p, n in {
    '/obj/machinery/autolathe': '/obj/machinery/modular_fabricator/autolathe',
    '/obj/machinery/button/shieldwallgen': None,
    '/obj/machinery/power/shieldwallgen/atmos/roundstart': None,
    '/obj/machinery/computer/helm': ('/obj/structure/frame/computer', {'anchored': '1'}),
    '/obj/machinery/door/airlock/outpost': '/obj/machinery/door/airlock',
    '/obj/machinery/door/poddoor/crusher': '/obj/machinery/door/poddoor',
    '/obj/machinery/fax/ruin': None,
    '/obj/machinery/jukebox/boombox': None,
    '/obj/machinery/light/floor/hangar': '/obj/machinery/light/floor',
    '/obj/machinery/porta_turret/ruin/ramzi/light': '/obj/machinery/porta_turret/syndicate',
    '/obj/machinery/porta_turret/ship/hardliners': '/obj/machinery/porta_turret/syndicate',
    '/obj/machinery/porta_turret/ship/hardliners/heavy': '/obj/machinery/porta_turret/syndicate/energy/heavy',
    '/obj/machinery/porta_turret/ship/hardliners/light': '/obj/machinery/porta_turret/syndicate',
    '/obj/machinery/turretid/ship': None,
    '/obj/machinery/power/emitter/welded': '/obj/machinery/power/emitter/anchored',
    '/obj/machinery/power/port_gen/pacman/super/not_very': '/obj/machinery/power/port_gen/pacman/super',
    '/obj/machinery/power/rtg/geothermal': '/obj/machinery/power/rtg',
    '/obj/machinery/power/shuttle/engine/electric': '/obj/structure/shuttle/engine/propulsion',
    '/obj/machinery/power/shuttle/engine/fueled/plasma': '/obj/structure/shuttle/engine/propulsion',
    '/obj/machinery/power/smes/shuttle/precharged': '/obj/machinery/power/smes',
    '/obj/machinery/vending/cola/holdout': '/obj/machinery/vending/cola/planet_lava_holdout',
    '/obj/machinery/vending/snack/holdout': '/obj/machinery/vending/snack/planet_lava_holdout',
}.items():
    rep(p, n)
DECISIONS['wieżyczki Twardogłowych'] = 'wieżyczki statkowe -> wieżyczki Syndykatu (ta sama frakcja co Ramzi, oblężenie nie walczy samo ze sobą)'
DECISIONS['/obj/machinery/power/shieldwallgen/atmos'] = 'pominięte: atmosferyczna ściana tarcz z przyciskiem (brak u nas)'
DECISIONS['/obj/machinery/fax/ruin'] = 'pominięty: faks (nasz faks łączy się ze stacją)'
DECISIONS['/obj/machinery/vending/*/holdout'] = 'PORT: puste automaty bastionu (zagłodzeni obrońcy)'

# --- struktury
for p, n in {
    '/obj/structure/catwalk/over': '/obj/structure/lattice/catwalk/over',
    '/obj/structure/catwalk/over/plated_catwalk': '/obj/structure/lattice/catwalk/over/ship',
    '/obj/structure/catwalk/over/plated_catwalk/dark': '/obj/structure/lattice/catwalk/over/ship/dark',
    '/obj/structure/catwalk/over/plated_catwalk/white': '/obj/structure/lattice/catwalk/over/ship/light',
    '/obj/structure/chair/bench/beige': '/obj/structure/chair/fancy/bench',
    '/obj/structure/chair/comfy/beige': '/obj/structure/chair/fancy/comfy',
    '/obj/structure/chair/comfy/blue': '/obj/structure/chair/fancy/comfy',
    '/obj/structure/chair/comfy/shuttle': '/obj/structure/chair/fancy/shuttle',
    '/obj/structure/chair/handrail': None,
    '/obj/structure/chair/office/dark': '/obj/structure/chair/office',
    '/obj/structure/chair/office/purple': '/obj/structure/chair/office',
    '/obj/structure/chair/plastic': '/obj/structure/chair/fancy/plastic',
    '/obj/structure/chair/sofa/brown/corpo/left': '/obj/structure/chair/fancy/sofa/corp/left',
    '/obj/structure/chair/sofa/brown/corpo/right': '/obj/structure/chair/fancy/sofa/corp/right',
    '/obj/structure/chair/sofa/red/corpo/left': '/obj/structure/chair/fancy/sofa/corp/left',
    '/obj/structure/chair/sofa/red/corpo/right': '/obj/structure/chair/fancy/sofa/corp/right',
    '/obj/structure/closet/crate/grave/loot': '/obj/structure/closet/crate/secure/loot',
    '/obj/structure/closet/crate/secure/exo': '/obj/structure/closet/crate/secure',
    '/obj/structure/closet/secure_closet/armorycage': ('/obj/structure/closet/secure_closet', {'icon_state': '"armory"'}),
    '/obj/structure/crate_shelf': None,
    '/obj/structure/curtain/cloth': '/obj/structure/curtain',
    '/obj/structure/curtain/cloth/grey': '/obj/structure/curtain',
    '/obj/structure/displaycase/noalert': ('/obj/structure/displaycase', {'alert': '0'}),
    '/obj/structure/fermenting_barrel/gunpowder': '/obj/structure/fermenting_barrel',
    '/obj/structure/filingcabinet/double': '/obj/structure/filingcabinet',
    '/obj/structure/filingcabinet/double/grey': '/obj/structure/filingcabinet',
    '/obj/structure/flora/rock/beach': '/obj/structure/flora/rock',
    '/obj/structure/flora/rock/crystal': '/obj/structure/flora/rock/pile/lava',
    '/obj/structure/flora/tree/dead_pine': '/obj/structure/flora/tree/dead',
    '/obj/structure/flora/tree/tall/whitesands': '/obj/structure/flora/tree/dead/tall/grey',
    '/obj/structure/guncloset': '/obj/structure/guncase',
    '/obj/structure/hazard/electrical/electrified_water': None,
    '/obj/structure/hazard_shutoff/electrical_shutoff': None,
    '/obj/structure/plaque/listeningpost': ('/obj/structure/sign/plaques', {'name': '"pamiątkowa tablica posterunku nasłuchowego"', 'desc': '"Cybersun Virtual Solutions – polowy posterunek nasłuchowy nr 213. Zbudowany z dumą w 491 r."'}),
    '/obj/structure/platform/industrial': None,
    '/obj/structure/platform/industrial/corner': None,
    '/obj/structure/poddoor_assembly/shutters': None,
    '/obj/structure/railing/wood': '/obj/structure/railing',
    '/obj/structure/salvageable/computer': ('/obj/structure/frame/computer', {'anchored': '1'}),
    '/obj/structure/salvageable/machine': ('/obj/structure/frame/machine', {'anchored': '1'}),
    '/obj/structure/salvageable/protolathe': ('/obj/structure/frame/machine', {'anchored': '1'}),
    '/obj/structure/sign/poster/clip/bard': '/obj/structure/sign/poster/official/random',
    '/obj/structure/sign/poster/clip/enlist': '/obj/structure/sign/poster/official/enlist',
    '/obj/structure/sign/poster/clip/lanchester': '/obj/structure/sign/poster/official/random',
    '/obj/structure/sign/poster/clip/maxin': '/obj/structure/sign/poster/official/random',
    '/obj/structure/sign/poster/contraband/backdoor_xeno_babes_6': '/obj/structure/sign/poster/contraband/busty_backdoor_xeno_babes_6',
    '/obj/structure/sign/poster/contraband/bulldog': '/obj/structure/sign/poster/contraband/c20r',
    '/obj/structure/sign/poster/contraband/cybersun': '/obj/structure/sign/poster/contraband/syndicate_recruitment',
    '/obj/structure/sign/poster/contraband/gec': '/obj/structure/sign/poster/contraband/random',
    '/obj/structure/sign/poster/official/moth/hardhats': '/obj/structure/sign/poster/official/build',
    '/obj/structure/sign/poster/official/warra_logo': '/obj/structure/sign/poster/official/random',
    '/obj/structure/sign/syndicate': '/obj/structure/sign/poster/contraband/syndicate_recruitment',
    '/obj/structure/sign/warning/gasmask': '/obj/structure/sign/poster/official/safety_internals',
    '/obj/structure/sign/warning/incident': None,
    '/obj/structure/sink/chem': '/obj/structure/sink',
    '/obj/structure/table/chem': '/obj/structure/table/reinforced',
    '/obj/structure/table/emptycomputer': '/obj/structure/table',
    '/obj/structure/table/wood/reinforced': '/obj/structure/table/wood',
    '/obj/structure/window/plasma/reinforced/plastitanium': '/obj/structure/window/plastitanium',
    '/obj/structure/window/reinforced/fulltile/shuttle': '/obj/structure/window/shuttle',
    '/obj/structure/barricade/directional/flippedtable': '/obj/structure/barricade/wooden/crude',
}.items():
    rep(p, n)
DECISIONS['/obj/structure/platform/industrial'] = 'pominięte: krawędzie platform (czysto wizualne, brak u nas)'
DECISIONS['/obj/structure/hazard/electrical/electrified_water'] = 'pominięte: zelektryzowana woda i jej wyłącznik (system zagrożeń Shiptesta)'
DECISIONS['/obj/structure/crate_shelf'] = 'pominięte: regał na skrzynie (skrzynie stoją na podłodze)'
DECISIONS['/obj/structure/salvageable/*'] = 'wraki maszyn -> puste ramy komputera/maszyny'

# istniejące u nas typy, których nie chcemy w ruinie planety
rep('/obj/machinery/blackbox_recorder', ('/obj/structure/frame/machine', {'anchored': '1'}), 'rejestrator czarnej skrzynki -> pusta rama (czarna skrzynka to cel kradzieży zdrajcy)')
rep('/obj/machinery/cryopod', '/obj/structure/bed', 'kriokapsuła -> łóżko (bez konsoli kriogeniki kapsuła wysyła adminom ostrzeżenia)')

# zamykane szafki z populate = FALSE -> ten sam wygląd bez wypełnienia
NO_POPULATE = {
    '/obj/structure/closet/secure_closet/security': ('/obj/structure/closet/secure_closet', '"sec"'),
    '/obj/structure/closet/secure_closet/armory1': ('/obj/structure/closet/secure_closet', '"armory"'),
    '/obj/structure/closet/secure_closet/quartermaster': ('/obj/structure/closet/secure_closet', '"qm"'),
    '/obj/structure/closet/syndicate/personal': ('/obj/structure/closet/syndicate', None),
}

# --- ścienne szafki (Shiptest wiesza je na ścianie): u nas zwykła szafka na tym samym polu
WALL_CLOSETS = {
    '/obj/structure/closet/emcloset/wall': '/obj/structure/closet/emcloset/anchored',
    '/obj/structure/closet/firecloset/wall': '/obj/structure/closet/firecloset',
    '/obj/structure/closet/secure_closet/freezer/kitchen/wall': '/obj/structure/closet/secure_closet/freezer/kitchen',
    '/obj/structure/closet/secure_closet/wall': '/obj/structure/closet/secure_closet',
    '/obj/structure/closet/wall': '/obj/structure/closet',
    '/obj/structure/closet/wall/red': '/obj/structure/closet',
    '/obj/structure/closet/wall/white': '/obj/structure/closet',
    '/obj/structure/closet/wall/white/med': '/obj/structure/closet/secure_closet/medical1',
}

# --- turfy
LAVA_FLOOR = {'initial_gas_mix': LAVA_GAS}
LAVA_PLANETARY = {'initial_gas_mix': LAVA_GAS, 'planetary_atmos': '1'}
TURFS = {
    '/turf/closed/indestructible/reinforced': '/turf/closed/indestructible/riveted',
    '/turf/closed/indestructible/titanium': '/turf/closed/indestructible/riveted',
    '/turf/closed/wall/concrete': '/turf/closed/wall',
    '/turf/closed/wall/concrete/reinforced': '/turf/closed/wall/r_wall',
    '/turf/open/floor/carpet/nanoweave': '/turf/open/floor/carpet/black',
    '/turf/open/floor/carpet/nanoweave/blue': '/turf/open/floor/carpet/royalblue',
    '/turf/open/floor/carpet/nanoweave/red': '/turf/open/floor/carpet/red',
    '/turf/open/floor/concrete/lava': '/turf/open/floor/concrete/lava',
    '/turf/open/floor/concrete/pavement/lava': '/turf/open/floor/concrete/pavement/lava',
    '/turf/open/floor/concrete/slab_1/lava': '/turf/open/floor/concrete/slab_1/lava',
    '/turf/open/floor/concrete/slab_4': '/turf/open/floor/concrete/slab_4',
    '/turf/open/floor/engine/hull': '/turf/open/floor/engine',
    '/turf/open/floor/engine/hull/interior': '/turf/open/floor/engine',
    '/turf/open/floor/engine/hull/interior/lavaland': ('/turf/open/floor/engine', LAVA_PLANETARY),
    '/turf/open/floor/engine/hull/reinforced/lavaland': ('/turf/open/floor/engine', LAVA_PLANETARY),
    '/turf/open/floor/hangar/plasteel/white': '/turf/open/floor/plasteel/white',
    '/turf/open/floor/plasteel/dark/lava': ('/turf/open/floor/plasteel/dark', LAVA_FLOOR),
    '/turf/open/floor/plasteel/mono': '/turf/open/floor/monotile/steel',
    '/turf/open/floor/plasteel/mono/dark': '/turf/open/floor/monotile/dark',
    '/turf/open/floor/plasteel/mono/white': '/turf/open/floor/monotile/light',
    '/turf/open/floor/plasteel/mono/white/lavaland': ('/turf/open/floor/monotile/light', LAVA_PLANETARY),
    '/turf/open/floor/plasteel/patterned': '/turf/open/floor/plasteel',
    '/turf/open/floor/plasteel/patterned/brushed': '/turf/open/floor/monotile/steel',
    '/turf/open/floor/plasteel/patterned/cargo_one': '/turf/open/floor/plasteel',
    '/turf/open/floor/plasteel/patterned/grid/dark': '/turf/open/floor/plasteel/tech/grid',
    '/turf/open/floor/plasteel/patterned/grid/dark/lavaland': ('/turf/open/floor/plasteel/tech/grid', LAVA_PLANETARY),
    '/turf/open/floor/plasteel/patterned/ridged': '/turf/open/floor/plasteel',
    '/turf/open/floor/plasteel/stairs/wood': '/turf/open/floor/plasteel/stairs',
    '/turf/open/floor/plasteel/tech/grid/lavaland': ('/turf/open/floor/plasteel/tech/grid', LAVA_PLANETARY),
    '/turf/open/floor/plasteel/tech/techmaint': '/turf/open/floor/plasteel/techmaint',
    '/turf/open/floor/plasteel/white/lava': ('/turf/open/floor/plasteel/white', LAVA_FLOOR),
    '/turf/open/floor/plating/asteroid/basalt/lava_land_surface/lit': '/turf/open/floor/plating/asteroid/basalt/lava_land_surface',
    '/turf/open/floor/plating/asteroid/purple/lit': '/turf/open/floor/plating/asteroid/purple',
    '/turf/open/floor/plating/catwalk_floor': '/turf/open/floor/plating',
    '/turf/open/floor/plating/lava': '/turf/open/floor/plating/lavaland',
    '/turf/open/floor/plating/rust/lava': ('/turf/open/floor/plating/rust', LAVA_FLOOR),
    '/turf/open/floor/suns/hatch': '/turf/open/floor/pod/dark',
    '/turf/open/floor/wood/walnut': '/turf/open/floor/wood',
    '/turf/open/water/beach/underground': '/turf/open/water/air',
}
DECISIONS['/turf/closed/wall/concrete'] = 'ściany betonowe -> nasze ściany stalowe/wzmocnione (beton Shiptesta ma smoothing bitmaskowy, u nas stary)'
DECISIONS['/turf/open/floor/concrete/*'] = 'PORT: posadzki betonowe (gładki beton, nawierzchnia, płyty) z odmianami */lava'
DECISIONS['*/lava, */lavaland (podłogi)'] = 'podłogi z atmosferą planety -> nasz typ z initial_gas_mix Lavalandu (jak nasze ruiny Lavalandu)'
DECISIONS['/turf/open/water/beach/underground'] = 'woda w zalanej łaźni -> /turf/open/water/air'

AREAS = {
    '/area/overmap_encounter/planetoid/lava/explored': '/area/lavaland/surface/outdoors',
    '/area/overmap_encounter/planetoid/cave/explored': '/area/ruin/unpowered/planet_lava/cave',
    '/area/ruin/unpowered/listening_post': '/area/ruin/unpowered/planet_lava/listening_post',
    '/area/ruin/unpowered/listening_post/canteen': '/area/ruin/unpowered/planet_lava/listening_post/canteen',
    '/area/ruin/unpowered/listening_post/commons': '/area/ruin/unpowered/planet_lava/listening_post/commons',
    '/area/ruin/unpowered/listening_post/engineering': '/area/ruin/unpowered/planet_lava/listening_post/engineering',
    '/area/ruin/unpowered/listening_post/operations': '/area/ruin/unpowered/planet_lava/listening_post/operations',
    '/area/ruin/unpowered/crashed_starwalker': '/area/ruin/unpowered/planet_lava/crashed_starwalker',
}
for sub in ['', '/dogs', '/dorms', '/dorms/two', '/engineering', '/gear', '/living_quarters', '/medbay', '/security']:
    AREAS['/area/ruin/unpowered/dynamitehole' + sub] = '/area/ruin/unpowered/planet_lava/dynamite_hole' + sub
for sub in ['adminstrative', 'dorms', 'lobby', 'manager_office', 'warehouse']:
    AREAS['/area/ruin/lavaland/factory/' + sub] = '/area/ruin/powered/planet_lava/factory/' + ('administrative' if sub == 'adminstrative' else sub)
for sub in ['armory', 'barracks', 'engineering', 'kitchen', 'mainhall', 'mess', 'office', 'ramziflea', 'ramzihq', 'tcomms', 'warehousea', 'warehouseb']:
    AREAS['/area/ruin/lavaland/holdout/' + sub] = '/area/ruin/unpowered/planet_lava/holdout/' + sub

# typy portowane (do statystyk)
PORTED = {'/mob/living/basic/mining/ramzi_hound', '/obj/item/reagent_containers/glass/bottle/nitroglycerin',
          '/obj/item/paper/fluff/ruins/planet_lava/holdout/besieged', '/obj/item/paper/fluff/ruins/planet_lava/holdout/goodbye',
          '/obj/item/paper/fluff/ruins/planet_lava/holdout/hurrah', '/obj/machinery/vending/cola/planet_lava_holdout',
          '/obj/machinery/vending/snack/planet_lava_holdout', '/turf/open/floor/concrete/lava', '/turf/open/floor/concrete/pavement/lava',
          '/turf/open/floor/concrete/slab_1/lava', '/turf/open/floor/concrete/slab_4'}


ICON_STATE_DROP = {'/obj/structure/spider/stickyweb', '/obj/effect/decal/fakelattice', '/obj/effect/decal/cleanable/blood', '/obj/machinery/computer/crew',
                   '/obj/machinery/modular_computer/console/preset/civilian', '/obj/machinery/computer/telecomms/monitor',
                   '/obj/machinery/modular_computer/console/preset/command', '/obj/item/toy/cards/singlecard'}

SUIT_PREFIX = ('/obj/item/clothing/suit/space', '/obj/item/clothing/suit/armor')
HELM_PREFIX = ('/obj/item/clothing/head/helmet',)
MASK_PREFIX = ('/obj/item/clothing/mask',)


# SSU inherit: konwersja ścieżki robi convert_tile, pojedynczy atom pomijamy
for p in ['/obj/machinery/suit_storage_unit/inherit', '/obj/machinery/suit_storage_unit/inherit/industrial']:
    R[p] = None

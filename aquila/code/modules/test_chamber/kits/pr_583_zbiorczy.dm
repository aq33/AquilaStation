// aq33/AquilaStation#583 - zbiorcze 7.11: czat i lobby jak w tg, hardsuity z modułami, examine, piksel ID, gangi z Dominatorem, dym z broni

/datum/test_chamber_kit/pr_583
	name = "Zbiorcze 7.11 (hardsuity, examine, ID, dym, gangi)"
	pr = "aq33/AquilaStation#583"
	description = "1) Hardsuity: załóż inżynieryjny hardsuit z modułami, otwórz akcję „Panel kombinezonu” (ładunek, moduły, butla), wybierz moduł akcją „Przełącz moduł”. Przycisk hełmu tylko rozkłada hełm. Włącz „Wbudowana butla”: oddychasz bez maski. \
	2) Zdejmij kombinezon: wkładaj luźne moduły ręką (limit złożoności), łomem wyjmij moduł albo rdzeń. Bez rdzenia moduły nie działają, alert ładunku znika przy pustym kombinezonie. Przyłóż butlę z tlenem, żeby dolać tlen. \
	3) Szafa na skafandry: włóż kombinezon z rozładowanym ogniwem, zamknij, po chwili ogniwo i butla są pełne. \
	4) Examine (shift-klik) na sobie i na kimś w kombinezonie: tytuł z portretem w zakładce ramki, ubranie, kreska „Stan” (uderz się), HUD-y pod osobną kreską z goglami ochrony. \
	5) Karta ID w slocie ID (zdejmij kurtkę): kolorowa karta na smyczy z przodu i z boku; PDA w slocie ID też widać. \
	6) Strzelaj z pistoletu w zamkniętym pomieszczeniu: po kilkunastu strzałach gęstnieje dym; z pianki nie dymi. \
	7) Ogłoszenia: komendą admina Create Command Report i zmianą poziomu alarmu sprawdź pasiaste ramki w kolorach. \
	8) Gangi: przez panel antagonisty zrób dwóch szefów gangów (Gang → Nowa), sprawdź okno gangu pod przyciskiem z kapeluszem (członkowie, limit, teren, Dominator), w gangtoolu kup Dominatora na zajętym terenie i włącz go."
	items = list(
		/obj/item/clothing/suit/space/hardsuit/engine/loaded = 1,
		/obj/item/clothing/suit/space/hardsuit/medical/loaded = 1,
		/obj/item/mod/module/thermal_regulator = 1,
		/obj/item/mod/module/flashlight = 1,
		/obj/item/mod/module/visor/meson = 1,
		/obj/item/mod/module/emp_shield = 1,
		/obj/item/crowbar = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/clothing/glasses/hud/security = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 2,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 1,
	)

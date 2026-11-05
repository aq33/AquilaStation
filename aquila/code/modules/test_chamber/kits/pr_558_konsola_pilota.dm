/datum/test_chamber_kit/pr_558_konsola
	name = "PR 558: panel konsoli myśliwca"
	pr = "aq33/AquilaStation#558"
	description = "Wejdź do myśliwca (klik, 2 s) → oczekiwane: na dole ekranu panel z napisami po polsku (WYBÓR BRONI, TRYB LOTU, STEROWANIE, STAN KADŁUBA, KATAPULTA) i komunikat o panelu w czacie. \
	1) Naciśnij Alt, potem C, potem spację (tryb skrótów) → oczekiwane: odpowiedni klawisz na panelu na chwilę się wciska, LOT/HAMULEC, MYSZ/KLAWISZE i PDC/TORPEDA zmieniają się zgodnie ze stanem. \
	2) Kliknij klawisze na panelu (ALT, C, spację) → oczekiwane: to samo co skróty, plus pikanie. Shift+klik na panel → opis w czacie. \
	3) Uderz myśliwiec (bez pilota albo gdy siedzisz, ktoś inny) → oczekiwane: stan kadłuba spada przez 75%/50% (UWAGA)/25% (ALARM) do WYSKOCZ. \
	4) Przeciągnij panel myszą → zostaje w nowym miejscu. Negatyw: upuść go daleko za krawędzią ekranu → oczekiwane: zatrzymuje się przy krawędzi, cały widoczny, da się go złapać z powrotem. Panel myśliwca jest mniejszy (3/4) niż sternika. Czasownik „Pokaż/ukryj panel konsoli” w zakładce Ship ukrywa i pokazuje panel. \
	5) Negatyw: przestaw oba przełączniki L i P (komora jest na pokładzie) → oczekiwane: odmowa „Jesteś na pokładzie statku…”, przełączniki same wracają po 5 s. \
	Poza komorą: wyleć myśliwcem w kosmos, przestaw L i P w ciągu 5 s → kapsuła ratunkowa z tobą, dźwięk katapultowania, myśliwiec zostaje pusty z hamulcem. \
	Za sterami statku (mostek) panel sternika, przy konsoli taktycznej panel strzelca (PDC/TORPEDA/RAILGUN); przy oddalonej kamerze panel ma być większy i czytelny. \
	Dźwięki: włącz APU (rozruch), baterię (przełącznik), start z katapulty pokładowej, Ctrl+klik na wrogi statek (namierzanie), drzwi turbowindy."
	items = list(
		/obj/structure/overmap/small_craft/combat/light = 1,
	)

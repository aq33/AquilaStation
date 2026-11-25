// AQUILA - stopnie marynarki (config/ranks/marynarka.txt). W linijce wypowiedzi stopień stoi we własnym <span>:
// klient wersji EN tłumaczy tylko całe węzły tekstu, a razem z imieniem („kmdr por. Jan Kowalski”) stopień zostawał po polsku.

/// Stopień z compose_rank() owinięty w <span> (pusty tekst, gdy stopni nie ma)
/proc/aq_rank_span(rank)
	if(!rank)
		return ""
	return "<span class='rank'>[rank]</span>"

/// Stopnie z config/ranks/marynarka.txt, od najwyższego (jak w pecking_order.txt). Słownik EN bierze teksty tylko z kodu,
/// więc stopnie z configu są wypisane tutaj; aquila_navy_ranks pilnuje, żeby lista zgadzała się z plikiem.
GLOBAL_LIST_INIT(aq_navy_ranks, list("kmdr", "kmdr por.", "kmdr ppor.", "kpt. mar.", "por. mar.", "ppor. mar.", "st. bosm.", "bosm.", "mat", "mar.", "cyw.", "VIP", "CPU"))

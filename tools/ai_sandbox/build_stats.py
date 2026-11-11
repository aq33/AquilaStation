"""Strona "Statystyki dla nerdów" z nagrań i profili piaskownicy AI.

    python tools/ai_sandbox/build_stats.py --dane data --wyjscie raport/bitwy/statystyki.html

Liczy wszystko z plików data/<seria>_<litera>.json (nagrania) i data/<seria>_<litera>_profil.json (profile
procedur, gdy bitwa szła z ai_sandbox_profile=1). Serie i ich opisy: SERIE w render_battle.py.
Strona jest samowystarczalna (bez zewnętrznych skryptów); po nowej serii wystarczy ją wygenerować od nowa.
"""

import argparse
import collections
import glob
import html
import json
import math
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compare_battles  # noqa: E402
import render_battle  # noqa: E402

# Kolejność na stronie: od najstarszej serii do najnowszej, z tym, co sprawdzała
KOLEJNOSC = [
    ("fin_odniesienie_", "odniesienie"), ("fin_zwykla_", "pełne AI, przed poprawkami ruchu"),
    ("R_bez_", "bez poprawek ruchu"), ("R_poprawki_", "poprawki ruchu"),
    ("S_bez_dyscypliny_", "bez przepustnicy"), ("S_wszystko_", "przepustnica i skradanie"),
    ("T_bez_objazdu_", "bez objazdu"), ("T_wszystko_", "objazd przeszkód"),
    ("U_bez_zapasow_", "pełny magazyn co 5 s"), ("U_zapasy_", "skończone zapasy"),
    ("V_bez_zwiadu_", "bez zwiadu"), ("V_zwiad_", "zwiad (pierwsza wersja)"),
    ("X_bez_doktryny_", "bez doktryny"), ("X_doktryna_", "działa jako ostateczność"),
    ("Z_bez_", "torpedy do 50 pól"), ("Z_daleko_", "daleki ostrzał"),
    ("F_legacy_", "legacy: zmiany AI wyłączone"), ("F_pelne_", "wszystkie zmiany AI"),
    ("G_pelne_", "wszystkie zmiany, po optymalizacji"), ("F_daleko_", "wszystkie zmiany, daleki start"),
]
STOI = 0.3


def pc(lista, q):
    lista = sorted(lista)
    return lista[min(int(len(lista) * q), len(lista) - 1)] if lista else float("nan")


def srednia(lista):
    lista = [x for x in lista if x is not None and not (isinstance(x, float) and math.isnan(x))]
    return sum(lista) / len(lista) if lista else None


def dodatkowe(sciezka):
    """Prędkość, pierwsze trafienie, zamarznięte okręty, uzbrojenie, zdarzenia i obciążenie z jednego nagrania"""
    d = json.load(open(sciezka, encoding="utf-8"))
    kl = [(f["t"], f["ships"]) for f in d["frames"] if f.get("full")]
    dt = kl[1][0] - kl[0][0] if len(kl) > 1 else 2
    predk = collections.defaultdict(list)
    ai = set()
    pierwsze = None
    for i in range(len(kl) - 1):
        poz = {s["id"]: s for s in kl[i][1]}
        for s in kl[i + 1][1]:
            st = poz.get(s["id"])
            if not st or st.get("main") or st.get("tiny"):
                continue
            if st.get("fleet") or st.get("goal"):
                ai.add(s["id"])
            predk[s["id"]].append(math.hypot(s["x"] - st["x"], s["y"] - st["y"]) / dt)
            if pierwsze is None and s.get("hull", 100) < 100:
                pierwsze = kl[i + 1][0]
    v = [x for k, l in predk.items() if k in ai for x in l]
    zam = sum(1 for k, l in predk.items() if k in ai and len(l) >= 10 and pc(l, .95) < 0.05)
    ev = collections.Counter()
    for e in d.get("events", []):
        t = e.get("text", "")
        if "strzela na tor radaru" in t:
            ev["tor_radaru"] += 1
        elif "strzela na namiar od" in t:
            ev["namiar"] += 1
        elif "strzela z daleka" in t:
            ev["daleko"] += 1
        if "dla okrętów rakietowych" in t:
            ev["namierzenia"] += 1
        if "zwiad wysunięty" in t:
            ev["zwiad_wysuniety"] += 1
    cpu = d.get("cpu") or []
    return {
        "v": pc(v, .5) if v else None, "pierwsze": pierwsze, "zam": zam,
        "mun": d.get("munitions") or {}, "dist": d.get("guided_dist") or {}, "ev": ev,
        "cpu": [x[1] for x in cpu], "cpu_t": cpu, "ai": [x[2] for x in cpu],
    }


def profil(sciezka):
    p = sciezka.replace(".json", "_profil.json")
    if not os.path.exists(p):
        return None
    dane = json.load(open(p, encoding="utf-8"))
    return {e["name"]: (float(e.get("self", 0)), float(e.get("total", 0)), int(e.get("calls", 0))) for e in dane if e.get("name")}


def nasze_procki():
    korzen = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "aquila", "code", "modules", "overmap")
    nazwy = set()
    for p in glob.glob(os.path.join(korzen, "*.dm")):
        for linia in open(p, encoding="utf-8"):
            m = re.match(r"^(/[a-z_/]*/proc/[a-z_0-9]+)", linia)
            if m:
                nazwy.add(m.group(1))
    return nazwy


def seria(dane, prefiks):
    pliki = sorted(p for p in glob.glob(os.path.join(dane, prefiks + "*.json"))
                   if re.fullmatch(re.escape(prefiks) + r"[a-z]\.json", os.path.basename(p)))
    if not pliki:
        return None
    m = [compare_battles.metryki(p) for p in pliki]
    m = [x for x in m if x]
    x = [dodatkowe(p) for p in pliki]
    mun = collections.defaultdict(lambda: collections.Counter())
    hist = collections.Counter()
    ev = collections.Counter()
    for b in x:
        for k, v in b["mun"].items():
            mun[k].update(v)
        for k, v in b["dist"].items():
            hist[int(k)] += v
        ev.update(b["ev"])
    n = len(pliki)
    prof = [profil(p) for p in pliki]
    prof = [p for p in prof if p]
    return {
        "n": n, "pliki": pliki,
        "stoi": srednia([b["stoi%"] for b in m]), "stoi_min": min(b["stoi%"] for b in m), "stoi_max": max(b["stoi%"] for b in m),
        "lot": srednia([b["lotniskowce stoja%"] for b in m]), "zab": srednia([b["zabicia"] for b in m]),
        "walka": srednia([b["walka%"] for b in m]), "imp": srednia([b["impulsy"] for b in m]),
        "v": srednia([b["v"] for b in x]), "pierwsze": srednia([b["pierwsze"] for b in x]),
        "zam": sum(b["zam"] for b in x), "zam_bitwy": sum(1 for b in x if b["zam"]),
        "mun": mun, "hist": hist, "ev": ev,
        "cpu": srednia([srednia(b["cpu"]) for b in x if b["cpu"]]), "cpu_max": max([max(b["cpu"]) for b in x if b["cpu"]], default=None),
        "ai": srednia([srednia(b["ai"]) for b in x if b["ai"]]), "cpu_t": [b["cpu_t"] for b in x if b["cpu_t"]],
        "prof": prof,
    }


def fmt(v, d=1, suf=""):
    if v is None or (isinstance(v, float) and math.isnan(v)):
        return "—"
    return ("%." + str(d) + "f") % v + suf


def liczba_pl(s):
    return s.replace(".", ",")


# ---------------------------------------------------------------- wykresy (SVG w HTML, kolory z tokenów CSS)

def wykres_slupki(wiersze, jednostka, opis):
    """Poziome słupki, jedna seria: wiersze = [(etykieta, wartość, podpowiedź)]"""
    wiersze = [w for w in wiersze if w[1] is not None]
    if not wiersze:
        return ""
    mx = max(w[1] for w in wiersze) or 1
    wys = 26
    lw = 250
    szer = 640
    h = wys * len(wiersze) + 10
    out = ['<svg class="ch" viewBox="0 0 %d %d" role="img" aria-label="%s">' % (szer, h, html.escape(opis))]
    for i, (et, val, tip) in enumerate(wiersze):
        y = i * wys + 4
        w = max(2, (szer - lw - 70) * val / mx)
        out.append('<text class="lab" x="%d" y="%d" text-anchor="end">%s</text>' % (lw - 8, y + 15, html.escape(et)))
        out.append('<g class="hit"><title>%s</title><rect x="%d" y="%d" width="%.1f" height="16" rx="4" class="s1"/>'
                   '<rect x="%d" y="%d" width="%d" height="%d" fill="transparent"/></g>' % (
                       html.escape(tip), lw, y + 2, w, lw, y, szer - lw, wys))
        out.append('<text class="val" x="%.1f" y="%d">%s</text>' % (lw + w + 6, y + 15, liczba_pl(fmt(val, 1)) + jednostka))
    out.append("</svg>")
    return "".join(out)


def wykres_grupy(kategorie, serie, opis, jednostka="%"):
    """Słupki pogrupowane, dwie serie: serie = [(nazwa, klasa, [wartości])]"""
    szer, h, lewo, dol = 640, 230, 40, 30
    mx = max(max(v for v in s[2]) for s in serie) or 1
    mx = math.ceil(mx / 10.0) * 10
    gw = (szer - lewo - 10) / len(kategorie)
    bw = min(16, (gw - 8) / len(serie))
    out = ['<svg class="ch" viewBox="0 0 %d %d" role="img" aria-label="%s">' % (szer, h, html.escape(opis))]
    for k in range(0, int(mx) + 1, max(10, int(mx / 4) // 10 * 10)):
        y = h - dol - (h - dol - 10) * k / mx
        out.append('<line class="grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/><text class="ax" x="%d" y="%.1f" text-anchor="end">%d%s</text>' % (
            lewo, szer - 5, y, y, lewo - 6, y + 4, k, jednostka))
    for i, kat in enumerate(kategorie):
        x0 = lewo + i * gw + (gw - bw * len(serie) - 2 * (len(serie) - 1)) / 2
        for j, (nazwa, klasa, wart) in enumerate(serie):
            v = wart[i]
            bh = (h - dol - 10) * v / mx
            x = x0 + j * (bw + 2)
            out.append('<g class="hit"><title>%s, %s: %s%s</title><rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="3" class="%s"/></g>' % (
                html.escape(nazwa), html.escape(kat), liczba_pl(fmt(v, 1)), jednostka, x, h - dol - bh, bw, max(bh, 0.5), klasa))
        out.append('<text class="ax" x="%.1f" y="%d" text-anchor="middle">%s</text>' % (lewo + i * gw + gw / 2, h - dol + 16, html.escape(kat)))
    out.append("</svg>")
    return "".join(out)


def wykres_linie(serie, opis):
    """world.cpu w czasie: serie = [(nazwa, klasa, [(sekunda, wartość)])]"""
    szer, h, lewo, dol = 640, 230, 44, 30
    tmax = max(p[0] for s in serie for p in s[2]) or 1
    mx = max(p[1] for s in serie for p in s[2]) or 1
    mx = math.ceil(mx / 10.0) * 10
    X = lambda t: lewo + (szer - lewo - 70) * t / tmax
    Y = lambda v: h - dol - (h - dol - 10) * v / mx
    out = ['<svg class="ch" viewBox="0 0 %d %d" role="img" aria-label="%s">' % (szer, h, html.escape(opis))]
    krok = next(k for k in (5, 10, 20, 25, 50, 100) if mx / k <= 5)
    for k in range(0, int(mx) + 1, krok):
        out.append('<line class="grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/><text class="ax" x="%d" y="%.1f" text-anchor="end">%d%%</text>' % (
            lewo, szer - 70, Y(k), Y(k), lewo - 6, Y(k) + 4, k))
    for m in range(0, int(tmax) + 1, 60):
        out.append('<text class="ax" x="%.1f" y="%d" text-anchor="middle">%d min</text>' % (X(m), h - dol + 16, m // 60))
    # podpisy na końcu linii, rozsunięte, żeby się nie nakładały
    konce = sorted(((Y(p[-1][1]) + 4, X(p[-1][0]) + 6, n) for n, _, p in serie))
    for i in range(1, len(konce)):
        if konce[i][0] - konce[i - 1][0] < 14:
            konce[i] = (konce[i - 1][0] + 14,) + konce[i][1:]
    for y, x, nazwa in konce:
        out.append('<text class="lab" x="%.1f" y="%.1f">%s</text>' % (x, y, html.escape(nazwa)))
    for nazwa, klasa, pkt in serie:
        d = " ".join(("M" if i == 0 else "L") + "%.1f,%.1f" % (X(t), Y(v)) for i, (t, v) in enumerate(pkt))
        out.append('<path d="%s" class="ln %s"/>' % (d, klasa))
        for t, v in pkt:
            out.append('<g class="hit"><title>%s, %d:%02d: %s%%</title><circle cx="%.1f" cy="%.1f" r="7" fill="transparent"/></g>' % (
                html.escape(nazwa), int(t) // 60, int(t) % 60, liczba_pl(fmt(v, 1)), X(t), Y(v)))
    out.append("</svg>")
    return "".join(out)


def cpu_w_czasie(s, kosz=30):
    if not s or not s["cpu_t"]:
        return []
    k = collections.defaultdict(list)
    for bitwa in s["cpu_t"]:
        for t, c, _ in bitwa:
            k[int(t // kosz) * kosz + kosz / 2].append(c)
    return sorted((t, srednia(v)) for t, v in k.items())


def opis_wariantu(nazwa):
    for prefiks, krotko in KOLEJNOSC:
        if nazwa.startswith(prefiks):
            return krotko
    return dict(render_battle.SERIE).get(nazwa.rsplit("_", 1)[0] + "_", "")


def lista_profili(dane, nasze):
    """Jeden wiersz na każdy plik profilu, najnowsze pierwsze"""
    wiersze = []
    for p in glob.glob(os.path.join(dane, "*_profil.json")):
        nagranie = p.replace("_profil.json", ".json")
        nazwa = os.path.basename(nagranie)[:-5]
        try:
            pr = profil(nagranie)
        except (ValueError, OSError):
            continue  # profil jeszcze się zapisuje
        if not pr:
            continue
        cpu = ai = szczyt = None
        if os.path.exists(nagranie):
            try:
                c = json.load(open(nagranie, encoding="utf-8")).get("cpu") or []
            except (ValueError, OSError):
                c = []
            if c:
                cpu = srednia([x[1] for x in c])
                szczyt = max(x[1] for x in c)
                ai = srednia([x[2] for x in c])
        tot = sum(v[0] for v in pr.values())
        ours = sum(v[0] for k, v in pr.items() if k in nasze)
        wiersze.append({
            "czas": os.path.getmtime(p), "nazwa": nazwa, "wariant": opis_wariantu(nazwa), "cpu": cpu, "szczyt": szczyt, "ai": ai,
            "tot": tot, "ours": ours, "sp": pr.get("/obj/structure/overmap/proc/slowprocess", (0, 0, 0))[1],
            "mt": pr.get("/obj/structure/overmap/proc/move_toward", (0, 0, 0))[1],
            "top": max(((k, v[0]) for k, v in pr.items() if k in nasze), key=lambda x: x[1], default=("", 0)),
        })
    return sorted(wiersze, key=lambda w: -w["czas"])


# ---------------------------------------------------------------- strona

def zbuduj(dane):
    serie = []
    for prefiks, krotko in KOLEJNOSC:
        s = seria(dane, prefiks)
        if s:
            opis = dict(render_battle.SERIE).get(prefiks, prefiks)
            serie.append((prefiks, krotko, opis, s))
    po = {p: s for p, _, _, s in serie}
    nasze = nasze_procki()
    profile = lista_profili(dane, nasze)

    def g(p, k):
        return po.get(p, {}).get(k)

    kafle = []
    if "fin_zwykla_" in po and "G_pelne_" in po:
        kafle.append(("stanie okrętów", "%s → %s" % (liczba_pl(fmt(g("fin_odniesienie_", "stoi"), 0, "%")), liczba_pl(fmt(g("G_pelne_", "stoi"), 0, "%"))),
                      "odniesienie → wszystkie zmiany"))
    if "F_legacy_" in po and "F_pelne_" in po:
        kafle.append(("obciążenie serwera", "+%s p.p." % liczba_pl(fmt(g("F_pelne_", "cpu") - g("F_legacy_", "cpu"), 1)),
                      "world.cpu: %s → %s" % (liczba_pl(fmt(g("F_legacy_", "cpu"), 1, "%")), liczba_pl(fmt(g("F_pelne_", "cpu"), 1, "%")))))
    if "F_pelne_" in po:
        kafle.append(("strzały na tor radaru", str(g("F_pelne_", "ev")["tor_radaru"]), "w %d bitwach (wcześniej 0)" % g("F_pelne_", "n")))
    if "G_pelne_" in po and po["G_pelne_"]["prof"] and "F_pelne_" in po and po["F_pelne_"]["prof"]:
        a = srednia([p.get("/obj/structure/overmap/proc/slowprocess", (0, 0, 0))[1] for p in po["F_pelne_"]["prof"]])
        b = srednia([p.get("/obj/structure/overmap/proc/slowprocess", (0, 0, 0))[1] for p in po["G_pelne_"]["prof"]])
        kafle.append(("tik AI po optymalizacji", "−%s%%" % liczba_pl(fmt(100 * (a - b) / a, 0)), "%s s → %s s na bitwę" % (liczba_pl(fmt(a, 1)), liczba_pl(fmt(b, 1)))))

    css = """
:root{--bg:#0b0e14;--panel:#121722;--panel2:#171d2a;--ink:#e8ebf2;--ink2:#c3c8d4;--muted:#8b93a7;--line:#232b3b;
  --s1:#3987e5;--s2:#d95926;--grid:#1d2433}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.55 "Segoe UI",system-ui,-apple-system,sans-serif}
.wrap{max-width:1100px;margin:0 auto;padding:0 16px}
header{border-bottom:1px solid var(--line);padding:14px 0}
nav{display:flex;gap:8px;margin-top:10px;flex-wrap:wrap}
nav a{color:var(--ink2);text-decoration:none;border:1px solid var(--line);border-radius:7px;padding:5px 12px;font-size:13px;background:var(--panel2)}
nav a.on{border-color:var(--s1);color:#cfe4ff}
h1{margin:0;font-size:20px}
.sub{color:var(--muted);font-size:13px}
h2{font-size:17px;margin:28px 0 6px}
p.note{color:var(--ink2);font-size:14px;margin:4px 0 12px;max-width:80ch}
.tiles{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px;margin-top:18px}
.tile{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:12px 14px}
.tile .k{color:var(--muted);font-size:12.5px;text-transform:uppercase;letter-spacing:.06em}
.tile .v{font-size:26px;font-weight:600;margin-top:2px;font-variant-numeric:tabular-nums}
.tile .d{color:var(--ink2);font-size:13px}
.card{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:14px;margin:10px 0}
.ch{width:100%;height:auto;display:block}
.ch .lab{fill:var(--ink2);font-size:12px}
.ch .val{fill:var(--ink);font-size:12px;font-variant-numeric:tabular-nums}
.ch .ax{fill:var(--muted);font-size:11px}
.ch .grid{stroke:var(--grid);stroke-width:1}
.ch .s1{fill:var(--s1)} .ch .s2{fill:var(--s2)}
.ch .ln{fill:none;stroke-width:2}.ch .ln.s1{stroke:var(--s1);fill:none}.ch .ln.s2{stroke:var(--s2);fill:none}
.ch .hit:hover rect{filter:brightness(1.25)}
.legend{display:flex;gap:16px;font-size:13px;color:var(--ink2);margin:4px 0 6px;flex-wrap:wrap}
.legend i{display:inline-block;width:12px;height:12px;border-radius:3px;margin-right:6px;vertical-align:-1px}
.tbl{overflow-x:auto;margin:8px 0}
table{border-collapse:collapse;width:100%;font-size:13px;font-variant-numeric:tabular-nums}
th,td{padding:5px 8px;border-bottom:1px solid var(--line);text-align:right;white-space:nowrap}
th:first-child,td:first-child{text-align:left}
th{color:var(--muted);font-weight:600;position:sticky;top:0;background:var(--panel)}
td.nm{white-space:normal;min-width:180px;text-align:left}
tr.on td{background:#14203a}
tr.swiezy td:first-child{box-shadow:inset 3px 0 0 var(--s1)}
td a{color:#cfe4ff}
details{margin:6px 0}
summary{cursor:pointer;color:var(--ink2);font-size:13.5px}
code{background:var(--panel2);border:1px solid var(--line);border-radius:4px;padding:0 4px;font-size:12.5px}
dl{display:grid;grid-template-columns:minmax(150px,220px) 1fr;gap:6px 14px;font-size:14px}
dt{color:var(--ink)}dd{margin:0;color:var(--ink2)}
@media(max-width:640px){dl{grid-template-columns:1fr}dd{margin-bottom:6px}}
footer{color:var(--muted);font-size:12.5px;padding:24px 0 40px}
"""
    o = []
    o.append("<!doctype html><html lang='pl'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>"
             "<title>Statystyki dla nerdów — piaskownica AI</title><style>%s</style></head><body>" % css)
    o.append("<header><div class='wrap'><h1>Statystyki dla nerdów</h1><div class='sub'>Piaskownica AI Aquili: %d serii, %d bitew po 8 minut. "
             "Wszystko liczone z nagrań i profili procedur. Zaktualizowano %s, %d profili.</div><nav><a href='./'>Bitwy</a><a class='on' href='statystyki.html'>Statystyki dla nerdów</a></nav></div></header>" % (
                 len(serie), sum(s["n"] for _, _, _, s in serie), time.strftime("%d.%m.%Y %H:%M"), len(profile)))
    o.append("<main class='wrap'>")
    o.append("<div class='tiles'>" + "".join("<div class='tile'><div class='k'>%s</div><div class='v'>%s</div><div class='d'>%s</div></div>" % (
        html.escape(k), html.escape(v), html.escape(d)) for k, v, d in kafle) + "</div>")

    # 0. lista profili, aktualizowana przy każdym nowym profilu
    if profile:
        najnowszy = profile[0]["czas"]
        o.append("<h2>Ostatnie profile</h2><p class='note'>Każda bitwa puszczona z profilerem (<code>ai_sandbox_profile=1</code>), najnowsze na górze. "
                 "Lista dopisuje się sama, gdy profiler zapisze nowe dane; strona odświeża się co minutę. Kreska z lewej: profile z ostatniej godziny przed najnowszym.</p>"
                 "<div class='card tbl'><table><thead><tr><th>bitwa</th><th>kiedy</th><th style='text-align:left'>wariant</th><th>world.cpu</th><th>szczyt</th><th>okrętów AI</th>"
                 "<th>czas procedur</th><th>aquila/ AI</th><th>tik AI</th><th>move_toward</th><th>najdroższa nasza procedura</th></tr></thead><tbody>")
        for w in profile[:60]:
            o.append("<tr%s><td><a href='pliki/bitwy/%s.html'>%s</a></td><td>%s</td><td class='nm'>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td><code>%s</code> %s</td></tr>" % (
                " class='swiezy'" if najnowszy - w["czas"] < 3600 else "", html.escape(w["nazwa"]), html.escape(w["nazwa"]),
                time.strftime("%d.%m %H:%M", time.localtime(w["czas"])), html.escape(w["wariant"]),
                liczba_pl(fmt(w["cpu"], 1, "%")), liczba_pl(fmt(w["szczyt"], 0, "%")), liczba_pl(fmt(w["ai"], 1)), liczba_pl(fmt(w["tot"], 1, " s")),
                liczba_pl(fmt(w["ours"], 2, " s")), liczba_pl(fmt(w["sp"], 1, " s")), liczba_pl(fmt(w["mt"], 1, " s")),
                html.escape(w["top"][0].split("/proc/")[-1]), liczba_pl(fmt(w["top"][1], 2, " s"))))
        o.append("</tbody></table></div>")
        if len(profile) > 60:
            o.append("<p class='note'>Pokazano 60 najnowszych z %d.</p>" % len(profile))

    # 1. stanie
    o.append("<h2>Ile okręty stoją</h2><p class='note'>Odsetek klatek, w których okręt AI (bez myśliwców i stacji) porusza się wolniej niż 0,3 pola/s. "
             "Średnia z bitew serii; po najechaniu na słupek: zakres między bitwami.</p><div class='card'>")
    o.append(wykres_slupki([("%s" % krotko, s["stoi"], "%s: %s%% (zakres %s–%s%%, %d bitew)" % (
        krotko, liczba_pl(fmt(s["stoi"], 1)), liczba_pl(fmt(s["stoi_min"], 0)), liczba_pl(fmt(s["stoi_max"], 0)), s["n"]))
        for _, krotko, _, s in serie], "%", "Stanie okrętów w każdej serii"))
    o.append("</div>")

    # 2. obciazenie w czasie
    if "F_legacy_" in po and "F_pelne_" in po:
        o.append("<h2>Obciążenie serwera w czasie bitwy</h2><p class='note'><code>world.cpu</code>: jaka część czasu ticka zużywa cała gra, średnio co 30 s "
                 "z 6 bitew każdego wariantu, puszczanych na przemian na tej samej maszynie. Legacy: te same bitwy z wyłączonymi wszystkimi zmianami AI z <code>aquila/</code>.</p>"
                 "<div class='card'><div class='legend'><span><i style='background:var(--s1)'></i>wszystkie zmiany AI</span><span><i style='background:var(--s2)'></i>legacy</span></div>")
        o.append(wykres_linie([("zmiany AI", "s1", cpu_w_czasie(po["F_pelne_"])), ("legacy", "s2", cpu_w_czasie(po["F_legacy_"]))], "world.cpu w czasie bitwy"))
        o.append("</div>")

    # 3. odleglosc strzalow kierowanych
    przed = po.get("D_blisko_") or seria(dane, "D_blisko_")
    po_f = po.get("F_pelne_")
    if przed and po_f:
        kat = [0, 10, 20, 30, 40, 50, 60, 70]
        def udz(s):
            tot = sum(s["hist"].values()) or 1
            return [100.0 * (s["hist"].get(k, 0) if k < 70 else sum(v for kk, v in s["hist"].items() if kk >= 70)) / tot for k in kat]
        o.append("<h2>Z jakiej odległości lecą torpedy i rakiety</h2><p class='note'>Udział strzałów kierowanych w przedziałach co 10 pól. "
                 "Przed: daleki ostrzał bez poprawki namierzania; po: wszystkie zmiany (zwiad wysunięty, tor radaru, namierzanie przez przeładowanie).</p>"
                 "<div class='card'><div class='legend'><span><i style='background:var(--s2)'></i>przed</span><span><i style='background:var(--s1)'></i>po</span></div>")
        o.append(wykres_grupy(["%d+" % k if k < 70 else "70+" for k in kat], [("przed", "s2", udz(przed)), ("po", "s1", udz(po_f))], "Odległość strzałów kierowanych"))
        o.append("</div>")

    # 4. tabela serii
    o.append("<h2>Wszystkie serie</h2><p class='note'>Wartości na bitwę (średnie). Pierwsze trafienie: kiedy po raz pierwszy spada kadłub któregokolwiek okrętu. "
             "Zamarznięte: okręty AI, które nie ruszyły się przez całą bitwę.</p><div class='card tbl'><table><thead><tr>"
             "<th>seria</th><th>bitew</th><th>stoi</th><th>lotniskowce stoją</th><th>zniszczone</th><th>walka</th><th>prędkość (mediana)</th>"
             "<th>pierwsze trafienie</th><th>zamarznięte</th><th>torpedy</th><th>rakiety</th><th>działa i PD</th><th>kierowane &gt;50 pól</th><th>impulsy radaru</th></tr></thead><tbody>")
    for prefiks, krotko, opis, s in serie:
        n = s["n"]
        tot = sum(s["hist"].values())
        daleko = 100.0 * sum(v for k, v in s["hist"].items() if k >= 50) / tot if tot else None
        o.append("<tr><td class='nm' title='%s'>%s</td><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>" % (
            html.escape(opis), html.escape(krotko), n, liczba_pl(fmt(s["stoi"], 1, "%")), liczba_pl(fmt(s["lot"], 1, "%")), liczba_pl(fmt(s["zab"], 1)),
            liczba_pl(fmt(s["walka"], 1, "%")), liczba_pl(fmt(s["v"], 2)), liczba_pl(fmt(s["pierwsze"], 0, " s")), "%d w %d bitwach" % (s["zam"], s["zam_bitwy"]),
            liczba_pl(fmt(s["mun"]["torpeda"]["fired"] / n, 0)) if s["mun"] else "—",
            liczba_pl(fmt(s["mun"]["rakieta"]["fired"] / n, 0)) if s["mun"] else "—",
            liczba_pl(fmt(s["mun"]["niekierowane"]["fired"] / n, 0)) if s["mun"] else "—",
            liczba_pl(fmt(daleko, 1, "%")), liczba_pl(fmt(s["imp"], 0))))
    o.append("</tbody></table></div>")

    # 5. uzbrojenie i lacze danych
    o.append("<h2>Uzbrojenie i łącze danych</h2><div class='card tbl'><table><thead><tr><th>seria</th><th>torpedy trafione</th><th>rakiety trafione</th>"
             "<th>działa trafione</th><th>śr. odległość torpedy</th><th>strzały na tor radaru</th><th>na namiar zwiadowcy</th><th>z własnych sensorów &gt;50 pól</th>"
             "<th>namierzenia</th><th>zwiad wysunięty</th></tr></thead><tbody>")
    for prefiks, krotko, opis, s in serie:
        if not s["mun"]:
            continue
        m = s["mun"]
        tr = lambda k: liczba_pl(fmt(100.0 * m[k]["hit"] / m[k]["fired"], 0, "%")) if m[k]["fired"] else "—"
        o.append("<tr><td class='nm'>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>" % (
            html.escape(krotko), tr("torpeda"), tr("rakieta"), tr("niekierowane"),
            liczba_pl(fmt(m["torpeda"]["dist"] / m["torpeda"]["fired"], 1, " pól")) if m["torpeda"]["fired"] else "—",
            s["ev"]["tor_radaru"], s["ev"]["namiar"], s["ev"]["daleko"], s["ev"]["namierzenia"], s["ev"]["zwiad_wysuniety"]))
    o.append("</tbody></table></div><p class='note'>Strzały na tor radaru, namiar i z daleka są liczone ze zdarzeń nagrania, które dopisano w późniejszych seriach; "
             "w starszych seriach jest tam 0, bo nie były zapisywane.</p>")

    # 6. profiler
    z_profilem = [(p, k, s) for p, k, _, s in serie if s["prof"]]
    if z_profilem:
        o.append("<h2>Profiler procedur</h2><p class='note'>BYOND <code>world.Profile</code> przez całą bitwę. Czas <b>self</b> to sama procedura, "
                 "<b>total</b> z wywołaniami w środku. Procedury bazowe, które nadpisujemy (np. <code>move_toward</code>), mają w total także nasz kod.</p>"
                 "<div class='card tbl'><table><thead><tr><th>wariant</th><th>bitew</th><th>world.cpu</th><th>szczyt</th><th>okrętów AI</th><th>czas procedur</th>"
                 "<th>w tym aquila/ AI</th><th>tik AI (slowprocess, total)</th><th>move_toward (total)</th></tr></thead><tbody>")
        for p, k, s in z_profilem:
            tot = srednia([sum(v[0] for v in pr.values()) for pr in s["prof"]])
            ours = srednia([sum(v[0] for kk, v in pr.items() if kk in nasze) for pr in s["prof"]])
            sp = srednia([pr.get("/obj/structure/overmap/proc/slowprocess", (0, 0, 0))[1] for pr in s["prof"]])
            mt = srednia([pr.get("/obj/structure/overmap/proc/move_toward", (0, 0, 0))[1] for pr in s["prof"]])
            o.append("<tr><td class='nm'>%s</td><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s (%s)</td><td>%s</td><td>%s</td></tr>" % (
                html.escape(k), len(s["prof"]), liczba_pl(fmt(s["cpu"], 1, "%")), liczba_pl(fmt(s["cpu_max"], 0, "%")), liczba_pl(fmt(s["ai"], 1)),
                liczba_pl(fmt(tot, 1, " s")), liczba_pl(fmt(ours, 2, " s")), liczba_pl(fmt(100 * ours / tot, 1, "%")), liczba_pl(fmt(sp, 1, " s")), liczba_pl(fmt(mt, 1, " s"))))
        o.append("</tbody></table></div>")
        for p, k, s in z_profilem:
            per = collections.defaultdict(lambda: [0.0, 0.0, 0])
            for pr in s["prof"]:
                for kk, v in pr.items():
                    per[kk][0] += v[0]
                    per[kk][1] += v[1]
                    per[kk][2] += v[2]
            n = len(s["prof"])
            o.append("<details><summary>Najdroższe procedury: %s</summary><div class='tbl'><table><thead><tr><th>procedura</th><th>self na bitwę</th>"
                     "<th>total na bitwę</th><th>wywołań na bitwę</th><th></th></tr></thead><tbody>" % html.escape(k))
            for kk, v in sorted(per.items(), key=lambda x: -x[1][0])[:25]:
                o.append("<tr%s><td class='nm'><code>%s</code></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>" % (
                    " class='on'" if kk in nasze else "", html.escape(kk), liczba_pl(fmt(v[0] / n, 3, " s")), liczba_pl(fmt(v[1] / n, 2, " s")),
                    "{:,}".format(v[2] // n).replace(",", " "), "aquila/" if kk in nasze else ""))
            o.append("</tbody></table></div></details>")

    # 7. slowniczek
    o.append("<h2>Co znaczą te liczby</h2><div class='card'><dl>"
             "<dt>stoi</dt><dd>klatki (co 2 s), w których okręt AI przesunął się wolniej niż 0,3 pola/s; bez myśliwców, okrętu głównego i stacji</dd>"
             "<dt>lotniskowce stoją</dt><dd>to samo tylko dla lotniskowców</dd>"
             "<dt>walka</dt><dd>klatki z etykietą taktyki „walka” (cel w zasięgu broni)</dd>"
             "<dt>zamarznięte</dt><dd>okręty AI, które przez całą bitwę ani razu się nie ruszyły (95% klatek poniżej 0,05 pola/s)</dd>"
             "<dt>działa i PD</dt><dd>wszystkie strzały niekierowane okrętów AI, także obrona punktowa i działka myśliwców</dd>"
             "<dt>kierowane &gt;50 pól</dt><dd>udział strzałów torpedami i rakietami z odległości ponad 50 pól (bazowy limit AI)</dd>"
             "<dt>tor radaru</dt><dd>strzał do celu, który widzi radar pulsującego okrętu floty, a strzelający sam nie</dd>"
             "<dt>namiar zwiadowcy</dt><dd>strzał do celu namierzanego radarem frontalnym przez myśliwca-zwiadowcę</dd>"
             "<dt>world.cpu</dt><dd>średni odsetek czasu ticka zużyty przez całą grę (próbka co 2 s)</dd>"
             "<dt>aquila/ AI</dt><dd>czas self procedur zdefiniowanych w <code>aquila/code/modules/overmap/</code></dd>"
             "</dl></div>")
    o.append("</main><footer class='wrap'>Generator: <code>tools/ai_sandbox/build_stats.py</code>. Bitwy w piaskownicy (<code>-DAQ_AI_SANDBOX</code>), "
             "8 minut, floty 8 na 8 z okrętem głównym poza walką; kilka bitew naraz na jednej maszynie, więc liczby obciążenia są względne.</footer>"
             "<script>(function(){var znany=null;function sprawdz(){fetch(location.pathname+'?t='+Date.now(),{method:'HEAD',cache:'no-store'}).then(function(r){"
             "var m=r.headers.get('Last-Modified')||r.headers.get('ETag');if(!m)return;if(znany&&m!==znany){location.reload();}znany=m;}).catch(function(){});}"
             "sprawdz();setInterval(sprawdz,60000);})();</script></body></html>")
    return "".join(o)


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--dane", default="data")
    p.add_argument("--wyjscie", default="raport/bitwy/statystyki.html")
    a = p.parse_args(argv)
    tekst = zbuduj(a.dane)
    os.makedirs(os.path.dirname(a.wyjscie) or ".", exist_ok=True)
    with open(a.wyjscie, "w", encoding="utf-8", newline="\n") as f:
        f.write(tekst)
    print("zapisano %s (%.0f KB)" % (a.wyjscie, os.path.getsize(a.wyjscie) / 1024.0))
    return 0


if __name__ == "__main__":
    sys.exit(main())

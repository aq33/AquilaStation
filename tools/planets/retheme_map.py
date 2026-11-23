"""Przepina przekonwertowaną mapę ruiny na inną planetę: podmienia ścieżki typów i fragmenty tekstu
(napisy atmosfery, przedrostki obszarów). Do ruin pożyczanych przez typy planet bez własnych ruin.

Użycie: python tools/planets/retheme_map.py <źródło.dmm> <wynik.dmm> --path '/stara/ścieżka=>/nowa/ścieżka' ... --text 'stary=>nowy' ...
--path zamienia dokładnie tę ścieżkę (podtypy trzeba podać osobno).
--text zamienia dosłowny fragment (np. napis initial_gas_mix albo przedrostek obszaru).
"""
import argparse
import re


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('src')
    parser.add_argument('dst')
    parser.add_argument('--path', action='append', default=[])
    parser.add_argument('--text', action='append', default=[])
    args = parser.parse_args()
    text = open(args.src, encoding='utf-8').read()
    paths = [item.split('=>', 1) for item in args.path]

    def swap(match):
        path = match.group(0)
        for old, new in paths:
            if path == old:
                return new
        return path
    # ścieżki typów jako całe tokeny (koniec na {, przecinku, nawiasie albo końcu linii)
    text = re.sub(r'/(?:turf|obj|mob|area)(?:/[A-Za-z0-9_]+)+(?=[{,\n)])', swap, text)
    for item in args.text:
        old, new = item.split('=>', 1)
        text = text.replace(old, new)
    open(args.dst, 'w', encoding='utf-8', newline='\n').write(text)
    print('zapisano', args.dst)


if __name__ == '__main__':
    main()

"""Testy skanu tekstów bez angielskiego (list_missing.py): napisy w kodzie okien i komentarze DM.

Uruchomienie: python tools/i18n/test_list_missing.py (z katalogu repozytorium).
Większość testów podstawia zdania okien, więc nie trzeba Node. RealLoader bierze zdania z prawdziwego
loadera tgui/i18n-jsx.cjs i bez zależności tgui się pomija (w CI działa, bo krok idzie po budowie tgui).
"""

import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jsx_ast  # noqa: E402
import list_missing as lm  # noqa: E402

WINDOW = "tgui/packages/tgui/interfaces/Test.tsx"


class RealLoader(unittest.TestCase):
    """Kolumny zrzutu loadera (UTF-16 w JS) i skanera (Python) muszą się zgadzać też przy emoji."""

    LINE = "  const x = '😀😀'; return <Box>{'żółty przycisk'} teraz.</Box>;"

    def setUp(self):
        fd, self.path = tempfile.mkstemp(suffix=".tsx")
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write("export const A = () => {\n" + self.LINE + "\n};\n")
        self.items = jsx_ast.dump_file(self.path, WINDOW)
        if self.items is None:
            self.skipTest("brak Node albo zależności tgui (tools/build/build yarn)")
        self.saved = lm._sentences
        lm._sentences = lm.sentence_spans(self.items)

    def tearDown(self):
        os.remove(self.path)
        if hasattr(self, "saved"):
            lm._sentences = self.saved

    def test_fragment_zdania_po_emoji(self):
        self.assertIn("żółty przycisk teraz.", [item["literal"] for item in self.items])
        found = lm.scan_literals(WINDOW, 2, self.LINE, True)
        self.assertNotIn("żółty przycisk", found)
        self.assertIn("😀😀", found)  # napis przed zdaniem to osobny tekst


class WindowCodeStrings(unittest.TestCase):
    def test_napisy_w_kodzie(self):
        self.assertEqual(lm.window_code_strings("  label: 'Stado',"), ["Stado"])
        self.assertEqual(lm.window_code_strings("{x || 'Brak celu dodatkowego'}"), ["Brak celu dodatkowego"])
        self.assertEqual(lm.window_code_strings("const a = 'Żółty przycisk'.toUpperCase();"), ["Żółty przycisk"])
        self.assertEqual(lm.window_code_strings("const a = 'Żółty przycisk' as const;"), ["Żółty przycisk"])

    def test_apostrof_w_tekscie_jsx_to_nie_napis(self):
        self.assertEqual(lm.window_code_strings("Kliknij 'Start', żeby zacząć"), [])
        self.assertEqual(lm.window_code_strings("Kliknij 'Start'. Potem"), [])

    def test_komentarz(self):
        self.assertEqual(lm.window_code_strings("// label: 'Stado',"), [])


class WindowSentences(unittest.TestCase):
    # <Box>Wybierz {'żółty przycisk'} teraz.</Box> w linii 3: loader robi z tego jedno zdanie
    LINE = "const options = { label: 'żółty przycisk' }; return <Box>Wybierz {'żółty przycisk'} teraz.</Box>;"

    def setUp(self):
        start = self.LINE.index("Wybierz")
        end = self.LINE.index("</Box>")
        self.saved = lm._sentences
        lm._sentences = {WINDOW: [((3, start), (3, end))]}

    def tearDown(self):
        lm._sentences = self.saved

    def test_napis_w_zdaniu_nie_potrzebuje_wpisu(self):
        inner = self.LINE.index("{'") + 1
        self.assertTrue(lm.in_window_sentence(WINDOW, 3, inner))

    def test_osobny_napis_w_tej_samej_linii_jest_sprawdzany(self):
        # ta sama treść co fragment zdania, ale poza nim: label wymaga własnego tłumaczenia
        self.assertEqual(lm.scan_literals(WINDOW, 3, self.LINE, True), ["żółty przycisk"])

    def test_inna_linia(self):
        self.assertFalse(lm.in_window_sentence(WINDOW, 4, 10))


class DmComments(unittest.TestCase):
    def test_komentarz_blokowy(self):
        self.assertEqual(lm.line_literals("a.dm", ' * "raport" - aport'), [])
        self.assertEqual(lm.line_literals("a.dm", '/** "sąsiad" */'), [])

    def test_kod(self):
        self.assertEqual(lm.line_literals("a.dm", '\tname = "czapka testowa"'), ["czapka testowa"])


if __name__ == "__main__":
    unittest.main()

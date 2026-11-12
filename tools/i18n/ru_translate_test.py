"""Testy kontroli tłumaczeń rosyjskich (tools/i18n/ru_translate.py): python -m unittest tools/i18n/ru_translate_test.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import ru_translate as rt  # noqa: E402


class CheckTest(unittest.TestCase):
    def test_przyjmuje_poprawne(self):
        self.assertIsNone(rt.check("<span class='notice'>Podnosisz [I].</span>", "<span class='notice'>Вы поднимаете [I].</span>"))
        self.assertIsNone(rt.check("Zrobił[gender == FEMALE ? \"aś\" : \"eś\"] to.", "Сделал[gender == FEMALE ? \"а\" : \"\"] это."))

    def test_wstawki(self):
        self.assertEqual(rt.check("Podnosisz [I].", "Вы поднимаете [W]."), "inne wstawki")
        # \[tekst\] to zwykły tekst w nawiasie: polskie litery w nim są błędem
        self.assertEqual(rt.check("<a>\\[Zapłać\\]</a>", "<a>\\[Zapłać\\]</a>"), "polskie litery")
        self.assertIsNone(rt.check("<a>\\[Zapłać\\]</a>", "<a>\\[Оплатить\\]</a>"))

    def test_atrybuty_techniczne(self):
        self.assertEqual(rt.check("<a href='x'>Akta</a>", "<a href='y'>Записи</a>"), "inne znaczniki HTML")
        self.assertEqual(rt.check("<span class='notice'>Tak</span>", "<span class='warning'>Да</span>"), "inne znaczniki HTML")

    def test_value(self):
        # napis na przycisku formularza wolno przetłumaczyć
        self.assertIsNone(rt.check("<input type='submit' value='Wyślij'>", "<input type='submit' value='Отправить'>"))
        self.assertIsNone(rt.check("<input type=submit value='Wyślij'>", "<input type=submit value='Отправить'>"))
        # value pola ukrytego to dane formularza
        self.assertEqual(rt.check("<input type='hidden' name='initializepoll' value='1'>Ankieta",
                                  "<input type='hidden' name='initializepoll' value='0'>Опрос"), "inne znaczniki HTML")

    def test_atrybuty_logiczne(self):
        self.assertEqual(rt.check("<input type='checkbox' name='a' checked>Tak", "<input type='checkbox' name='a'>Да"),
                         "inne znaczniki HTML")
        self.assertIsNone(rt.check("<input type='checkbox' name='a' checked>Tak", "<input type='checkbox' name='a' checked>Да"))

    def test_nie_znaczniki(self):
        # "<" w wyrażeniu i zepsuty znacznik z polskiego kodu to nie znaczniki HTML
        self.assertIsNone(rt.check('Głód.[bonus < 5 ? " Moc rośnie.":""]', 'Голод.[bonus < 5 ? " Сила растёт.":""]'))
        self.assertIsNone(rt.check("<span class='danger'Możesz wrócić.</span>", "<span class='danger'Вы можете вернуться.</span>"))


class LineLiteralsTest(unittest.TestCase):
    def test_napisy_z_zagniezdzonych_wstawek(self):
        import list_missing as lm
        # "wkrótce" stoi obok napisu z własną wstawką: wcześniej brany był tylko najgłębszy nawias
        line = 'to_chat(src, "Gra rozpocznie się [tl > 0 ? "za około [DisplayTimeText(tl)]" : "wkrótce"].")'
        found = lm.line_literals("a.dm", line)
        self.assertIn("wkrótce", found)
        self.assertIn("za około [DisplayTimeText(tl)]", found)
        # \" poza napisem (tekst wieloliniowy {" "}) nie zaczyna napisu
        self.assertEqual(list(lm.embed_strings('ckey || \\"brak\\"')), [])
        self.assertEqual(list(lm.nested_strings('a \\[b\\] [x ? "c [y ? "d" : "e"]" : "f"]')), ['c [y ? "d" : "e"]', "d", "e", "f"])


if __name__ == "__main__":
    unittest.main()

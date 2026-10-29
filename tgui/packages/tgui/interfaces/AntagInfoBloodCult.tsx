// AQUILA - okno roli kultu krwi „Cult 4” (vg/Monke): runy ze słów, oddanie, rytuały, tatuaże, Zaćmienie
import { type ReactNode, useState } from 'react';
import { Box, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { type Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  objectives: Objective[];
};

const Red = (props: { children: ReactNode }) => (
  <Box inline textColor="red">
    <b>{props.children}</b>
  </Box>
);

const BasicsTab = () => (
  <Box>
    <p>
      Służysz <Red>Nar&apos;Sie</Red>, Geometrze Krwi. Kult zaczyna mały i
      ukryty: zdobywa <Red>oddanie</Red>, rośnie i przybliża{' '}
      <Red>Zaćmienie</Red>, w czasie którego może sprowadzić boginię na statek.
    </p>
    <p>
      <Red>Panel kultu</Red> na ekranie to twoje centrum dowodzenia: pokazuje
      oddanie, rytuały, członków kultu, postęp Zaćmienia i twoją rolę. Ma też
      strony pomocy, do których warto zajrzeć na początku.
    </p>
    <p>
      <Red>Runy</Red> kreślisz krwią z panelu kultu. Pełna runa to 3 słowa (np.
      Podróż, Krew, Złączenie), a każda kombinacja daje inne zaklęcie. Krew
      bierzesz z siebie, z plam i zakrwawionych dłoni, z worków i pojemników z
      krwią albo z osoby, którą trzymasz. Dotknij gotowej runy, żeby rzucić
      zaklęcie. Runy można przenosić na <Red>talizmany</Red> i nosić w kieszeni.
    </p>
    <p>
      Opis wszystkich run znajdziesz w <Red>Tajemnej Księdze</Red>, którą
      przywołasz runą Akcesoriów (ta runa daje też talizmany, świece, nóż
      rytualny i inne akcesoria).
    </p>
    <p>
      <Red>Komunikacja</Red>: runa Komunikacji pozwala mówić do całego kultu, a
      po wzniesieniu Iglicy kultyści na tym samym poziomie porozumiewają się
      przez <b>:f</b>.
    </p>
    <p>
      <Red>Role</Red>: nowi kultyści mogą zostać akolitami pod opieką mentora.
      Doświadczeni kultyści mogą zostać mentorami albo działać samodzielnie jako
      heroldzi. Rolę zmienisz w panelu kultu.
    </p>
  </Box>
);

const DevotionTab = () => (
  <Box>
    <p>
      <Red>Oddanie</Red> zdobywasz niemal każdym działaniem kultu: kreśleniem i
      używaniem run, nawracaniem, przemienianiem statku, walką bronią kultu. Im
      więcej oddania, tym wyższa ranga i tym szybciej nadchodzi Zaćmienie.
    </p>
    <p>
      <Red>Rytuały</Red> pojawiają się w panelu kultu po kilku minutach rundy.
      Każdy kultysta ma 2 rytuały osobiste, a cały kult 3 wspólne (np. rozlej
      krew, oślep kamery, złóż ofiarę na ołtarzu, zbuduj po jednym konstrukcie
      każdego rodzaju). Ukończony rytuał daje dużo oddania, a po pewnym czasie
      jego miejsce zajmuje nowy.
    </p>
    <p>
      <Red>Tatuaże</Red>: przy Iglicy wyższa ranga pozwala wybrać tatuaż z
      kolejnego poziomu (są 3 poziomy). Dają m.in. wspólnotę krwi (tańsze runy,
      krew dzielona z innymi), krwawy sztylet, ciche rzucanie, nieświętą ochronę
      przed wodą święconą, runiczną skórę (runa na skórze), sigil skrótu
      (przejście przez ścianę) czy tajemny wymiar (księga ukryta w powietrzu).
    </p>
    <p>
      Kult ma <Red>limit członków</Red> zależny od liczby załogi (od 5 do 9,
      plus po jednym konstrukcie każdego rodzaju). Panel pokazuje, ile miejsc
      zostało.
    </p>
  </Box>
);

const ConversionTab = () => (
  <Box>
    <p>
      <Red>Konwersja</Red>: połóż ofiarę na runie Konwersji i ją uruchom. Ofiara
      jest ogłuszona przez cały rytuał. Kto nie ma kultu włączonego w
      preferencjach, może <Red>odmówić</Red>. Wtedy, podobnie jak osoby z
      implantem lojalności, kapelan i inni nienawracalni, zostaje{' '}
      <Red>więźniem kultu</Red>, dopóki ma na sobie więzy kultu.
    </p>
    <p>
      Więźniowie mogą zastąpić kultystów w ostatnim rytuale Rozdarcia
      Rzeczywistości.
    </p>
    <p>
      <Red>Dekonwersja</Red>: kapelan albo inna osoba z Biblią może odprawić nad
      tobą egzorcyzm, jeśli masz we krwi wodę święconą. Możesz się mu oprzeć, a
      porzucenie kultu kosztuje krew i ból.
    </p>
    <p>
      <Red>Śmierć</Red> nie musi być końcem: kultysta, który umrze, staje się
      cieniem, a runa Reinkarnacji może dać mu nowe ciało.
    </p>
  </Box>
);

const StructuresTab = () => (
  <Box>
    <p>
      Budowle wznosisz runą <Red>Wzniesienia Budowli</Red>. Runy i budowle można
      ukrywać i ponownie odsłaniać.
    </p>
    <p>
      <Red>Ołtarz</Red> służy do rytuałów i ofiar (rytualny nóż, ostrze kultu),
      tworzy klejnot dusz i pozwala porozumieć się z Nar&apos;Sie.
    </p>
    <p>
      <Red>Kuźnia</Red> wykuwa broń i pancerz kultu.
    </p>
    <p>
      <Red>Iglica</Red> daje tatuaże i pozwala kultystom na tym samym poziomie
      rozmawiać przez <b>:f</b>.
    </p>
    <p>
      <Red>Pylon</Red> leczy pobliskich kultystów i przemienia podłogi wokół
      siebie.
    </p>
    <p>
      <Red>Konstrukty</Red>: napełnij klejnot albo kamień dusz duchem lub
      zwłokami, włóż go do skorupy konstruktu i wybierz rzemieślnika, widmo albo
      juggernauta.
    </p>
  </Box>
);

const EclipseTab = () => (
  <Box>
    <p>
      <Red>Zaćmienie</Red> zbliża się tym szybciej, im więcej żywych i oddanych
      kultystów. Gdy nadejdzie, na statku gasną światła, niebo robi się
      czerwone, a prom ewakuacyjny nie może odlecieć.
    </p>
    <p>
      W czasie Zaćmienia kult musi odprawić <Red>Rozdarcie Rzeczywistości</Red>.
      Runę pokaże ci panel kultu. Nakreśl ją w otwartym miejscu na statku i
      zbierz 8 kultystów albo więźniów. Tancerze stoją na platformach i
      powtarzają słowa, które Nar&apos;Sie przekazuje w panelu kultu.
    </p>
    <p>
      Udany rytuał wznosi <Red>Krwawy Kamień</Red>. Załoga zostaje ostrzeżona i
      ma kilka minut, żeby go zniszczyć. Jeśli kamień przetrwa,{' '}
      <Red>Nar&apos;Sie przybywa</Red> i kult wygrywa.
    </p>
    <p>
      Jeśli Krwawy Kamień zostanie zniszczony, zasłona się zrasta: istniejące
      runy znikają, kult słabnie i nie zdobywa już oddania.
    </p>
    <p>
      Jeśli Zaćmienie minie bez rytuału, <Red>uciekajcie promem</Red>{' '}
      ewakuacyjnym, żywi i wolni, żeby spróbować innym razem. Ucieczka samymi
      kapsułami to tchórzostwo, a skuci kultyści na promie trafią do aresztu.
    </p>
    <p>
      Gdy Krwawy Kamień stoi, duchy mogą przyłączyć się do kultu i pisać krwawe
      napisy.
    </p>
  </Box>
);

const GuideSection = () => {
  const [tab, setTab] = useState(1);
  return (
    <Section title="Przewodnik kultysty">
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Podstawy
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          Oddanie i rytuały
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
          Konwersja
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
          Budowle
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
          Zaćmienie
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && <BasicsTab />}
      {tab === 2 && <DevotionTab />}
      {tab === 3 && <ConversionTab />}
      {tab === 4 && <StructuresTab />}
      {tab === 5 && <EclipseTab />}
    </Section>
  );
};

export const AntagInfoBloodCult = () => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={650} height={720} theme="narsie">
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name="Kultysta Nar'Sie" asset="bloodcult.png" />
          </Stack.Item>
          <Stack.Item>
            <GuideSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Image, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  objectives: Objective[];
};

const StructureAltar = (_props) => {
  return (
    <Box>
      <Image
        src={resolveAsset('cult-altar.gif')}
        width="48px"
        style={{
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      <Box inline textColor="red">
        Ołtarz
      </Box>{' '}
      to zakrwawiony ołtarz poświęcony{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      . Może wytworzyć 4 różne przedmioty:
      <br />
      <Box inline textColor="red">
        <b>Pradawna osełka</b>
      </Box>
      : zakrwawiona osełka do ostrzenia twoich ostrzy.
      <br />
      <Box inline textColor="red">
        <b>Powłoka konstruktu</b>
      </Box>
      : pusta powłoka, która zmienia się w konstrukt, gdy umieścisz w niej
      kamień duszy.
      <br />
      <Box inline textColor="red">
        <b>Flaszka nieświętej wody</b>
      </Box>
      : ciemna flaszka z nieświętą wodą, która leczy wiernych, a heretykom pali
      żyły.
      <br />
      <Box inline textColor="red">
        <b>Powłoka runicznego golema</b>
      </Box>
      : poświęcona powłoka, która wiąże kamień duszy w konstrukt runicznego
      golema.
    </Box>
  );
};

const StructureArchives = (_props) => {
  return (
    <Box>
      <Image
        src={resolveAsset('cult-archives.gif')}
        width="48px"
        style={{
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      <Box inline textColor="red">
        Archiwum
      </Box>{' '}
      to biurko zawalone pradawnymi rękopisami wielkiej{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      . Może wytworzyć 3 różne przedmioty:
      <br />
      <Box inline textColor="red">
        <b>Opaska fanatyka</b>
      </Box>
      : opaska na oczy, która, paradoksalnie, pozwala noszącemu ją wiernemu
      widzieć w ciemności.
      <br />
      <Box inline textColor="red">
        <b>Klątwa promu</b>
      </Box>
      : tajemnicza kula, której rozbicie opóźnia prom ewakuacyjny.
      <i>Działa tylko raz.</i>
      <br />
      <Box inline textColor="red">
        <b>Zestaw wędrowca zasłony</b>
      </Box>
      : zestaw dwóch przedmiotów – <b>przesuwacza zasłony</b>, który do 4 razy
      teleportuje cię spory kawałek do przodu, i <b>pochodni pustki</b>, która
      natychmiast przenosi przedmioty do innych wiernych.
    </Box>
  );
};

const StructureForge = (_props) => {
  return (
    <Box>
      <Image
        src={resolveAsset('cult-forge.gif')}
        width="48px"
        style={{
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      <Box inline textColor="red">
        Kuźnia demonów
      </Box>{' '}
      służy do wykuwania nieświętej broni dla armii wielkiej{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      . Może wytworzyć 3 różne przedmioty:
      <br />
      <Box inline textColor="red">
        <b>Szata z tarczą</b>
      </Box>
      : wzmocnione szaty, które w całości blokują ograniczoną liczbę ataków na
      noszącego.
      <br />
      <Box inline textColor="red">
        <b>Szata biczownika</b>
      </Box>
      : szaty pobłogosławione krwawą szybkością, które zwiększają twoją
      podatność na obrażenia, ale pozwalają ci poruszać się z nieludzką
      prędkością.
      <br />
      <Box inline textColor="red">
        <b>Lustrzana tarcza</b>
      </Box>
      : nieświęta tarcza, która przywołuje iluzje do twojej obrony. Można nią
      też rzucić, żeby kogoś przewrócić.
    </Box>
  );
};

const StructurePylon = (_props) => {
  return (
    <Box>
      <Image
        src={resolveAsset('cult-pylon.gif')}
        width="48px"
        style={{
          imageRendering: 'pixelated',
          float: 'left',
        }}
      />
      <Box inline textColor="red">
        Pylon
      </Box>{' '}
      to unoszący się kryształ pobłogosławiony przez{' '}
      <Box inline textColor="#aa1c1c">
        <b>Nar&apos;Sie</b>
      </Box>
      . Powoli zamienia pobliską podłogę w runiczne płytki i leczy pobliskich
      kultystów.
      <br />
      Runiczna podłoga jest odporna (choć nie całkowicie) na zmiany atmosfery, a
      runy rysuje się na niej szybciej.
    </Box>
  );
};

const StructureSection = (_props) => {
  const [tab, setTab] = useLocalState('structureTab', 1);
  return (
    <Section title="Budowle">
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          Ołtarz
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          Archiwum
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
          Kuźnia
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
          Pylon
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && <StructureAltar />}
      {tab === 2 && <StructureArchives />}
      {tab === 3 && <StructureForge />}
      {tab === 4 && <StructurePylon />}
      <br />
      <i>
        Każdą budowlę kultu możesz odczepić od podłogi i przytwierdzić z
        powrotem, uderzając ją sztyletem rytualnym.
      </i>
    </Section>
  );
};

const BloodMagicSection = (_props) => {
  const [tab, setTab] = useLocalState('magicTab', 1);
  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Przygotuj magię krwi
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Ogłuszenie
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Teleportacja
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
            Impuls elektromagnetyczny
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
            Kajdany cienia
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
            Wypaczona budowa
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 7} onClick={() => setTab(7)}>
            Przywołaj sprzęt bojowy
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 8} onClick={() => setTab(8)}>
            Przywołaj sztylet rytualny
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 9} onClick={() => setTab(9)}>
            Halucynacje
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 10} onClick={() => setTab(10)}>
            Ukryj obecność
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 11} onClick={() => setTab(11)}>
            Rytuały krwi
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        {tab === 1 && (
          <Box>
            <Image
              src={resolveAsset('cult-carve.png')}
              width="32px"
              style={{
                imageRendering: 'pixelated',
                float: 'left',
              }}
            />
            <Box inline textColor="red">
              Przygotuj magię krwi
            </Box>{' '}
            pozwala ci wyryć na sobie runy, by rzucać magię krwi. Nie da się ich
            wykryć, dopóki ich nie użyjesz, a przydają się w wielu sytuacjach.
            <br />
            Normalnie możesz mieć na sobie tylko 1 zaklęcie, ale na runie
            <b>Wzmocnienia</b> wyryjesz ich do 4!
            <br />
            <b>Uwaga</b>: większość magii krwi nie działa na osoby święte
            (kapłana) ani na kogoś z antymagią (np. trzymającego święty arbuz).
          </Box>
        )}
        {tab === 2 && (
          <Box>
            <h2>
              <Box inline textColor="#FF0000">
                <i>Fuu ma&apos;jin!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Ogłuszenie
            <br />
            <b>Ładunki</b>: 1
            <br />
            <p>
              Potężne zaklęcie, które przy dotyku ogłusza i ucisza ofiarę.
              Proste, czyste i skuteczne w mnóstwie sytuacji.
            </p>
            <p>
              Paraliżuje na 16 s, ucisza na 12 s i przez 30 s (od chwili
              ogłuszenia) zniekształca mowę w język kultu. Na cyborga działa jak
              silny EMP.
            </p>
            <p>
              <b>Nie działa na osoby z implantem ochrony umysłu!</b>
            </p>
            <p>
              Ofiara mówi wtedy w niepokojący, niezrozumiały sposób. Jeśli
              wykrzyczy coś przez radio, zwykle zdradza to, że na pokładzie jest
              kult (chyba że barman rozdał o wiele za dużo Nar&apos;Sourów).
            </p>
          </Box>
        )}
        {tab === 3 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Sas&apos;so c&apos;arta forbici!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Teleportacja
            <b>Ładunki</b>: 1
            <p>
              Natychmiast teleportuje ciebie, kogoś albo coś na narysowaną runę
              Teleportacji.
            </p>
          </Box>
        )}
        {tab === 4 && (
          <Box>
            <h2>
              <Box inline textColor="#4D94FF">
                <i>Ta&apos;gh fara&apos;qha fel d&apos;amar det!!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Impuls elektromagnetyczny
            <br />
            <b>Ładunki</b>: 1
            <p>
              Potężne zaklęcie, które przekuwa mroczną energię w EMP. Cała
              elektronika w okolicy psuje się albo wyłącza.
            </p>
          </Box>
        )}
        {tab === 5 && (
          <Box>
            <h2>
              <Box inline textColor="#2a2a2a">
                <i>In&apos;otum Lig&apos;abis!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Kajdany cienia
            <br />
            <b>Ładunki</b>: 4
            <p>
              Ciche zaklęcie, które zakuwa ofiarę w cieniste kajdanki i ucisza
              ją na 10 s. Służy do trzymania załogi w kajdankach do czasu
              nawrócenia. Kajdanki znikają, gdy ofiara zostanie nawrócona.
            </p>
          </Box>
        )}
        {tab === 6 && (
          <Box>
            <h2>
              <Box inline textColor="#2a2a2a">
                <i>Ethra p&apos;ni dedol!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Wypaczona budowa
            <br />
            <b>Ładunki</b>: 1
            <p>
              Zamienia plastal w runiczny metal, 50 sztuk żelaza w powłokę
              konstruktu, żywe cyborgi i SI w konstrukty (po chwili), powłoki
              cyborgów w powłoki konstruktów, a śluzy w kruche runiczne śluzy
              (po chwili, w trybie walki)
            </p>
          </Box>
        )}
        {tab === 7 && (
          <Box>
            <b>Nazwa</b>: Przywołaj sprzęt bojowy
            <b>Ładunki</b>: 1
            <p>
              Użyte na kultyście (także na tobie) przywołuje na nim nieziemski
              pancerz razem z ostrzem kultu i bolą.
            </p>
          </Box>
        )}
        {tab === 8 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Wur d&apos;dai leev&apos;mai k&apos;sagan!!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Przywołaj sztylet rytualny
            <br />
            <b>Ładunki</b>: 1
            <p>
              Przywołuje sztylet rytualny do rysowania run, gdy swój zgubisz
              albo zapomnisz go podnieść z podłogi po nawróceniu. Aktywuj
              zaklęcie i kliknij na siebie.
            </p>
          </Box>
        )}
        {tab === 9 && (
          <Box>
            <b>Nazwa</b>: Halucynacje
            <br />
            <b>Ładunki</b>: 4
            <p>
              Po cichu przeklina czyjś umysł żywymi koszmarami i wywołuje
              halucynacje. Działa na odległość i jest zupełnie bezgłośne.
            </p>
          </Box>
        )}
        {tab === 10 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Kla&apos;atu barada nikt&apos;o!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Ukryj obecność
            <br />
            <b>Ładunki</b>: 10
            <p>
              Wielofunkcyjne zaklęcie, które na przemian ukrywa i odsłania runy
              i budowle kultu w promieniu <b>5 pól</b>. Nadal możesz
              teleportować się na ukryte runy Teleportacji i przygotowywać magię
              krwi na ukrytych runach Wzmocnienia.
            </p>
            <p>
              Runiczne śluzy wyglądają wtedy jak zwykłe śluzy techniczne, ale
              dostęp do nich mają tylko kultyści.
            </p>
          </Box>
        )}
        {tab === 11 && (
          <Box>
            <h2>
              <Box inline textColor="red">
                <i>Fel&apos;th Dol Ab&apos;orod!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Rytuały krwi
            <br />
            <b>Ładunki</b>: 5
            <p>
              Złożona magia krwi, która leczy kultystów, przywołuje włócznię,
              wystrzeliwuje potężne krwawe pociski albo tworzy ogromny promień,
              który zamienia ściany i podłogi w budowle Nar&apos;Sie.
            </p>
            <p>
              Rytuały krwi zasila krew – użyj ręki na podłodze (albo na żywych
              ofiarach), żeby wchłonąć krew z podłogi i zasilić rytuały.
            </p>
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};

const RunesSection = (_props) => {
  const [tab, setTab] = useLocalState('runeTab', 1);
  return (
    <Stack>
      <Stack.Item>
        <Tabs vertical>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Ofiara
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Wzmocnienie
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Teleportacja
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
            Wskrzeszenie
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
            Bariera
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
            Przywołanie kultysty
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 7} onClick={() => setTab(7)}>
            Wrząca krew
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 8} onClick={() => setTab(8)}>
            Kraina duchów
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 9} onClick={() => setTab(9)}>
            Apokalipsa
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 10} onClick={() => setTab(10)}>
            Nar&apos;Sie
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        {tab === 1 && (
          <Box>
            <h2>
              <Box inline textColor="#FFFFFF">
                <i>Mah&apos;weyh pleggh at e&apos;ntrath!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Ofiara
            <br />
            <b>Wymagani kultyści</b>: 1 (ofiara z martwego, który nie jest
            celem), 2 (nawrócenie), 3 (ofiara z celu albo z żywej osoby)
            <p>
              Natychmiast nawraca zwykłego członka załogi stojącego na runie,
              leczy mu 75% obrażeń fizycznych i od poparzeń oraz tworzy sztylet
              rytualny.
            </p>
            <p>
              Załogi z implantem ochrony umysłu nie da się nawrócić, można ją
              tylko złożyć w ofierze (a konstrukty nie są mniej groźne od ludzi)
              –{' '}
              <b>
                dlatego szybko dobijaj ofiary z ochrony, zanim zdradzi cię ich
                radio albo czujniki stroju!
              </b>
            </p>
            <p>
              Ofiara zostaje rozerwana na strzępy, a jej dusza trafia do
              kamienia duszy, który możesz potem włożyć do powłoki konstruktu
              albo golema.
            </p>
          </Box>
        )}
        {tab === 2 && (
          <Box>
            <h2>
              <Box inline textColor="#0000FF">
                <i>H&apos;drak v&apos;loso, mir&apos;kanas verbot!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Wzmocnienie
            <br />
            <b>Wymagani kultyści</b>: 1
            <p>
              Pozwala kultystom przygotować więcej magii krwi znacznie mniejszym
              kosztem. Na runie Wzmocnienia limit zaklęć wynosi 4 zamiast 1.
            </p>
            <p>
              Do tego przygotowanie magii krwi trwa znacznie krócej i tracisz
              przy tym mniej krwi.
            </p>
          </Box>
        )}
        {tab === 3 && (
          <Box>
            <h2>
              <Box inline textColor="#551A8B">
                <i>Sas&apos;so c&apos;arta forbici!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Teleportacja
            <br />
            <b>Wymagani kultyści</b>: 1
            <p>
              Ta runa przenosi wszystko, co na niej stoi, na inną runę
              Teleportacji. Przy tworzeniu runy możesz nadać jej etykietę.
            </p>
            <p>
              <b>Ostrzeżenie:</b>{' '}
              <i>
                Teleportacja z Lavalandu albo z kosmosu sprawia, że runa
                docelowa jasno świeci i otwiera szczelinę w rzeczywistości,
                która może zdradzić nie tylko runę, ale i położenie twojej
                głównej bazy. Wybieraj miejsca na runy rozważnie!
              </i>
            </p>
          </Box>
        )}
        {tab === 4 && (
          <Box>
            <h2>
              <Box inline textColor="#C80000">
                <i>
                  Pasnar val&apos;keriam usinar. Savrae ines amutan.
                  Yam&apos;toth remium il&apos;tarat!
                </i>
              </Box>
            </h2>
            <b>Nazwa</b>: Wskrzeszenie
            <br />
            <b>Wymagani kultyści</b>: 1
            <p>
              Każda ofiara złożona na runie Ofiary dodaje tej runie jeden
              (wspólny) ładunek. Połóż zwłoki kultysty na runie i ją aktywuj, a
              kultysta wróci do życia kosztem aż trzech ładunków. Na start jest
              jedno darmowe wskrzeszenie, więc korzystaj z niego oszczędnie.
            </p>
            <p>
              Kultystów w katatonii (rozłączonych albo duchów) możesz obudzić z
              nową duszą, kładąc ich na runie Wskrzeszenia i aktywując ją. Takie
              wskrzeszenie nie zużywa ładunków.
            </p>
          </Box>
        )}
        {tab === 5 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Khari&apos;d! Eske&apos;te tannin!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Bariera
            <br />
            <b>Wymagani kultyści</b>: 1
            <p>
              Po aktywacji tworzy na 5 minut niewidzialną ścianę, która blokuje
              przejście. Ponowna aktywacja ją usuwa.
            </p>
            <p>
              Aktywacja jednej runy Bariery łańcuchowo aktywuje inne runy
              Bariery w odległości do 2 pól od siebie. Wyłączenie runy nie
              wyłącza łańcuchowo pozostałych.
            </p>
            <p>
              Aktywacja i wyłączenie kosztują po 2 obrażenia fizyczne
              (niezależnie od liczby połączonych run). Aktywne runy Bariery
              delikatnie falują i zwykle są jaśniejsze.
            </p>
          </Box>
        )}
        {tab === 6 && (
          <Box>
            <h2>
              <Box inline textColor="#00FF00">
                <i>N&apos;ath reth sh&apos;yro eth d&apos;rekkathnor!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Przywołanie kultysty
            <br />
            <b>Wymagani kultyści</b>: 2
            <p>
              Ta runa natychmiast przywołuje na siebie dowolnego żywego
              kultystę, po czym znika.
            </p>
            <p>
              <b>Ta runa działa tylko na głównej stacji</b>, ale ściąga
              kultystów niemal z każdego miejsca!
            </p>
            <p>
              Nie działa na skrępowanych kultystów, którzy są przypięci albo
              ciągnięci.
            </p>
          </Box>
        )}
        {tab === 7 && (
          <Box>
            <h2>
              <Box inline textColor="#CC5500">
                <i>Dedo ol&apos;btoh!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Wrząca krew
            <br />
            <b>Wymagani kultyści</b>: 3
            <p>
              Po aktywacji wysysa trochę zdrowia z przywołujących i wysyła trzy
              raniące impulsy do każdego, kto widzi runę. Zadają one 25/50/75
              obrażeń, po równo fizycznych i od poparzeń. Na koniec runa na
              chwilę podpala wszystko, co na niej leży.
            </p>
            <p>
              Niektóre rasy, na przykład golemy, nie mają krwi, więc są odporne
              na tę runę. Kultystom Ratvara zadaje też dodatkowe obrażenia
              wytrzymałości.
            </p>
          </Box>
        )}
        {tab === 8 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Gal&apos;h&apos;rfikk harfrandid mud&apos;gib!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Kraina duchów
            <br />
            <b>Wymagani kultyści</b>: 1
            <p>Ta runa daje ci dwie potężne możliwości:</p>
            <p>
              <b>1)</b> Zmaterializować duchy jako półprzezroczyste homunkulusy,
              czyli słabych, humanoidalnych kultystów bez instynktu
              samozachowawczego. Żeby je utrzymać, musisz stać na runie, a każdy
              przywołany homunkulus z czasem zadaje ci obrażenia fizyczne. Jeśli
              utkniesz na runie po przywołaniu ducha, usuń ją sztyletem
              rytualnym, zanim za bardzo oberwiesz.
              <br />
              Ta możliwość działa tylko na samej stacji, bo w kosmosie ani na
              Lavalandzie zasłona nie jest dość cienka, by dać duchom fizyczną
              postać.
            </p>
            <p>
              <b>2)</b> Wznieść się jako mroczny duch. Nie kosztuje to zdrowia i
              daje ci praktycznie nieograniczoną wiedzę! W tej postaci możesz
              korzystać z informacji od duchów, przemawiać do kultu donośnym
              głosem, a nawet oznaczyć cel, który reszta kultu będzie widzieć
              „namierzony”. Możesz też użyć tej opcji po zmaterializowaniu
              duchów, żeby prowadzić je w walce – zmaterializowane duchy widzą
              zwykłe duchy, więc widzą też twojego mrocznego ducha, gdy
              prowadzisz je do boju!
            </p>
          </Box>
        )}
        {tab === 9 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>Ta&apos;gh fara&apos;qha fel d&apos;amar det!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Apokalipsa
            <br />
            <b>Wymagani kultyści</b>: 3
            <p>
              Zwiastun końca czasów. Jej siła zależy od tego, jak silna jest
              załoga w porównaniu z kultem. Wywołuje potężny EMP, wyjątkowe
              halucynacje u nie-kultystów, a jeśli kultowi idzie słabo, także
              pewne eventy. Runę można narysować tylko w miejscach rytuału
              Nar&apos;Sie i potem nie da się już tam przywołać Nar&apos;Sie.
            </p>
            <p>
              Tak jak Rytuał Rozdarcia Wymiarów, runę Apokalipsy można narysować
              tylko w jednym z 3 miejsc rytuału. Po narysowaniu runy Apokalipsy
              to miejsce nie nadaje się już do przywołania Nar&apos;Sie.
            </p>
          </Box>
        )}
        {tab === 10 && (
          <Box>
            <h2>
              <Box inline textColor="#7D1717">
                <i>TOK-LYR RQA-NAP G&apos;OLT-ULOFT!!</i>
              </Box>
            </h2>
            <b>Nazwa</b>: Nar&apos;Sie
            <br />
            <b>Wymagani kultyści</b>: 9
            <p>
              Ta runa rozdziera bariery wymiarów i przywołuje Geometrę.
              Potrzebuje wolnego miejsca 3x3 i można ją przywołać tylko w 3
              miejscach na stacji. Zanim zaczniesz ją rysować, wyznaczony cel
              musi już zostać złożony w ofierze. Rozpoczęcie rysowania tworzy
              wokół rysującego słabe pole siłowe i zdradza całej stacji jego
              położenie. Rysującego trzeba bronić przez 45 s, aż runa będzie
              gotowa.
            </p>
            <p>
              Gdy runa jest gotowa, musi na niej stanąć 9 kultystów, konstruktów
              albo przywołanych duchów. Wtedy można ją aktywować i przywołać
              samą Nar&apos;Sie.
            </p>
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};

const PowersSection = (_props) => {
  const [tab, setTab] = useLocalState('powersTab', 1);
  return (
    <Section title="Moce">
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Image
                src={resolveAsset('dagger.png')}
                width="32px"
                style={{
                  imageRendering: 'pixelated',
                  float: 'left',
                }}
              />
              Twój{' '}
              <Box inline textColor="red">
                sztylet rytualny
              </Box>{' '}
              to niezbędne narzędzie w służbie Nar&apos;Sie!
              <br />
              Pozwala ci szybko rysować na podłodze{' '}
              <Box inline textColor="red">
                krwawe runy
              </Box>{' '}
              o najróżniejszych mocach!
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Image
                src={resolveAsset('cult-comms.png')}
                width="32px"
                style={{
                  imageRendering: 'pixelated',
                  float: 'left',
                }}
              />
              Użyj{' '}
              <Box inline textColor="red">
                Komunii
              </Box>
              , żeby porozumiewać się z innymi kultystami. Takie wiadomości
              słyszą wszyscy kultyści.
              <br />
              Uważaj jednak: osoby stojące blisko ciebie też cię usłyszą!
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Tabs>
            <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
              Magia krwi
            </Tabs.Tab>
            <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
              Runy
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && <BloodMagicSection />}
          {tab === 2 && <RunesSection />}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoBloodCult = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={750} height={900} theme="narsie">
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name="Kultysta krwi" asset="bloodcult.png" />
          </Stack.Item>
          <Stack.Item>
            <PowersSection />
          </Stack.Item>
          <Stack.Item>
            <StructureSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

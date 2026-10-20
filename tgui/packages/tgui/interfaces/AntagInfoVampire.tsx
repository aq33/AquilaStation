import { BooleanLike } from 'common/react';
import { sanitizeText } from 'tgui/sanitize';
import { DmIcon } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type VampireInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  powers: PowerInfo[];
};

type ClanInfo = {
  name: string;
  description: string;
  icon: string;
  icon_state: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
  icon_state: string;
  cost: string;
  constant_cost: string;
  cooldown: string;
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoVampire = (_props) => {
  // Set default to 2 so Basics (now in the middle) opens by default
  const [tab, setTab] = useLocalState('tab', 2);

  // Styles for the top-level tabs:
  const topTabsStyle = {
    display: 'flex',
    width: '100%',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;
  const topTabStyle = {
    flex: 1,
    fontSize: '25px',
    padding: '10px 12px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
    fontWeight: 900,
    letterSpacing: '0.5px',
    textShadow: '0 1px 0 rgba(0,0,0,0.6)',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;

  return (
    <Window width={700} height={750} theme="spooky">
      <Window.Content>
        <Box align="center" style={{ width: '100%' }}>
          <Tabs style={topTabsStyle}>
            {/* Guide on the left */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === 1}
              onClick={() => setTab(1)}
            >
              Przewodnik
            </Tabs.Tab>

            {/* Basics in the middle (slightly larger/bold for emphasis) */}
            <Tabs.Tab
              style={{ ...topTabStyle, fontSize: '30px', fontWeight: 900 }}
              selected={tab === 2}
              onClick={() => setTab(2)}
            >
              Podstawy
            </Tabs.Tab>

            {/* Powers on the right */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === 3}
              onClick={() => setTab(3)}
            >
              Moce
            </Tabs.Tab>
          </Tabs>
        </Box>

        {/* Re-map which component shows for each tab index to match the new ordering */}
        {tab === 1 && <VampireGuide />}
        {tab === 2 && <VampireIntroduction />}
        {tab === 3 && <PowerSection />}
      </Window.Content>
    </Window>
  );
};

const VampireIntroduction = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <AntagInfoHeader name={'Wampir'} asset="vampire.png" />
      </Stack.Item>
      <Stack.Item grow maxHeight="220px">
        <ObjectivesSection objectives={objectives} />
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

const VampireGuide = (_props) => {
  const { data } = useBackend<VampireInformation>();
  const { clan } = data;

  const [tab, setTab] = useLocalState('guideTab', 1);

  // small vertical padding for each tab; tweak values as desired
  const guideTabStyle = { paddingTop: '10px', paddingBottom: '10px' } as const;

  return (
    <Section title="Przewodnik wampira">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab
              icon="list"
              selected={tab === 1}
              onClick={() => setTab(1)}
              style={guideTabStyle}
            >
              Podstawy
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 2}
              onClick={() => setTab(2)}
              style={guideTabStyle}
            >
              Maskarada
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 3}
              onClick={() => setTab(3)}
              style={guideTabStyle}
            >
              Człowieczeństwo
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 4}
              onClick={() => setTab(4)}
              style={guideTabStyle}
            >
              Książęta i społeczność
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 5}
              onClick={() => setTab(5)}
              style={guideTabStyle}
            >
              Sol i awanse
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 6}
              onClick={() => setTab(6)}
              style={guideTabStyle}
            >
              Vitae
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 7}
              onClick={() => setTab(7)}
              style={guideTabStyle}
            >
              Walka
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 8}
              onClick={() => setTab(8)}
              style={guideTabStyle}
            >
              Twoje legowisko
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 9}
              onClick={() => setTab(9)}
              style={guideTabStyle}
            >
              Struktury
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 10}
              onClick={() => setTab(10)}
              style={guideTabStyle}
            >
              Wasale
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
          {tab === 1 && (
            // The Basics
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Więc jesteś groźnym wampirem. Gratulacje.
              </Box>
              <Box fontSize="26px" textColor="red" bold>
                A teraz zachowaj to dla siebie.
              </Box>
              <Box align="right" fontSize="10px" textColor="grey">
                - „Uśmiechnięty” Jack, Los Angeles, ok. 2001-2008.
              </Box>
              <br />
              Wampiry przetrwały, bo śmiertelnicy uważają je za mit. To właśnie{' '}
              <Box inline textColor="gold">
                Maskarada
              </Box>
              . Wilk nie chce, żeby owce wiedziały, że tu jest. Tyle że te owce
              mają broń.
              <Box inline fontSize="14px" textColor="red" bold>
                {' '}
                <i>Musisz</i> pozostać w ukryciu.
              </Box>
              <br />
              <br />
              <Box fontSize="16px" textColor="gold" bold>
                Wtapianie się w tłum
              </Box>
              Jesteś martwy: nie oddychasz, serce ci nie bije i nie musisz jeść.
              To cię wyróżnia. Unikaj lekarzy, skanów zdrowia, a zwłaszcza{' '}
              <Box inline textColor="pink">
                kuratora
              </Box>
              . On wie, że wampiry istnieją, i może cię zdemaskować.
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Rada:</b> Masz niesamowite moce, ale ich używanie zwraca
                uwagę. Mądrzy Spokrewnieni wtapiają się w tłum, zachowując się
                jak śmiertelnicy. Użyj broni palnej zamiast pazurów. Chodź,
                zamiast skakać przez całe pomieszczenia. Zachowaj moce na
                chwile, gdy naprawdę ich potrzebujesz.
              </Box>
              <br />
              <Box fontSize="16px" textColor="green" bold>
                Pierwsze kroki
              </Box>
              Przyjrzyj się przez chwilę ekranowi. Widzisz te ikony po lewej? To
              twój wampirzy HUD. Każda ikona daje ci ważne informacje, więc
              przeklikaj je i dowiedz się, co pokazują.
              <br />
              <br />
              Następnym priorytetem powinno być znalezienie innego
              Spokrewnionego. Pomoże ci się wdrożyć i może wskazać miejscowego{' '}
              <Box inline textColor="red">
                Księcia
              </Box>
              .
              <br />
              <Box
                mt={1}
                style={{
                  border: '2px solid #ff4444',
                  borderRadius: '6px',
                  padding: '8px',
                  backgroundColor: 'rgba(255, 0, 0, 0.1)',
                }}
              >
                <Box fontSize="15px" textColor="red" bold textAlign="center">
                  ZASADA PRZETRWANIA NR 1
                </Box>
                <Box fontSize="18px" textColor="gold" bold textAlign="center">
                  Trzymaj vitae powyżej 300.
                </Box>
                <Box fontSize="12px" textAlign="center">
                  Głodny wampir to martwy wampir. Panika prowadzi do błędów.
                </Box>
                <Box fontSize="11px" textColor="grey" textAlign="center">
                  Żeruj często. Żeruj mądrze. Przeżyj.
                </Box>
              </Box>
            </Box>
          )}
          {tab === 2 && (
            // The Masquerade
            <Box>
              <Box fontSize="18px" textColor="gold" bold>
                Maskarada
              </Box>
              <Box fontSize="13px" textColor="gold">
                Jak nie doprowadzić do tego, że wszyscy zginiemy.
              </Box>
              <br />
              <Box inline textColor="gold">
                Maskarada
              </Box>{' '}
              to zorganizowana kampania dezinformacyjna, której pilnuje
              społeczność{' '}
              <Box inline textColor="purple">
                Spokrewnionych
              </Box>{' '}
              (głównie{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>
              ), by przekonać ludzi, że wampiry nie istnieją.
              <br />
              <br />
              Jeśli śmiertelnik zobaczy coś podejrzanego, dostajesz{' '}
              <Box inline textColor="red">
                wykroczenie przeciw Maskaradzie
              </Box>
              . Po <b>trzech</b> zostajesz wygnany i{' '}
              <Box inline textColor="red" bold>
                WSZYSTKIE
              </Box>{' '}
              wampiry obracają się przeciwko tobie.
              <br />
              <br />
              <Box inline textColor="pink">
                Kurator
              </Box>{' '}
              ma{' '}
              <Box inline textColor="blue">
                Archiwum Spokrewnionych
              </Box>
              , które może cię natychmiast zdemaskować. Jeśli jednak masz
              aktywną{' '}
              <Box inline textColor="gold">
                moc Maskarady
              </Box>
              , nawet ta pradawna księga nie przejrzy twojego przebrania.
              <br />
              <br />
              Przy{' '}
              <Box inline textColor="blue">
                Człowieczeństwie
              </Box>{' '}
              powyżej 7 zyskujesz{' '}
              <Box inline textColor="gold">
                moc Maskarady
              </Box>
              , która oszukuje analizatory zdrowia i{' '}
              <Box inline textColor="pink">
                kuratora
              </Box>
              .{' '}
              <b>Gdy jest aktywna, nie leczysz się jednak w normalny sposób.</b>
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Rada:</b> Zbyt wielu pacjentów z utratą krwi w medbayu jest
                równie podejrzane jak wykrwawione zwłoki na korytarzu.
              </Box>
              <br />
              <Box fontSize="16px" textColor="red" bold>
                Złamałem Maskaradę. Co teraz?
              </Box>
              <Box fontSize="13px">
                • Wszyscy na ciebie polują, wampiry bardziej niż śmiertelnicy
                <br />
                • Twoi wasale są do wzięcia
                <br />
                • Inne wampiry mogą się tobą żywić
                <br />• <b>Wyssanie innego wampira daje ci jego moce</b>
                <br />• Na litość jest już za późno
              </Box>
            </Box>
          )}
          {tab === 3 && (
            // Humanity
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Człowieczeństwo
              </Box>
              <Box fontSize="13px" textColor="blue">
                Czy jesteśmy ludźmi? Czy tancerzami?
              </Box>
              <br />
              Większość{' '}
              <Box inline textColor="purple">
                Spokrewnionych
              </Box>{' '}
              była ludźmi przed Przeistoczeniem. Kurczowe trzymanie się{' '}
              <Box inline textColor="blue">
                Człowieczeństwa
              </Box>{' '}
              to ich sposób na opieranie się dzikiej naturze{' '}
              <Box inline textColor="orange">
                Bestii
              </Box>
              .
              <br />
              <br />
              Twoje{' '}
              <Box inline textColor="blue">
                Człowieczeństwo
              </Box>{' '}
              bezpośrednio wpływa na wampirzą klątwę. Niższe{' '}
              <Box inline textColor="blue">
                Człowieczeństwo
              </Box>{' '}
              oznacza:
              <br />
              <Box fontSize="13px" ml={1}>
                • Trudniejszy kontakt ze śmiertelnikami
                <br />
                • Trudność z pozostaniem aktywnym za dnia
                <br />• Dłuższe wychodzenie z{' '}
                <Box inline textColor="orange">
                  torporu
                </Box>
              </Box>
              <br />
              <Box
                fontSize="13px"
                textColor="gold"
                style={{
                  borderLeft: '2px solid #ffd700',
                  paddingLeft: '8px',
                }}
              >
                Kliknij licznik Człowieczeństwa na HUD-zie, by zobaczyć
                szczegóły.
              </Box>
              <br />
              Czemu nazywać to{' '}
              <Box inline textColor="blue">
                Człowieczeństwem
              </Box>
              , skoro nie wszyscy{' '}
              <Box inline textColor="purple">
                Spokrewnieni
              </Box>{' '}
              byli ludźmi? To proste: tradycja. Wielowiekowe wampiry niechętnie
              zmieniają swoje zwyczaje.
            </Box>
          )}
          {tab === 4 && (
            // Society
            <Box>
              <Box fontSize="18px" textColor="darkred" bold>
                Książęta i Bicze
              </Box>
              <br />
              <Box inline textColor="red">
                Książę
              </Box>{' '}
              to starszy wampir, któremu{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              powierzyła władzę nad terytorium. Śledzi każdego obecnego{' '}
              <Box inline textColor="purple">
                Spokrewnionego
              </Box>{' '}
              i żelazną ręką pilnuje{' '}
              <Box inline textColor="gold">
                Maskarady
              </Box>
              .
              <br />
              <br />
              Oczywiście nie działa sam. Wielu{' '}
              <Box inline textColor="red">
                Książąt
              </Box>{' '}
              zatrudnia{' '}
              <Box inline textColor="red">
                Bicza
              </Box>
              , osobistego egzekutora lojalnego tylko wobec nich. Bicze często
              wybiera się spośród klanów takich jak Tremere, choć zdarzali się
              rzadcy{' '}
              <Box inline textColor="red">
                Książęta
              </Box>
              , którzy zatrudniali nawet Brujah.
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Ważne:</b> Wobec Książąt oczekiwania są wyższe. Muszą za
                wszelką cenę chronić Maskaradę i bez wahania zsyłać Ostateczną
                Śmierć na niesfornych Spokrewnionych.
              </Box>
              <br />
              <Box fontSize="18px" textColor="purple" bold>
                Camarilla
              </Box>
              <br />
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              to najlepiej zorganizowana wampirza sekta: elitarny klub, który
              ceni tradycję i potajemne sterowanie śmiertelnikami zza kulis.
              Należy do niej większość wampirzych klanów, choć{' '}
              <Box inline textColor="orange">
                Brujah wyraźnie upierają się przy niezależności
              </Box>
              .
              <br />
              <br />
              Każde miasto, stacja, kolonia czy placówka, gdzie przebywają{' '}
              <Box inline textColor="purple">
                Spokrewnieni
              </Box>
              , ma{' '}
              <Box inline textColor="red">
                Księcia
              </Box>{' '}
              wyznaczonego przez{' '}
              <Box inline textColor="purple">
                Camarillę
              </Box>{' '}
              do nadzoru. To główni stróże{' '}
              <Box inline textColor="gold">
                Maskarady
              </Box>
              .
            </Box>
          )}
          {tab === 5 && (
            // Sol
            <Box>
              <Box fontSize="32px" textColor="orange" bold>
                Sol
              </Box>
              <Box inline textColor="yellow">
                Sol
              </Box>{' '}
              to pobliska kapryśna gwiazda, a nie ziemskie Słońce. Wampirom w
              kosmosie wiedzie się dobrze. Po prostu masz pecha być blisko tej
              jednej.
              <br />
              <br />
              <Box fontSize="14px" bold>
                Najważniejsze fakty
              </Box>
              <Box fontSize="13px">
                • Kliknij ikonę na HUD-zie, by zobaczyć więcej szczegółów
                <br />
                • Sol cię nie zabije, jeśli chronią cię szafki, tunele
                techniczne albo trumny
                <br />
                • Jeśli Sol zastanie cię bez ochrony, spłoniesz na popiół
                <br />• Wyższe Człowieczeństwo daje częściową odporność na
                działanie Sol
              </Box>
              <br />
              <Box fontSize="14px" bold textColor="red">
                W czasie Sol
              </Box>
              <Box fontSize="13px">
                • Nie leczysz się biernie; uleczyć cię może tylko trumna
                <br />
                • Otrzymujesz o 50% więcej obrażeń ze wszystkich źródeł
                <br />• Twoje moce mają podwojone odnowienie, wyższy koszt
                vitae, a niektóre są całkiem zablokowane
              </Box>
              <br />
              <Box fontSize="16px" textColor="darkred" bold>
                Rośnięcie w siłę
              </Box>
              Jako wampir z czasem stajesz się silniejszy, spełniając wymagania
              żerowania. Kliknij licznik krwi na HUD-zie, by zobaczyć postęp do
              następnej rangi.
              <br />
              <br />
              Po każdym cyklu Sol, jeśli wypiłeś dość vitae, by osiągnąć cel,
              zdobywasz rangę. Każda ranga daje znaczne korzyści:
              <Box fontSize="13px" ml={1}>
                • Większa siła fizyczna
                <br />
                • Więcej zdrowia
                <br />
                • Szybsze żerowanie
                <br />
                • Większa pojemność krwi
                <br />• Dodatkowe punkty dyscyplin do odblokowania nowych mocy
              </Box>
            </Box>
          )}
          {tab === 6 && (
            // Vitae
            <Box>
              <Box fontSize="18px" textColor="red" bold>
                Vitae
              </Box>
              <br />
              <Box inline textColor="red">
                Vitae
              </Box>{' '}
              to krew życia, która podtrzymuje każdego wampira.{' '}
              <Box inline textColor="orange">
                Bestia
              </Box>{' '}
              w tobie żąda nieustannego żerowania i zignorowanie tej potrzeby
              nie wchodzi w grę. Gdy twoje zapasy krwi spadną do zera, czeka cię
              rozmyty wzrok, osłabione leczenie i znacznie gorsze konsekwencje.
              <br />
              <br />
              Twoja obecna ranga decyduje, ile{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              możesz przechowywać i wykorzystywać naraz.
              <br />
              <br />
              <Box bold>
                Źródła{' '}
                <Box inline textColor="red">
                  vitae
                </Box>
                :
              </Box>
              <Box fontSize="13px">
                • Członkowie załogi
                <br />
                • Małpy
                <br />
                • Myszy
                <br />• Worki z krwią
              </Box>
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Rada:</b> Regularnie żeruj na załodze. Myszy i małpy nie
                utrzymają cię na dłuższą metę.
              </Box>
              <br />
              <Box fontSize="16px" textColor="orange" bold>
                Szał
              </Box>
              Gdy twoje{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              całkiem się wyczerpie, tracisz kontrolę i wpadasz w stan zwany{' '}
              <Box inline textColor="orange">
                Szałem
              </Box>
              . W tym dzikim stanie{' '}
              <Box inline textColor="orange">
                Bestia
              </Box>{' '}
              przejmuje kontrolę i zmusza cię, byś bez wahania zaatakował
              najbliższego śmiertelnika.
              <br />
              <br />W{' '}
              <Box inline textColor="orange">
                Szale
              </Box>{' '}
              możesz natychmiast chwytać ofiary, co czyni cię niezwykle
              niebezpiecznym, ale też bardzo rzucającym się w oczy. Jedynym
              sposobem na odzyskanie kontroli jest żerowanie, dopóki nie
              zgromadzisz dość{' '}
              <Box inline textColor="red">
                vitae
              </Box>
              , by stłumić{' '}
              <Box inline textColor="orange">
                Bestię
              </Box>
              .
              <br />
              <br />
              <Box fontSize="16px" textColor="blue" bold>
                Moce i vitae
              </Box>
              Wszystkie twoje wampirze moce wymagają{' '}
              <Box inline textColor="red">
                vitae
              </Box>
              . Niektóre zdolności wysysają krew nieprzerwanie, dopóki są
              aktywne, inne mają jednorazowy koszt przy aktywacji. Szczegółowe
              koszty i opisy każdej zdolności znajdziesz w zakładce Moce.
            </Box>
          )}
          {tab === 7 && (
            // Combat
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Walka
              </Box>
              <br />
              Jako wampir masz w walce znaczne przewagi, ale też krytyczne
              słabości, które można wykorzystać.
              <br />
              <br />
              <Box fontSize="15px" textColor="green" bold>
                Mocne strony
              </Box>
              <Box fontSize="13px">
                <b>Wyostrzone zmysły:</b> Widzenie w ciemności i termowizja
                pozwalają ci tropić ofiary w zupełnych ciemnościach.
                <br />
                <br />
                <b>Fizjologia nieumarłego:</b> Nie musisz oddychać, spać ani
                jeść. Jesteś odporny na choroby. Śmiertelne rany wprowadzają cię
                w{' '}
                <Box inline textColor="orange">
                  torpor
                </Box>{' '}
                zamiast cię zabić. Powstaniesz ponownie, jeśli masz{' '}
                <Box inline textColor="red">
                  vitae
                </Box>{' '}
                i nie tkwi w tobie kołek.
                <br />
                <br />
                <b>Wytrzymałość:</b> Odporność na zimno, promieniowanie i
                toksyny. Krytyczne obrażenia cię nie przewracają.
                <br />
                <br />
                <b>Nadprzyrodzona siła:</b> Twoje pięści zadają niszczycielskie
                obrażenia, rosnące wraz z rangą.
              </Box>
              <br />
              <Box fontSize="15px" textColor="red" bold>
                Słabości
              </Box>
              <Box fontSize="13px">
                <b>Kołki:</b> Paraliżują cię, wyłączają moce, wstrzymują
                leczenie i uniemożliwiają powrót z{' '}
                <Box inline textColor="orange">
                  torporu
                </Box>
                .
                <br />
                <br />
                <b>Ogień i lasery:</b> Zadają niszczycielskie obrażenia. Hart
                daje minimalną ochronę.
                <br />
                <br />
                <b>Sol:</b> Co dziesięć minut światło słoneczne cię okalecza,
                chyba że chroni cię trumna albo podobne schronienie.
                <br />
                <br />
                <b>Maskarada:</b> Złam ją, a każdy wampir obróci się przeciwko
                tobie. Będą na ciebie polować zarówno Spokrewnieni, jak i
                śmiertelnicy.
              </Box>
            </Box>
          )}
          {tab === 8 && (
            // Lairs
            <Box>
              <Box fontSize="18px" textColor="green" bold>
                Twoje legowisko
              </Box>
              <br />
              <Box inline textColor="green">
                Legowisko
              </Box>{' '}
              to miejsce, które zająłeś na własność, gdzie możesz odpoczywać w
              trumnie i odprawiać niektóre wampirze rytuały. Niektórym wampirom
              się przydaje. O wiele więcej wpadło właśnie przez nie.
              <br />
              <br />
              <Box bold>
                Czy potrzebujesz{' '}
                <Box inline textColor="green">
                  legowiska
                </Box>
                ?
              </Box>
              <Box fontSize="13px">
                Szczerze? Raczej nie.{' '}
                <Box inline textColor="green">
                  Legowisko
                </Box>{' '}
                jest potrzebne tylko wtedy, gdy chcesz tworzyć{' '}
                <Box inline textColor="purple">
                  wasali
                </Box>{' '}
                albo używać niektórych struktur. Jeśli potrzebujesz tylko
                kryjówki na czas{' '}
                <Box inline textColor="yellow">
                  Sol
                </Box>
                , wystarczy dowolny ciemny kąt z szafką. Im więcej
                infrastruktury zbudujesz, tym więcej dowodów zostawisz.
              </Box>
              <br />
              <Box bold>
                Zajmowanie{' '}
                <Box inline textColor="green">
                  legowiska
                </Box>
              </Box>
              <Box fontSize="13px">
                Jeśli nadal go chcesz: zdobądź trumnę z kaplicy albo zrób ją w
                kategorii Meble. Znajdź miejsce <i>naprawdę ukryte</i>, postaw
                trumnę i odpocznij w niej, by zająć ten obszar. Potem możesz
                przytwierdzać wampirze struktury, takie jak{' '}
                <Box inline textColor="purple">
                  stół do tortur
                </Box>{' '}
                czy{' '}
                <Box inline textColor="darkred">
                  tron krwi
                </Box>
                .
              </Box>
              <br />
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Uwaga:</b> Tunele techniczne to pierwsze miejsce, gdzie
                ludzie szukają. Jeśli ktoś znajdzie twoje legowisko, znajdzie
                wszystko: trumnę, struktury, wasali i ciebie.
              </Box>
            </Box>
          )}
          {tab === 9 && (
            // Structures
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Struktury
              </Box>
              <Box fontSize="13px" textColor="blue">
                Można je zbudować w wampirzej zakładce craftingu.
              </Box>
              <br />
              <Box textColor="purple" bold>
                Stół do tortur
              </Box>
              <Box fontSize="13px">
                Stół do tortur to twoje narzędzie do przemiany pojmanych
                członków załogi w lojalnych{' '}
                <Box inline textColor="purple">
                  wasali
                </Box>
                , którzy wykonają każdy twój rozkaz.
                <br />
                <br />
                <b>Użycie:</b> Przytwierdź stół w swoim{' '}
                <Box inline textColor="green">
                  legowisku
                </Box>{' '}
                → skrępuj cel → przeciągnij go na stół → kliknij stół, by
                rozpocząć tortury.
                <br />
                <br />
                Możesz znacznie przyspieszyć przemianę, używając na skrępowanej
                ofierze{' '}
                <Box inline textColor="red">
                  ostrych narzędzi
                </Box>
                .
              </Box>
              <br />
              <Box fontSize="13px">
                Członkom załogi z{' '}
                <Box inline textColor="blue">
                  mindshieldem
                </Box>{' '}
                albo silną lojalnością trzeba najpierw osłabić obronę
                psychiczną.{' '}
                <Box inline textColor="purple">
                  Słudzy nadprzyrodzonych sił
                </Box>{' '}
                są całkowicie odporni i nigdy nie dadzą się przemienić.
              </Box>
              <br />
              <Box textColor="yellow" bold>
                Kandelabr
              </Box>
              <Box fontSize="13px">
                Wampirzy kandelabr, który roztacza niepokojącą aurę. Każdy
                śmiertelnik, który zapatrzy się w jego{' '}
                <Box inline textColor="orange">
                  płomień
                </Box>
                , będzie powoli tracił zdrowe zmysły.
              </Box>
              <br />
              <Box textColor="darkred" bold>
                Tron krwi
              </Box>
              <Box fontSize="13px">
                Gdy zasiadasz na tronie krwi, twoje słowa trafiają telepatycznie
                do wszystkich{' '}
                <Box inline textColor="purple">
                  Spokrewnionych
                </Box>{' '}
                na stacji. Inne wampiry potrzebują własnego tronu, jeśli chcą
                odpowiedzieć.
              </Box>
            </Box>
          )}
          {tab === 10 && (
            // Vassals
            <Box>
              <Box fontSize="18px" textColor="purple" bold>
                Wasale
              </Box>
              <br />
              <Box inline textColor="purple">
                Wasale
              </Box>{' '}
              to śmiertelnicy, których złamano i związano z twoją wolą. Są
              twoimi oczami, uszami i rękami wśród żywych i wykonują twoje
              rozkazy, gdy ty pozostajesz ukryty w cieniu.
              <br />
              <br />
              <Box bold>Tworzenie wasali</Box>
              <Box fontSize="13px">
                Do stworzenia wasala potrzebujesz{' '}
                <Box inline textColor="purple">
                  stołu do tortur
                </Box>{' '}
                przytwierdzonego w swoim{' '}
                <Box inline textColor="green">
                  legowisku
                </Box>
                . Pojmij cel i skrępuj go, żeby nie uciekł, a potem przeciągnij
                go na stół. Kliknij stół, by rozpocząć{' '}
                <Box inline textColor="red">
                  tortury
                </Box>
                , które złamią jego wolę i zwiążą go z tobą.
                <br />
                <br />
                Używanie{' '}
                <Box inline textColor="red">
                  ostrych narzędzi
                </Box>{' '}
                na skrępowanej ofierze znacznie przyspiesza ten proces.
              </Box>
              <br />
              <Box bold>Ograniczenia</Box>
              <Box fontSize="13px">
                Członków załogi chronionych{' '}
                <Box inline textColor="blue">
                  mindshieldem
                </Box>{' '}
                albo silnie lojalnych nie da się przemienić, dopóki ich obrona
                psychiczna nie zostanie osłabiona. Ci, którzy służą{' '}
                <Box inline textColor="purple">
                  nadprzyrodzonym siłom
                </Box>
                , są całkowicie odporni i nigdy nie dadzą się przeciągnąć.
                <br />
                <br />
                Gdy ktoś zostanie twoim wasalem, jedynym sposobem na jego
                uwolnienie jest wszczepienie{' '}
                <Box inline textColor="blue">
                  mindshielda
                </Box>
                .
              </Box>
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PowerSection = (_props) => {
  const { data } = useBackend<VampireInformation>();
  const { powers } = data;
  if (!powers) {
    return <Section minHeight="220px" />;
  }

  const [tab, setTab] = useLocalState('powerTab', 0);
  return (
    <Section title="Moce">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            {powers.map((power, index) => (
              <Tabs.Tab
                key={index}
                selected={tab === index}
                onClick={() => setTab(index)}
              >
                <Stack align="center">
                  <Stack.Item>
                    <DmIcon
                      inline
                      icon={power.icon}
                      icon_state={power.icon_state}
                      fallback={
                        <Icon mr={1} name="spinner" spin fontSize="30px" />
                      }
                      width="32px"
                      style={{
                        imageRendering: 'pixelated',
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>{power.name}</Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          {powers.map(
            (power, index) =>
              tab === index && (
                <Box key={index}>
                  <Box inline bold textColor="red">
                    {power.cost !== '0' && <>KOSZT KRWI: {power.cost}</>}
                    {power.cost !== '0' && power.constant_cost !== '0' && (
                      <br />
                    )}
                    {power.constant_cost !== '0' && (
                      <>KOSZT STAŁY: {power.constant_cost}</>
                    )}
                    {(power.cost !== '0' || power.constant_cost !== '0') &&
                      Number(power.cooldown) !== 0 && (
                        <>
                          <br />
                          <br />
                        </>
                      )}
                    {Number(power.cooldown) !== 0 && (
                      <>
                        ODNOWIENIE: {power.cooldown} s
                        <br />
                        <br />
                      </>
                    )}
                  </Box>
                  <Box
                    style={{ whiteSpace: 'pre-wrap', lineHeight: '1' }}
                    dangerouslySetInnerHTML={{
                      __html: sanitizeText(
                        power.explanation.replace(/\n/g, '\n\n'),
                      ),
                    }}
                  />
                </Box>
              ),
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ClanSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section title="Klan">
        <Stack vertical>
          <Stack.Item fontSize="20px">
            <Box inline textColor="red">
              Nie należysz do żadnego klanu!
            </Box>
          </Stack.Item>
          <Stack.Item>Aby wybrać klan, użyj mocy Wybór klanu.</Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Section title="Klan">
      {clan.map((ClanInfo, index) => (
        <Stack key={index}>
          <Stack.Item>
            <DmIcon
              icon={ClanInfo.icon}
              icon_state={ClanInfo.icon_state}
              fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
              width="128px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack.Item textAlign="center">
              <Box inline fontSize="20px" textColor="red">
                Należysz do: <b>{ClanInfo.name}!</b>
              </Box>
            </Stack.Item>
            <Box
              fontSize="16px"
              dangerouslySetInnerHTML={{ __html: ClanInfo.description }}
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

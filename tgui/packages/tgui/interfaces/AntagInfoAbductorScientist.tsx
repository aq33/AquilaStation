import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { BlockQuote, Box, Image, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  members: string[];
  mothership: string;
  objectives: Objective[];
};

const IntroSection = (_props) => {
  const { data } = useBackend<Info>();
  const { mothership } = data;
  return (
    <Stack>
      <Stack.Item>
        <Image
          src={resolveAsset('ayylmao.png')}
          width="64px"
          style={{
            imageRendering: 'pixelated',
          }}
        />
      </Stack.Item>
      <Stack.Item grow>
        <h1 style={{ position: 'relative', top: '25%', left: '-2%' }}>
          Jesteś{' '}
          <Box inline textColor="blue">
            naukowcem
          </Box>{' '}
          <Box inline textColor="purple">
            porywaczy
          </Box>{' '}
          ze statku{' '}
          <Box inline textColor="purple">
            {mothership}
          </Box>
          !
        </h1>
      </Stack.Item>
    </Stack>
  );
};

const BasicLoreSection = (_props) => {
  return (
    <Section>
      <BlockQuote>
        Jesteś{' '}
        <Box inline textColor="blue">
          naukowcem
        </Box>{' '}
        w tej drużynie porywaczy!
        <br />
        Jesteś <b>mózgiem</b> porywaczy: razem ze swoim{' '}
        <Box inline textColor="red">
          agentem
        </Box>{' '}
        łapiesz obiekty badań i przywozisz je na statek na eksperymenty!
        <br />
        Jako porywacz masz telepatyczną więź z partnerem i nie możesz
        porozumiewać się słowami.
      </BlockQuote>
    </Section>
  );
};

const SurgerySubsection = (_props) => {
  return (
    <Section title="Eksperymenty">
      Gdy uda ci się porwać cel na statek-matkę, przeprowadzasz na nim operację{' '}
      <Box inline textColor="purple">
        eksperymentalnej wymiany organów
      </Box>
      . Nie musisz rozbierać celu, a operacja składa się z kroków:
      <br />
      <b>1.</b>: Celując w klatkę piersiową, kliknij obiekt{' '}
      <Box inline textColor="blue">
        serwetą chirurgiczną
      </Box>{' '}
      i wybierz{' '}
      <Box inline textColor="purple">
        eksperymentalną manipulację organami
      </Box>
      .
      <br />
      <b>2.</b>: Natnij obiekt{' '}
      <Box inline textColor="blue">
        skalpelem
      </Box>
      .
      <br />
      <b>3.</b>: Zaciśnij krwawiące naczynia{' '}
      <Box inline textColor="blue">
        hemostatem
      </Box>
      .
      <br />
      <b>4.</b>: Odciągnij skórę obiektu{' '}
      <Box inline textColor="blue">
        retraktorem
      </Box>
      .
      <br />
      <b>5.</b>: Natnij obiekt drugi raz{' '}
      <Box inline textColor="blue">
        skalpelem
      </Box>
      .
      <br />
      <b>6.</b>: Wyjmij organy obiektu{' '}
      <Box inline textColor="blue">
        pustą ręką
      </Box>
      .
      <br />
      <b>7.</b>: Włóż obiektowi eksperymentalny{' '}
      <Box inline textColor="blue">
        organ obcych
      </Box>
      .
      <br />
      <b>8.</b>: Przeciągnij cel do{' '}
      <Box inline textColor="purple">
        maszyny eksperymentalnej
      </Box>{' '}
      (najpierw odepnij go od stołu operacyjnego). W środku wybierz badanie,
      analizę albo sekcję.
    </Section>
  );
};

const EquipmentSection = (_props) => {
  return (
    <Section title="Wyposażenie">
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Image
                src={resolveAsset('scitool.png')}
                width="32px"
                style={{
                  imageRendering: 'pixelated',
                }}
              />
              Twoje{' '}
              <Box inline textColor="purple">
                narzędzie naukowe
              </Box>{' '}
              jest niezbędne do porywania obiektów badań! Ma dwa tryby:
              <br />
              <Box inline textColor="blue">
                Oznaczanie
              </Box>
              : oznacza obiekt, żeby konsola kamer mogła go teleportować. Agenta
              oznaczysz natychmiast z każdej odległości (nawet przez kamery),
              ale obiekty badań musisz oznaczyć osobiście, po teleportacji na
              dół!
              <br />
              <Box inline textColor="red">
                Skanowanie
              </Box>
              : skanuje kogoś i dodaje jego wygląd do możliwych przebrań twojego
              agenta. Działa przez kamery.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Image
                src={resolveAsset('atool.png')}
                width="32px"
                style={{
                  imageRendering: 'pixelated',
                }}
              />
              Masz{' '}
              <Box inline textColor="purple">
                obce narzędzia chirurgiczne
              </Box>
              , które działają niezwykle szybko, szybciej niż jakiekolwiek
              narzędzia niższych form życia.
              <br />
              Są niezbędne do eksperymentalnych operacji na porwanych obiektach
              badań!
              <br />
              Możesz też przeprowadzać inne zaawansowane operacje, na przykład{' '}
              <Box inline textColor="purple">
                pranie mózgu
              </Box>{' '}
              albo{' '}
              <Box inline textColor="green">
                opatrywanie ran najwyższego poziomu
              </Box>
              .
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <SurgerySubsection />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoAbductorScientist = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={620} height={620} theme="abductor">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item>
            <BasicLoreSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
          <Stack.Item>
            <EquipmentSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

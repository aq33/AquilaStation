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
          <Box inline textColor="red">
            agentem
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
        <Box inline textColor="red">
          agentem
        </Box>{' '}
        w tej drużynie porywaczy!
        <br />
        Jesteś <b>siłą</b> porywaczy: razem ze swoim{' '}
        <Box inline textColor="blue">
          naukowcem
        </Box>{' '}
        łapiesz obiekty badań i przywozisz je na statek!
        <br />
        Jako porywacz masz telepatyczną więź z partnerem i nie możesz
        porozumiewać się słowami.
      </BlockQuote>
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
                src={resolveAsset('abaton.png')}
                width="32px"
                style={{
                  imageRendering: 'pixelated',
                }}
              />
              Twoja{' '}
              <Box inline textColor="purple">
                zaawansowana pałka
              </Box>{' '}
              to wielofunkcyjna pałka, która robi niemal wszystko, czego
              potrzebujesz do obezwładnienia kogoś. Ma cztery tryby:
              <br />
              <Box inline textColor="yellow">
                Ogłuszenie
              </Box>
              : ogłusza każdego, kogo uderzysz.
              <br />
              <Box inline textColor="blue">
                Uśpienie
              </Box>
              : usypia ogłuszoną osobę. Naraz może spać tylko jedna osoba!
              <br />
              <Box inline textColor="red">
                Skucie
              </Box>
              : skuwa kogoś kajdankami z twardego światła.
              <br />
              <Box inline textColor="purple">
                Badanie
              </Box>
              : sprawdza, czy organizm nadaje się do eksperymentów.
              <br />
              Osoby w{' '}
              <Box inline textColor="label">
                czapeczkach z folii aluminiowej
              </Box>{' '}
              są jednak odporne na działanie pałki.
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
                obce narzędzia
              </Box>
              , które działają niezwykle szybko, szybciej niż jakiekolwiek
              narzędzia niższych form życia.
              <br />
              Możesz nimi na przykład{' '}
              <Box inline textColor="yellow">
                hakować maszyny
              </Box>{' '}
              albo{' '}
              <Box inline textColor="orange">
                zaspawać drzwi
              </Box>
              .
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack.Item>
            <Image
              src={resolveAsset('apistol.png')}
              width="32px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
            Twój{' '}
            <Box inline textColor="purple">
              obcy pistolet
            </Box>{' '}
            to skuteczna broń do samoobrony z trzema trybami ognia:
            <br />
            <Box inline textColor="green">
              Rozklonowanie
            </Box>
            : zadaje 20 obrażeń komórkowych trafionemu celowi.
            <br />
            <Box inline textColor="blue">
              Jony
            </Box>
            : trafia cel impulsem EMP.
            <br />
            <Box inline textColor="teal">
              Zamrożenie
            </Box>
            : obniża temperaturę trafionego celu.
          </Stack.Item>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoAbductorAgent = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Window width={620} height={650} theme="abductor">
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

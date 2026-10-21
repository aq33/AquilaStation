import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

// AQUILA: zostaje nasz układ (lista wiedzy z Bee) - okno z tg wymaga drzewa wiedzy,
// ścieżek i pasywek, których nasz heretyk nie wysyła

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type Knowledge = {
  path: string;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  disabled: boolean;
  hereticPath: string;
  color: string;
};

type KnowledgeInfo = {
  learnableKnowledge: Knowledge[];
  learnedKnowledge: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
};

const IntroductionSection = () => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="Jesteś Heretykiem!" fill scrollable fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />

            <GuideSection />
            <Stack.Divider />

            <InformationSection />
            <Stack.Divider />

            <Stack.Item>
              <ObjectivePrintout
                fill
                titleMessage="Aby dostąpić wniebowstąpienia, musisz wykonać te zadania"
                objectives={objectives}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px" width="100%">
        <Stack.Item>
          <i>
            Kolejny dzień w bezsensownej pracy. Czujesz wokół siebie&nbsp;
            <span style={hereticBlue}>migotanie</span>
            &nbsp;i dociera do ciebie, że w powietrzu wisi coś&nbsp;
            <span style={hereticRed}>dziwnego</span>. Zaglądasz w głąb siebie i
            odkrywasz coś, co odmieni twoje życie.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            <span style={hereticPurple}>Wrota Mansusa</span>
            &nbsp;otwierają się przed twoim umysłem.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px" width="100%">
        <Stack.Item>
          - Szukaj na stacji niewidocznych dla zwykłego oka&nbsp;
          <span style={hereticPurple}>wpływów</span>, które kruszą
          rzeczywistość, i zbieraj je <b>lewym kliknięciem</b>, aby zdobyć&nbsp;
          <span style={hereticBlue}>punkty wiedzy</span>. Chwilę po zebraniu
          wpływ staje się widoczny dla wszystkich.
        </Stack.Item>
        <Stack.Item>
          - Akcją&nbsp;
          <span style={hereticRed}>Żywego Serca</span>
          &nbsp;tropisz&nbsp;
          <span style={hereticRed}>cele ofiarne</span>, ale uważaj: każde
          pulsowanie wydaje dźwięk bicia serca, który mogą usłyszeć osoby w
          pobliżu. Ta akcja jest związana z twoim <b>sercem</b> - jeśli je
          stracisz, musisz odprawić rytuał, aby ją odzyskać.
        </Stack.Item>
        <Stack.Item>
          - Narysuj&nbsp;
          <span style={hereticGreen}>runę transmutacji</span>, używając na
          podłodze przyboru do pisania (długopisu lub kredki), gdy w drugiej
          ręce masz aktywny&nbsp;
          <span style={hereticGreen}>Uchwyt Mansusa</span>. Na tej runie
          odprawiasz rytuały i składasz ofiary.
        </Stack.Item>
        <Stack.Item>
          - Idź za <span style={hereticRed}>Żywym Sercem</span>, aby znaleźć
          swoje cele. Zanieś je na&nbsp;
          <span style={hereticGreen}>runę transmutacji</span> i&nbsp;
          <span style={hereticRed}>złóż w ofierze</span> za&nbsp;
          <span style={hereticBlue}>punkty wiedzy</span>. Mansus przyjmuje{' '}
          <b>WYŁĄCZNIE</b> cele wskazane przez&nbsp;
          <span style={hereticRed}>Żywe Serce</span>.
        </Stack.Item>
        <Stack.Item>
          - Stwórz przedmiot, który posłuży jako&nbsp;
          <span style={hereticYellow}>fokus</span> dla twoich&nbsp;
          <span style={hereticGreen}>zaklęć</span>. Na start masz już
          zbadany&nbsp;
          <span style={hereticYellow}>Bursztynowy Fokus</span>, ale inna&nbsp;
          <span style={hereticBlue}>wiedza</span> może pozwolić ci&nbsp;
          <span style={hereticGreen}>przetransmutować</span> nowy&nbsp;
          <span style={hereticYellow}>fokus</span>.
        </Stack.Item>
        <Stack.Item>
          - Wykonaj wszystkie cele, aby móc poznać{' '}
          <span style={hereticYellow}>ostatni rytuał</span>. Odpraw go, aby stać
          się wszechmocnym!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props) => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>Dostąpiłeś</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  WNIEBOWSTĄPIENIA
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          <span style={hereticBlue}>Punkty wiedzy</span>: <b>{charges || 0}</b>
        </Stack.Item>
        <Stack.Item>
          <span style={hereticRed}>Złożone ofiary</span> łącznie:{' '}
          <b>{total_sacrifices || 0}</b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ResearchedKnowledge = (props) => {
  const { data } = useBackend<KnowledgeInfo>();
  const { learnedKnowledge = [] } = data;

  return (
    <Stack.Item grow>
      <Section title="Poznana wiedza" fill scrollable>
        <Stack vertical>
          {(!learnedKnowledge.length && 'Brak!') ||
            learnedKnowledge.map((learned) => (
              <Stack.Item key={learned.name}>
                <Button
                  width="100%"
                  color={learned.color}
                  tooltip={learned.desc}
                >
                  {`${learned.hereticPath} - ${learned.name}`}
                </Button>
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const KnowledgeShop = (props) => {
  const { data, act } = useBackend<KnowledgeInfo>();
  const { learnableKnowledge = [] } = data;

  return (
    <Stack.Item grow>
      <Section title="Wiedza do zdobycia" fill scrollable>
        {(!learnableKnowledge.length && 'Brak!') ||
          learnableKnowledge.map((toLearn) => (
            <Stack.Item key={toLearn.name} mb={1}>
              <Button
                width="100%"
                color={toLearn.color}
                disabled={toLearn.disabled}
                tooltip={toLearn.desc}
                onClick={() => act('research', { path: toLearn.path })}
              >
                {`${toLearn.hereticPath} - ${
                  toLearn.cost > 0
                    ? `${toLearn.name}: ${toLearn.cost} pkt`
                    : toLearn.name
                }`}
              </Button>
              {!!toLearn.gainFlavor && (
                <BlockQuote>
                  <i>{toLearn.gainFlavor}</i>
                </BlockQuote>
              )}
            </Stack.Item>
          ))}
      </Section>
    </Stack.Item>
  );
};

const ResearchInfo = (props) => {
  const { data } = useBackend<Info>();
  const { charges } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Stack vertical height="100%">
          <Stack.Item fontSize="20px" textAlign="center">
            <span style={hereticBlue}>Punkty wiedzy</span> do wydania:{' '}
            <b>{charges || 0}</b>
          </Stack.Item>
          <Stack.Item grow>
            <Stack height="100%">
              <ResearchedKnowledge />
              <KnowledgeShop />
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props) => {
  const { data } = useBackend<Info>();
  const { ascended } = data;

  const [currentTab, setTab] = useState(0);

  return (
    <Window width={675} height={600}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%)'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%)',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Informacje
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Badania
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || <ResearchInfo />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

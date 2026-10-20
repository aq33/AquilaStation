import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const chemstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

type Info = {
  true_name: string;
  objectives: Objective[];
  absorbed_dna: number;
  genetic_points: number;
};

// AQUILA: bez sekcji skradzionych wspomnień i umysłu roju z tg - nasz zmiennokształtny ich nie ma
export const AntagInfoChangeling = (props) => {
  return (
    <Window width={720} height={600}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item maxHeight={16}>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow>
            <AbilitiesSection />
          </Stack.Item>
          <BetrayalWarning />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { true_name, objectives, absorbed_dna, genetic_points } = data;
  return (
    <Section
      fill
      title="Wprowadzenie"
      style={{ overflowY: 'auto' }}
      buttons={
        <>
          <Button
            icon="flask"
            tooltipPosition="left"
            tooltip="Punkty genetyczne"
            color="green"
          >
            {genetic_points}
          </Button>
          <Button
            icon="dna"
            tooltipPosition="left"
            tooltip="Wchłonięte DNA"
            color="purple"
          >
            {absorbed_dna}
          </Button>
        </>
      }
    >
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          Jesteś <span style={absorbstyle}>{true_name}</span>, zmiennokształtny!
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout
            objectives={objectives}
            titleMessage="Twoje obecne cele"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = () => {
  return (
    <Section fill title="Zdolności">
      <Stack fill>
        <Stack.Item grow basis={0}>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Zdolność
              <span style={absorbstyle}>&ensp;Absorb DNA</span> pozwala ukraść
              ofierze DNA i wspomnienia. Daje też trochę chemikaliów i pozwala
              ponownie rozdać punkty genetyczne.
              <span style={absorbstyle}>&ensp;Extract DNA Sting</span> również
              kradnie DNA ofiary i jest niewykrywalne, ale nie daje jej
              wspomnień ani sposobu mówienia.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              Zdolność
              <span style={revivestyle}>&ensp;Reviving Stasis</span> pozwala ci
              powrócić do życia. Powstrzyma cię tylko całkowite zniszczenie
              ciała! To oczywiście głośne, więc nie rób tego przy ludziach,
              których nie zamierzasz uciszyć.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow basis={0}>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Zdolność
              <span style={transformstyle}>&ensp;Transform</span> pozwala
              przyjąć postać każdego, od kogo zebrałeś DNA, w sposób zabójczy
              lub nie. Naśladuje też (TO NIE PRAWDZIWE UBRANIA) ubrania, które
              nosił, na każdym wolnym miejscu.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              W<span style={storestyle}>&ensp;Komórkowym Emporium</span>{' '}
              kupujesz zdolności poza zestawem startowym. Masz na nie punkty
              genetyczne, a po wchłonięciu ciała możesz się przystosować na nowo
              i odzyskać punkty na inny zestaw.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow basis={0}>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Każda zdolność zużywa <span style={chemstyle}>chemikalia</span>.
              Ich zapas widzisz na HUD-zie po lewej stronie ekranu. Maksymalny
              zapas rośnie, gdy <span style={absorbstyle}>wchłaniasz</span>{' '}
              innych zmiennokształtnych.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BetrayalWarning = (props) => {
  return (
    <NoticeBox danger>
      Inni zmiennokształtni mogą być silnymi sojusznikami, ale niektórzy mogą
      cię zdradzić. Zmiennokształtni zyskują ogromną moc, wchłaniając sobie
      podobnych, a jeśli inny zmiennokształtny wchłonie ciebie, stracisz swoje
      moce, punkty genetyczne i chemikalia. Nie ma większego upokorzenia.
    </NoticeBox>
  );
};

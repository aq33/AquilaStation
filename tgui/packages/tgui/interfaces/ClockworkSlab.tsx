import { Fragment } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Divider,
  Icon,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

type Data = {
  cogs: any;
  power: any;
  recollection: any;
  scriptures: any;
  vitality: any;
};

export const convertPower = (power_in) => {
  const units = ['W', 'kW', 'MW', 'GW'];
  let power = 0;
  let value = power_in;
  while (value >= 1000 && power < units.length) {
    power++;
    value /= 1000;
  }
  return Math.round((value + Number.EPSILON) * 100) / 100 + units[power];
};

export const ClockworkSlab = (props) => {
  const { data } = useBackend<Data>();
  const { power } = data;
  const { recollection } = data;
  const [selectedTab, setSelectedTab] = useLocalState(
    'selectedTab',
    'Servitude',
  );
  return (
    <Window theme="clockwork" width={860} height={700}>
      <Window.Content>
        <Section
          title={
            <Box inline color={'good'}>
              <Icon name={'cog'} rotation={0} spin={1} />
              {' Mechaniczna płyta '}
              <Icon name={'cog'} rotation={35} spin={1} />
            </Box>
          }
        >
          <ClockworkButtonSelection />
        </Section>
        <div className="ClockSlab__left">
          <Section height="100%" overflowY="scroll">
            <ClockworkSpellList selectedTab={selectedTab} />
          </Section>
        </div>
        <div className="ClockSlab__right">
          <div className="ClockSlab__stats">
            <Section height="100%" scrollable overflowY="scroll">
              <ClockworkOverview />
            </Section>
          </div>
          <div className="ClockSlab__current">
            <Section
              height="100%"
              scrollable
              overflowY="scroll"
              title="Słudzy Zębatki, tom 1"
            >
              <ClockworkHelp />
            </Section>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

export const ClockworkHelp = (props) => {
  return (
    <>
      <Collapsible title="Od czego zacząć" color="average" open>
        <Section>
          Po długiej i niszczycielskiej wojnie Rat&#39;Var został uwięziony w
          wymiarze cierpienia.
          <br />
          Należysz do grupy jego ostatnich, najwierniejszych sług. <br />
          Masz bardzo mało mocy, a większość twoich pism nie działa.
          <br />
          <b>
            Użyj&nbsp;
            <span style={{ color: '#BD78C4' }}>
              ratvariańskich konsol obserwacyjnych&nbsp;
            </span>
            , żeby przenieść się na stację!
          </b>
          <br />
          <b>
            Montuj&nbsp;
            <span style={{ color: '#DFC69C' }}>zębatki integracyjne&nbsp;</span>
            , żeby odblokować więcej pism i wysysać energię!
          </b>
          <br />
          <b>
            Odblokuj&nbsp;
            <span style={{ color: '#D8D98D' }}>Rozpalenie&nbsp;</span>
            i&nbsp;
            <span style={{ color: '#F19096' }}>Nienawistne kajdany&nbsp;</span>
            oraz przywołaj&nbsp;
            <span style={{ color: '#9EA7E5' }}>pieczęć uległości&nbsp;</span>,
            żeby nawracać niewiernych!
          </b>
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Odblokowywanie pism" color="average">
        <Section>
          Większość pism do odblokowania wymaga <b>zębatek</b>.
          <br />
          Przywołaj pismo&nbsp;
          <span style={{ color: '#DFC69C' }}>
            <b>Zębatka integracyjna&nbsp;</b>
          </span>
          , żeby dostać zębatkę integracyjną, którą możesz włożyć do
          dowolnego&nbsp;
          <b>APC&nbsp;</b>
          na stacji.
          <br />
          Rozetnij&nbsp;
          <b>APC&nbsp;</b>
          za pomocą&nbsp;
          <b>zębatki integracyjnej&nbsp;</b>
          , a potem włóż ją do środka, żeby zacząć wysysać energię.
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Nawracanie" color="average">
        <Section>
          Przywołaj
          <b>
            <span style={{ color: '#D8D98D' }}>&nbsp;Rozpalenie&nbsp;</span>
          </b>
          (po odblokowaniu), żeby&nbsp;
          <b>ogłuszyć&nbsp;</b>
          i&nbsp;
          <b>uciszyć&nbsp;</b>
          cel na tyle długo, by go skrępować.
          <br />
          Za pomocą&nbsp;
          <b>opasek zaciskowych&nbsp;</b> zdobytych na stacji albo pisma&nbsp;
          <b>
            <span style={{ color: '#F19096' }}>Nienawistne kajdany&nbsp;</span>
          </b>
          możesz skrępować cel, żeby nie uciekł przed światłem.
          <br />
          Przywołaj&nbsp;
          <b>
            <span style={{ color: '#D5B8DC' }}>Ucieczkę&nbsp;</span>
          </b>
          , żeby wrócić do Reebe razem z istotą, którą ciągniesz.
          <br />
          Tam przywołaj&nbsp;
          <b>
            <span style={{ color: '#9EA7E5' }}>pieczęć uległości&nbsp;</span>
          </b>
          i przytrzymaj nad nią cel przez 8 sekund. <br />
          Nie oświecisz osób z&nbsp;
          <b>implantem ochrony umysłu.</b>
          <br />
          Zabierz im&nbsp;
          <b>słuchawki&nbsp;</b>
          , żeby nie szerzyli dezinformacji!
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Obrona Reebe" color="average">
        <Section>
          <b>
            Masz do dyspozycji wiele budowli i mocy, które są kluczowe w obronie
            Arki.
          </b>
          <br />
          <b>
            <span style={{ color: '#B5FD9D' }}>Fabrykator replik:&nbsp;</span>
          </b>
          Potężne narzędzie, które szybko buduje mosiężne konstrukcje albo
          zamienia większość materiałów w mosiądz.
          <br />
          <b>
            <span style={{ color: '#DED09F' }}>Zębatkoskarabeusz:&nbsp;</span>
          </b>
          Mały dron opętany przez duchy poległych żołnierzy, który chroni Reebe,
          gdy ty szerzysz prawdę!
          <br />
          <b>
            <span style={{ color: '#FF9D9D' }}>Mechaniczny maruder:&nbsp;</span>
          </b>
          Potężna powłoka, która odbija ataki dystansowe i mocno uderza w walce
          wręcz.
          <br />
          <br />
        </Section>
      </Collapsible>
      <Collapsible title="Arka" color="average">
        <Section>
          Żeby przywołać Rat&#39;Vara, trzeba otworzyć&nbsp;
          <b>
            <span style={{ color: '#E9E094' }}>Arkę&nbsp;</span>
          </b>
          .
          <br />
          Wystarczy, że dość sług przywoła pismo&nbsp;
          <b>
            <span style={{ color: '#B5FD9D' }}>Ożywienie Arki.&nbsp;</span>
          </b>
          <br />
          Gdy oświecisz wystarczająco dużo załogi,&nbsp;
          <b>
            <span style={{ color: '#E9E094' }}>Arka&nbsp;</span>
          </b>
          otworzy się sama.
          <br />
          <b>
            Przygotuj się na otwarcie Arki, bo cała załoga rzuci się, żeby ją
            zniszczyć!
          </b>
          <br />
        </Section>
      </Collapsible>
    </>
  );
};

export const ClockworkSpellList = (props) => {
  const { act, data } = useBackend<Data>();
  const { selectedTab } = props;
  const { scriptures = [] } = data;
  return (
    <Table>
      {scriptures.map((script) =>
        script.type === selectedTab ? (
          <Fragment key={script}>
            <Table.Row>
              <Table.Cell bold>{script.name}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  color={script.purchased ? 'default' : 'average'}
                  content={
                    script.purchased
                      ? 'Przywołaj (' + convertPower(script.cost) + ')'
                      : 'Zębatki: ' + script.cog_cost
                  }
                  disabled={false}
                  onClick={() =>
                    act('invoke', {
                      scriptureName: script.name,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>{script.desc}</Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  content={'Szybki dostęp'}
                  disabled={!script.purchased}
                  onClick={() =>
                    act('quickbind', {
                      scriptureName: script.name,
                    })
                  }
                />
              </Table.Cell>
            </Table.Row>
            <Table.Cell>
              <Divider />
            </Table.Cell>
          </Fragment>
        ) : (
          <Box key={script} />
        ),
      )}
    </Table>
  );
};

export const ClockworkOverview = (props) => {
  const { data } = useBackend<Data>();
  const { power, cogs, vitality } = data;
  return (
    <Box>
      <Box color="good" bold fontSize="16px">
        {'Raport Arki'}
      </Box>
      <Divider />
      <ClockworkOverviewStat
        title="Zębatki"
        amount={cogs}
        maxAmount={cogs + 50 / cogs}
        iconName="cog"
        unit=""
      />
      <ClockworkOverviewStat
        title="Moc"
        amount={power}
        maxAmount={power + 500000 / power}
        iconName="battery-half "
        overrideText={convertPower(power)}
      />
      <ClockworkOverviewStat
        title="Witalność"
        amount={vitality}
        maxAmount={vitality + 50 / vitality}
        iconName="tint"
        unit="j."
      />
    </Box>
  );
};

export const ClockworkOverviewStat = (props) => {
  const { title, iconName, amount, maxAmount, unit, overrideText } = props;
  return (
    <Box height="22px" fontSize="16px">
      <Grid>
        <Grid.Column>
          <Icon name={iconName} rotation={0} spin={0} />
        </Grid.Column>
        <Grid.Column size={2}>{title}</Grid.Column>
        <Grid.Column size={8}>
          <ProgressBar
            value={amount}
            minValue={0}
            maxValue={maxAmount}
            ranges={{
              good: [maxAmount / 2, Infinity],
              average: [maxAmount / 4, maxAmount / 2],
              bad: [-Infinity, maxAmount / 4],
            }}
          >
            {overrideText ? overrideText : amount + ' ' + unit}
          </ProgressBar>
        </Grid.Column>
      </Grid>
    </Box>
  );
};

// AQUILA: SPELLTYPE_* z DM to klucze, tłumaczymy tylko napis
const SPELLTYPE_NAMES: Record<string, string> = {
  Servitude: 'Służba',
  Preservation: 'Ochrona',
  Structures: 'Budowle',
};

export const ClockworkButtonSelection = (props) => {
  const [selectedTab, setSelectedTab] = useLocalState<any>('selectedTab', {});
  const tabs = ['Servitude', 'Preservation', 'Structures'];
  return (
    <Table>
      <Table.Row>
        {tabs.map((tab) => (
          <Table.Cell key={tab} collapsing>
            <Button
              key={tab}
              fluid
              content={SPELLTYPE_NAMES[tab] || tab}
              onClick={() => setSelectedTab(tab)}
            />
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};

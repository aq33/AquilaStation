import yaml from 'js-yaml';
import { Component, Fragment } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Icon,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { sendAct as act } from '../events/act';
import { Window } from '../layouts';

const icons = {
  add: { icon: 'check-circle', color: 'green' },
  admin: { icon: 'user-shield', color: 'purple' },
  balance: { icon: 'balance-scale-right', color: 'yellow' },
  bugfix: { icon: 'bug', color: 'green' },
  code_imp: { icon: 'code', color: 'green' },
  config: { icon: 'cogs', color: 'purple' },
  expansion: { icon: 'check-circle', color: 'green' },
  experiment: { icon: 'radiation', color: 'yellow' },
  image: { icon: 'image', color: 'green' },
  imageadd: { icon: 'tg-image-plus', color: 'green' },
  imagedel: { icon: 'tg-image-minus', color: 'red' },
  qol: { icon: 'hand-holding-heart', color: 'green' },
  refactor: { icon: 'tools', color: 'green' },
  rscadd: { icon: 'check-circle', color: 'green' },
  rscdel: { icon: 'times-circle', color: 'red' },
  server: { icon: 'server', color: 'purple' },
  sound: { icon: 'volume-high', color: 'green' },
  soundadd: { icon: 'tg-sound-plus', color: 'green' },
  sounddel: { icon: 'tg-sound-minus', color: 'red' },
  spellcheck: { icon: 'spell-check', color: 'green' },
  map: { icon: 'map', color: 'green' },
  tgs: { icon: 'toolbox', color: 'purple' },
  tweak: { icon: 'wrench', color: 'green' },
  unknown: { icon: 'info-circle', color: 'label' },
  wip: { icon: 'hammer', color: 'orange' },
};

type Change = Record<string, string>;
type AuthorChanges = Record<string, Change[]>;
type ChangelogYaml = Record<string, AuthorChanges>;

type Testmerge = {
  title: string;
  number: number;
  link: string;
  author: string;
  changes: Record<string, string[]>;
};

type ChangelogData = {
  dates: string[];
  testmerges?: Testmerge[];
};

type ChangelogState = {
  loaded_text: ChangelogYaml | string;
  selectedDate: string;
  selectedIndex: number;
};

const LOADING_TEXT = 'Wczytywanie listy zmian...';

// AQUILA EDIT - polskie nazwy miesięcy zamiast dateformat
const formatMonth = (date: string) =>
  new Date(date).toLocaleDateString('pl-PL', {
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  });

const formatDay = (date: string) =>
  new Date(date).toLocaleDateString('pl-PL', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    timeZone: 'UTC',
  });

const ChangeRow = (props: { kind: string; content: string }) => {
  return (
    <Table.Row>
      <Table.Cell
        className={classes(['Changelog__Cell', 'Changelog__Cell--Icon'])}
      >
        <Icon
          color={
            icons[props.kind] ? icons[props.kind].color : icons['unknown'].color
          }
          name={
            icons[props.kind] ? icons[props.kind].icon : icons['unknown'].icon
          }
        />
      </Table.Cell>
      <Table.Cell className="Changelog__Cell">{props.content}</Table.Cell>
    </Table.Row>
  );
};

const Header = (props: { dropdown: any }) => {
  return (
    <Section>
      {/* AQUILA: our project instead of BeeStation's links */}
      <h1>NSV13 Aquila</h1>
      <p>
        <b>Podziękowania dla: </b>
        NSV13, BeeStation, /TG/station, Baystation 12, /vg/station, NTstation,
        CDK Station devs, FacepunchStation, GoonStation devs, twórców
        oryginalnego Space Station 13 i wszystkich, którzy przez lata dokładali
        się do gry.
      </p>
      <p>
        {'Kod źródłowy i lista autorów: '}
        <a href="https://github.com/aq33/NSV13">GitHub</a>
        {', '}
        <a href="https://github.com/aq33/NSV13/graphs/contributors">
          kontrybutorzy
        </a>
        .
      </p>
      {props.dropdown}
    </Section>
  );
};

const Footer = (props: { dropdown: any }) => {
  return (
    <Section>
      {props.dropdown}
      <h3>GoonStation 13 Development Team</h3>
      <p>
        <b>Programiści: </b>
        Stuntwaffle, Showtime, Pantaloons, Nannek, Keelin, Exadv1, hobnob,
        Justicefries, 0staf, sniperchance, AngriestIBM, BrianOBlivion
      </p>
      <p>
        <b>Graficy: </b>
        Supernorn, Haruhi, Stuntwaffle, Pantaloons, Rho, SynthOrange, I Said No
      </p>
      <p>
        BeeStation dziękuje GoonStation 13 Development Team za pracę nad grą
        {' do wydania r4407. Listę zmian do r4407 znajdziesz '}
        <a href="https://wiki.ss13.co/Pre-2016_Changelog#April_2010">tutaj</a>.
      </p>
      <p>
        {'O ile nie zaznaczono inaczej, Goon Station 13 jest na licencji '}
        <a href="https://creativecommons.org/licenses/by-nc-sa/3.0/">
          Creative Commons Attribution-Noncommercial-Share Alike 3.0 License
        </a>
        {'. Prawa przysługują obecnie wyłącznie '}
        <a href="http://forums.somethingawful.com/">SomethingAwful Goons</a>
        {'.'}
      </p>
      <h3>Licencja BeeStation</h3>
      <p>
        {'Cały kod po '}
        <a
          href={
            'https://github.com/tgstation/tgstation/commit/' +
            '333c566b88108de218d882840e61928a9b759d8f'
          }
        >
          commicie 333c566b88108de218d882840e61928a9b759d8f z 31.12.2014, 16:38
          PST
        </a>
        {' jest na licencji '}
        <a href="https://www.gnu.org/licenses/agpl-3.0.html">GNU AGPL v3</a>
        {'. Kod sprzed tego commita jest na licencji '}
        <a href="https://www.gnu.org/licenses/gpl-3.0.html">GNU GPL v3</a>
        {
          ', łącznie z narzędziami, chyba że ich readme mówi inaczej. Szczegóły w '
        }
        <a href="https://github.com/tgstation/tgstation/blob/master/LICENSE">
          LICENSE
        </a>
        {' i '}
        <a href="https://github.com/tgstation/tgstation/blob/master/GPLv3.txt">
          GPLv3.txt
        </a>
        {'.'}
      </p>
      <p>
        API TGS DMAPI jest osobnym podprojektem na licencji MIT.
        {' Zobacz stopkę '}
        <a
          href={
            'https://github.com/tgstation/tgstation/blob/master' +
            '/code/__DEFINES/tgs.dm'
          }
        >
          code/__DEFINES/tgs.dm
        </a>
        {' i '}
        <a
          href={
            'https://github.com/tgstation/tgstation/blob/master' +
            '/code/modules/tgs/LICENSE'
          }
        >
          code/modules/tgs/LICENSE
        </a>
        {', gdzie znajduje się licencja MIT.'}
      </p>
      <p>
        {'Wszystkie zasoby, w tym ikony i dźwięki, są na licencji '}
        <a href="https://creativecommons.org/licenses/by-sa/3.0/">
          Creative Commons 3.0 BY-SA license
        </a>
        {', o ile nie zaznaczono inaczej.'}
      </p>
    </Section>
  );
};

const Testmerges = (_props) => {
  const {
    data: { testmerges },
  } = useBackend<ChangelogData>();
  if (!testmerges?.length) {
    return null;
  }
  return (
    <>
      <Section px={1}>
        <h4>
          To funkcje, które są teraz testowane i rozwijane na serwerze. Błędy i
          uwagi zgłaszaj w oryginalnym PR albo w wątku na Discordzie, jeśli taki
          istnieje.
        </h4>
      </Section>
      <Stack vertical>
        {testmerges.map((testmerge) => {
          const title = (
            <a href={testmerge.link}>
              #{testmerge.number}: &quot;{testmerge.title}&quot;, autor:{' '}
              {testmerge.author}
            </a>
          );
          return (
            <Stack.Item key={testmerge.number}>
              <Section title={title}>
                <Collapsible color="transparent" title="Lista zmian" open>
                  <Box ml={3}>
                    <Table>
                      {Object.entries(testmerge.changes).map(
                        ([kind, changes]) =>
                          changes.map((desc) => (
                            <ChangeRow
                              key={kind + desc}
                              kind={kind}
                              content={desc}
                            />
                          )),
                      )}
                    </Table>
                  </Box>
                </Collapsible>
              </Section>
            </Stack.Item>
          );
        })}
      </Stack>
    </>
  );
};

export class ChangelogContent extends Component<any, ChangelogState> {
  dateChoices: string[];

  constructor(props) {
    super(props);
    this.dateChoices = [];
    this.state = {
      loaded_text: LOADING_TEXT,
      selectedDate: '',
      selectedIndex: 0,
    };
  }

  setData(loaded_text: ChangelogYaml | string) {
    this.setState({ loaded_text });
  }

  setSelectedDate(selectedDate: string) {
    this.setState({ selectedDate });
  }

  setSelectedIndex(selectedIndex: number) {
    this.setState({ selectedIndex });
  }

  getData = (date: string, attemptNumber = 1) => {
    const maxAttempts = 6;

    if (attemptNumber > maxAttempts) {
      return this.setData(
        `Nie udało się wczytać danych po ${maxAttempts} próbach`,
      );
    }

    act('get_month', { date });

    fetch(resolveAsset(`${date}.yml`)).then(async (changelogData) => {
      const result = changelogData.ok ? await changelogData.text() : '';
      // Serwer zasobów może zwrócić tekst błędu zamiast kodu 404
      if (!changelogData.ok || /^Cannot find/.test(result)) {
        if (attemptNumber >= maxAttempts) {
          this.setData(
            `Nie udało się wczytać danych po ${maxAttempts} próbach`,
          );
          return;
        }

        const timeout = 50 + attemptNumber * 50;
        this.setData(`Wczytywanie listy zmian${'.'.repeat(attemptNumber + 3)}`);
        setTimeout(() => {
          this.getData(date, attemptNumber + 1);
        }, timeout);
        return;
      }

      this.setData(
        yaml.load(result, { schema: yaml.CORE_SCHEMA }) as ChangelogYaml,
      );
    });
  };

  componentDidMount() {
    const { data } = useBackend<ChangelogData>();
    const { dates = [] } = data;

    if (dates.length) {
      dates.forEach((date) => {
        this.dateChoices.push(formatMonth(date));
      });
      this.setSelectedDate(this.dateChoices[0]);
      this.getData(dates[0]);
    }
  }

  selectIndex(index: number) {
    const { data } = useBackend<ChangelogData>();
    const { dates = [] } = data;

    this.setData(LOADING_TEXT);
    this.setSelectedIndex(index);
    this.setSelectedDate(this.dateChoices[index]);
    window.scrollTo(
      0,
      document.body.scrollHeight || document.documentElement.scrollHeight,
    );
    return this.getData(dates[index]);
  }

  render() {
    const { data } = useBackend<ChangelogData>();
    const { testmerges } = data;
    const { loaded_text, selectedIndex, selectedDate } = this.state;
    const { dateChoices } = this;

    const dateDropdown = dateChoices.length > 0 && (
      <Stack mb={1}>
        <Stack.Item>
          <Button
            className="Changelog__Button"
            disabled={selectedIndex === 0}
            icon="chevron-left"
            onClick={() => this.selectIndex(selectedIndex - 1)}
          />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            autoScroll={false}
            options={dateChoices}
            onSelected={(value) => this.selectIndex(dateChoices.indexOf(value))}
            selected={selectedDate}
            width="150px"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            className="Changelog__Button"
            disabled={selectedIndex === dateChoices.length - 1}
            icon="chevron-right"
            onClick={() => this.selectIndex(selectedIndex + 1)}
          />
        </Stack.Item>
      </Stack>
    );

    const changes =
      typeof loaded_text === 'object' &&
      Object.keys(loaded_text).length > 0 &&
      Object.entries(loaded_text)
        .reverse()
        .map(([date, authors]) => (
          <Section key={date} title={formatDay(date)}>
            <Box ml={3}>
              {Object.entries(authors).map(([name, changes]) => (
                <Fragment key={name}>
                  <h4>{name} – zmiany:</h4>
                  <Box ml={3}>
                    <Table>
                      {changes.map((change) => {
                        const changeType = Object.keys(change)[0];
                        return (
                          <ChangeRow
                            key={changeType + change[changeType]}
                            kind={changeType}
                            content={change[changeType]}
                          />
                        );
                      })}
                    </Table>
                  </Box>
                </Fragment>
              ))}
            </Box>
          </Section>
        ));

    return (
      <>
        <Header dropdown={dateDropdown} />
        {/* AQUILA EDIT - testmerge'e z Bee obok listy zmian */}
        <Stack>
          <Stack.Item grow>{changes}</Stack.Item>
          {!!testmerges?.length && (
            <Stack.Item width="50%">
              <Testmerges />
            </Stack.Item>
          )}
        </Stack>
        {typeof loaded_text === 'string' && <p>{loaded_text}</p>}
        <Footer dropdown={dateDropdown} />
      </>
    );
  }
}

export const Changelog = () => {
  const { data } = useBackend<ChangelogData>();
  const { testmerges } = data;

  return (
    <Window
      title="Lista zmian"
      width={testmerges?.length ? 1000 : 675}
      height={650}
    >
      <Window.Content scrollable>
        <ChangelogContent />
      </Window.Content>
    </Window>
  );
};

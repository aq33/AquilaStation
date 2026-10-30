import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Telemetry = {
  status: string;
  bad: boolean;
  notices?: { text: string; bad: boolean }[];
};

type MuteType = {
  name: string;
  flag: number;
};

type Data = {
  exists: boolean;
  ref: string;
  name: string;
  key: string;
  ckey: string;
  mob_type: string;
  new_player: boolean;
  has_mind: boolean;
  cyborg: boolean;
  human_with_mind: boolean;
  is_human: boolean;
  is_monkey: boolean;
  is_corgi: boolean;
  is_ai: boolean;
  is_cluwne: boolean;
  is_animal: boolean;
  has_client: boolean;
  log_src: string;
  client_name: string;
  rank: string;
  is_admin: boolean;
  playtime: string | null;
  join_date: string;
  account_join_date: string;
  telemetry: Telemetry;
  centcom_db: boolean;
  antag_rep: number;
  antag_tokens: number;
  metacurrency_name: string;
  metabalance: number;
  byond_version: string;
  muted: number;
  mute_types: MuteType[];
};

const ValueEditor = (props: { value: string }) => {
  const { act } = useBackend<Data>();
  const { value } = props;
  return (
    <>
      <Button
        icon="plus"
        tooltip="Dodaj"
        onClick={() => act('modvalue', { value, operation: 'add' })}
      />
      <Button
        icon="minus"
        tooltip="Odejmij"
        onClick={() => act('modvalue', { value, operation: 'subtract' })}
      />
      <Button
        icon="equals"
        tooltip="Ustaw"
        onClick={() => act('modvalue', { value, operation: 'set' })}
      />
      <Button
        icon="times"
        tooltip="Wyzeruj"
        onClick={() => act('modvalue', { value, operation: 'zero' })}
      />
    </>
  );
};

const SIMPLE_MAKE: [string, [string, string][]][] = [
  [
    'Podstawowe',
    [
      ['observer', 'Obserwator'],
      ['human', 'Człowiek'],
      ['monkey', 'Małpa'],
      ['robot', 'Cyborg'],
      ['cat', 'Kot'],
      ['runtime', 'Runtime'],
      ['corgi', 'Corgi'],
      ['ian', 'Ian'],
      ['crab', 'Krab'],
      ['coffee', 'Coffee'],
      ['shade', 'Cień'],
    ],
  ],
  [
    'Szlam',
    [
      ['slime', 'Młody'],
      ['adultslime', 'Dorosły'],
    ],
  ],
  [
    'Obcy',
    [
      ['drone', 'Dron'],
      ['hunter', 'Łowca'],
      ['sentinel', 'Strażnik'],
      ['praetorian', 'Pretorianin'],
      ['queen', 'Królowa'],
      ['larva', 'Larwa'],
    ],
  ],
  [
    'Konstrukt',
    [
      ['constructarmored', 'Juggernaut'],
      ['constructbuilder', 'Artificer'],
      ['constructwraith', 'Wraith'],
    ],
  ],
];

const ClientSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { telemetry } = data;
  return (
    <Section title="Klient">
      <LabeledList>
        <LabeledList.Item label="Ranga">
          <Button onClick={() => act('editrights')}>{data.rank}</Button>
        </LabeledList.Item>
        {data.playtime !== null && data.playtime !== undefined && (
          <LabeledList.Item label="Czas gry">
            <Button onClick={() => act('getplaytimewindow')}>
              {data.playtime}
            </Button>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Pierwsze wejście">
          {data.join_date}
        </LabeledList.Item>
        <LabeledList.Item label="Konto BYOND od">
          {data.account_join_date}
        </LabeledList.Item>
        <LabeledList.Item label="Wersja BYOND">
          {data.byond_version}
        </LabeledList.Item>
        <LabeledList.Item label="Telemetria">
          <Box color={telemetry?.bad ? 'bad' : undefined}>
            {telemetry?.status}
          </Box>
          {telemetry?.notices?.length === 0 && (
            <Box color="good">Brak alertów.</Box>
          )}
          {telemetry?.notices?.map((notice, i) => (
            <Box key={i} color={notice.bad ? 'bad' : 'average'}>
              {notice.text}
            </Box>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Baza banów CentCom">
          {data.centcom_db ? (
            <Button icon="search" onClick={() => act('centcomlookup')}>
              Szukaj
            </Button>
          ) : (
            <Box italic color="label">
              Wyłączona
            </Box>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Powiązane konta">
          <Button onClick={() => act('relatedacc', { type: 'cid' })}>
            CID
          </Button>
          <Button onClick={() => act('relatedacc', { type: 'ip' })}>IP</Button>
        </LabeledList.Item>
        <LabeledList.Item label="Reputacja antaga">
          <Box inline mr={1}>
            {data.antag_rep}
          </Box>
          <ValueEditor value="antagrep" />
        </LabeledList.Item>
        <LabeledList.Item label="Żetony antaga">
          <Box inline mr={1}>
            {data.antag_tokens}
          </Box>
          <ValueEditor value="antagtokens" />
        </LabeledList.Item>
        <LabeledList.Item label={data.metacurrency_name}>
          <Box inline mr={1}>
            {data.metabalance}
          </Box>
          <ValueEditor value="metacoins" />
        </LabeledList.Item>
        <LabeledList.Item label="Wyciszenie">
          {data.mute_types?.map((mute) => (
            <Button.Checkbox
              key={mute.flag}
              checked={!!(data.muted & mute.flag)}
              color={data.muted & mute.flag ? 'bad' : undefined}
              onClick={() => act('mute', { flag: mute.flag })}
            >
              {mute.name}
            </Button.Checkbox>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const TransformSection = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Section title="Przemiana">
      <LabeledList>
        <LabeledList.Item label="Przemiana">
          {data.is_human ? (
            <Button disabled>Człowiek</Button>
          ) : (
            <Button onClick={() => act('humanone')}>Uczłowiecz</Button>
          )}
          {data.is_monkey ? (
            <Button disabled>Małpa</Button>
          ) : (
            <Button onClick={() => act('monkeyone')}>W małpę</Button>
          )}
          {data.is_corgi ? (
            <Button disabled>Corgi</Button>
          ) : (
            <Button onClick={() => act('corgione')}>W corgi</Button>
          )}
          {!!data.is_ai && <Button disabled>Jest SI</Button>}
          {!data.is_ai && !!data.is_human && (
            <>
              <Button onClick={() => act('makeai')}>W SI</Button>
              <Button onClick={() => act('makepai')}>W pAI</Button>
              <Button onClick={() => act('makerobot')}>W cyborga</Button>
              <Button onClick={() => act('makealien')}>W obcego</Button>
              <Button onClick={() => act('makeslime')}>W szlam</Button>
              <Button onClick={() => act('makeblob')}>W bloba</Button>
            </>
          )}
          {data.is_cluwne ? (
            <Button disabled>Jest cluwne</Button>
          ) : (
            !!data.is_human && (
              <Button onClick={() => act('makecluwne')}>W cluwne</Button>
            )
          )}
          <Button onClick={() => act('makeanimal')}>
            {data.is_animal ? 'Ponownie w zwierzę' : 'W zwierzę'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} color="label" fontSize={0.9}>
        Prosta przemiana tylko tworzy nowego moba i kopiuje dane. Gdy się da,
        lepiej użyć przycisków powyżej.
      </Box>
      <LabeledList>
        {SIMPLE_MAKE.map(([group, types]) => (
          <LabeledList.Item key={group} label={group}>
            {types.map(([type, label]) => (
              <Button key={type} onClick={() => act('simplemake', { type })}>
                {label}
              </Button>
            ))}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

export const AdminPlayerPanel = (props) => {
  const { act, data } = useBackend<Data>();

  if (!data.exists) {
    return (
      <Window title="Panel gracza" theme="admin" width={700} height={300}>
        <Window.Content>
          <NoticeBox danger>Ten mob już nie istnieje.</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title={`Opcje dla ${data.key || data.name}`}
      theme="admin"
      width={720}
      height={680}
    >
      <Window.Content scrollable>
        <Section
          title={data.name}
          buttons={
            data.new_player ? (
              <Box italic color="label">
                Nie wszedł do gry
              </Box>
            ) : (
              <Button icon="heart" color="good" onClick={() => act('revive')}>
                Ulecz
              </Button>
            )
          }
        >
          <LabeledList>
            <LabeledList.Item label="Gracz">
              {data.has_client ? data.client_name : 'Brak klienta'}
            </LabeledList.Item>
            <LabeledList.Item label="Typ moba">
              {data.mob_type}
            </LabeledList.Item>
          </LabeledList>
          <Stack wrap="wrap" mt={1}>
            <Button onClick={() => act('vv')}>VV</Button>
            {data.has_mind ? (
              <Button onClick={() => act('traitor')}>TP</Button>
            ) : (
              <Button onClick={() => act('initmind')}>Utwórz umysł</Button>
            )}
            {!!data.cyborg && (
              <Button onClick={() => act('borgpanel')}>BP</Button>
            )}
            <Button onClick={() => act('pm')}>PM</Button>
            <Button onClick={() => act('subtlemessage')}>SM</Button>
            {!!data.human_with_mind && (
              <Button onClick={() => act('HeadsetMessage')}>HM</Button>
            )}
            <Button onClick={() => act('adminplayerobservefollow')}>FLW</Button>
            <Button onClick={() => act('logs')}>LOGI</Button>
            {!!data.ckey && !!data.centcom_db && (
              <Button
                tooltip="Bany gracza na innych serwerach (baza CentCom)"
                onClick={() => act('centcomlookup')}
              >
                CentCom
              </Button>
            )}
          </Stack>
        </Section>
        {!!data.has_client && <ClientSection />}
        <Section title="Akcje">
          <LabeledList>
            <LabeledList.Item label="Kary">
              <Button color="average" onClick={() => act('boot2')}>
                Wyrzuć
              </Button>
              <Button color="bad" onClick={() => act('ban')}>
                Ban
              </Button>
              <Button onClick={() => act('notes')}>Notatki</Button>
              {!!data.has_client && (
                <>
                  <Button onClick={() => act('sendtoprison')}>
                    Do więzienia
                  </Button>
                  <Button onClick={() => act('sendbacktolobby')}>
                    Wyślij do lobby
                  </Button>
                </>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Ruch">
              <Button onClick={() => act('jumpto')}>Skocz do</Button>
              <Button onClick={() => act('getmob')}>Przyciągnij</Button>
              <Button onClick={() => act('sendmob')}>Wyślij do</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Inne">
              <Button onClick={() => act('traitor')}>Panel zdrajcy</Button>
              <Button onClick={() => act('narrateto')}>Narracja do</Button>
              <Button onClick={() => act('subtlemessage')}>
                Subtelna wiadomość
              </Button>
              <Button onClick={() => act('languagemenu')}>Menu języków</Button>
            </LabeledList.Item>
            {!!data.has_client && (
              <LabeledList.Item label="Pozostałe">
                <Button onClick={() => act('forcespeech')}>
                  Wymuś wypowiedź
                </Button>
                <Button onClick={() => act('tdome1')}>Thunderdome 1</Button>
                <Button onClick={() => act('tdome2')}>Thunderdome 2</Button>
                <Button onClick={() => act('tdomeadmin')}>
                  Thunderdome admin
                </Button>
                <Button onClick={() => act('tdomeobserve')}>
                  Thunderdome obserwator
                </Button>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        {!!data.has_client && !data.new_player && <TransformSection />}
      </Window.Content>
    </Window>
  );
};

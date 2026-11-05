import {
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

// Nazwy ustawień (NES_*) i część wartości z list wyboru to klucze w DM
// (extra_settings[name], porównania w on_trigger), więc do DM idzie
// oryginał, a tłumaczymy tylko to, co widać w oknie.
export const NANITE_SETTING_PL: Record<string, string> = {
  'Sent Code': 'Wysyłany kod',
  Delay: 'Opóźnienie',
  Mode: 'Tryb',
  'Comm Code': 'Kod komunikacji',
  'Relay Channel': 'Kanał przekaźnika',
  'Health Percent': 'Procent zdrowia',
  Direction: 'Kierunek',
  'Nanite Percent': 'Procent nanitów',
  'Damage Type': 'Rodzaj obrażeń',
  Damage: 'Obrażenia',
  Sentence: 'Zdanie',
  Message: 'Wiadomość',
  Directive: 'Dyrektywa',
  'Inclusive Mode': 'Dopasowanie',
  Race: 'Rasa',
  'Hallucination Type': 'Rodzaj halucynacji',
  'Hallucination Detail': 'Szczegół halucynacji',
  'Mood Message': 'Komunikat nastroju',
  'Program Overwrite': 'Nadpisywanie programów',
  'Cloud Overwrite': 'Nadpisanie chmury',
  'Scan Type': 'Rodzaj skanu',
  'Button Name': 'Nazwa przycisku',
  Icon: 'Ikona',
  Color: 'Kolor',
  Logic: 'Logika',
  'Host Aggression': 'Agresja nosiciela',
  'Receive Messages': 'Odbieranie wiadomości',
  'Send Messages': 'Wysyłanie wiadomości',
};

// Rodzaje obrażeń (BRUTE, BURN, TOX, OXY, CLONE) osobno, bo "fire" jest też
// alertem w halucynacjach.
const NANITE_DAMAGE_PL: Record<string, string> = {
  brute: 'Obrażenia fizyczne',
  fire: 'Oparzenia',
  tox: 'Toksyny',
  oxy: 'Niedotlenienie',
  clone: 'Uszkodzenia komórkowe',
};

export const NANITE_VALUE_PL: Record<string, string> = {
  // kierunki
  NORTH: 'Północ',
  SOUTH: 'Południe',
  EAST: 'Wschód',
  WEST: 'Zachód',
  // ikony i kolory przycisku pilota
  one: 'Jeden',
  two: 'Dwa',
  three: 'Trzy',
  four: 'Cztery',
  five: 'Pięć',
  plus: 'Plus',
  minus: 'Minus',
  power: 'Zasilanie',
  green: 'Zielony',
  red: 'Czerwony',
  yellow: 'Żółty',
  blue: 'Niebieski',
  // szczegóły halucynacji
  random: 'Losowo',
  laser: 'Laser',
  disabler: 'Disabler',
  esword: 'Miecz energetyczny',
  gun: 'Pistolet',
  stunprod: 'Pałka elektryczna',
  harmbaton: 'Pałka',
  bomb: 'Bomba',
  airlock: 'Śluza',
  'airlock pry': 'Podważanie śluzy',
  console: 'Konsola',
  explosion: 'Wybuch',
  'far explosion': 'Odległy wybuch',
  mech: 'Mech',
  glass: 'Szkło',
  alarm: 'Alarm',
  beepsky: 'Beepsky',
  'wall decon': 'Rozbiórka ściany',
  'door hack': 'Hakowanie drzwi',
  phone: 'Telefon',
  hallelujah: 'Alleluja',
  highlander: 'Highlander',
  laughter: 'Śmiech',
  hyperspace: 'Nadprzestrzeń',
  'game over': 'Koniec gry',
  creepy: 'Upiorne szepty',
  tesla: 'Tesla',
  ratvar: 'Ratvar',
  'shuttle dock': 'Dokowanie promu',
  'blob alert': 'Alarm bloba',
  'malf ai': 'Zbuntowana SI',
  meteors: 'Meteory',
  supermatter: 'Supermateria',
  critical: 'Stan krytyczny',
  dead: 'Śmierć',
  healthy: 'Zdrowie',
  not_enough_oxy: 'Brak tlenu',
  not_enough_tox: 'Brak plazmy',
  not_enough_co2: 'Brak CO2',
  too_much_oxy: 'Za dużo tlenu',
  too_much_co2: 'Za dużo CO2',
  too_much_tox: 'Za dużo plazmy',
  newlaw: 'Nowe prawo',
  nutrition: 'Głód',
  charge: 'Niski poziom energii',
  gravity: 'Brak grawitacji',
  fire: 'Ogień',
  locked: 'Zablokowanie',
  hacked: 'Zhakowanie',
  temphot: 'Za gorąco',
  tempcold: 'Za zimno',
  pressure: 'Ciśnienie',
  // gatunki (id z GLOB.roundstart_races)
  human: 'Człowiek',
};

export const naniteSettingName = (name: string) =>
  NANITE_SETTING_PL[name] ?? name;

export const naniteValueName = (value, settingName?: string) => {
  if (typeof value !== 'string') {
    return value;
  }
  if (settingName === 'Damage Type') {
    return NANITE_DAMAGE_PL[value] ?? value;
  }
  return NANITE_VALUE_PL[value] ?? value;
};

type Data = {
  activated: any;
  activation_code: any;
  can_trigger: any;
  deactivation_code: any;
  desc: any;
  extra_settings: any;
  has_disk: any;
  has_extra_settings: any;
  has_program: any;
  kill_code: any;
  name: any;
  timer_restart: any;
  timer_shutdown: any;
  timer_trigger: any;
  timer_trigger_delay: any;
  trigger_code: any;
  trigger_cooldown: any;
  trigger_cost: any;
  use_rate: any;
};

export const NaniteCodes = (props) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title="Kody" mr={1}>
      <LabeledList>
        <LabeledList.Item label="Aktywacja">
          <NumberInput
            step={1}
            value={data.activation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(value) =>
              act('set_code', {
                target_code: 'activation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Dezaktywacja">
          <NumberInput
            step={1}
            value={data.deactivation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(value) =>
              act('set_code', {
                target_code: 'deactivation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Zniszczenie">
          <NumberInput
            step={1}
            value={data.kill_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            onChange={(value) =>
              act('set_code', {
                target_code: 'kill',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        {!!data.can_trigger && (
          <LabeledList.Item label="Wyzwolenie">
            <NumberInput
              step={1}
              value={data.trigger_code}
              width="47px"
              minValue={0}
              maxValue={9999}
              onChange={(value) =>
                act('set_code', {
                  target_code: 'trigger',
                  code: value,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const NaniteDelays = (props) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title="Opóźnienia" ml={1}>
      <LabeledList>
        <LabeledList.Item label="Czas do restartu">
          <NumberInput
            step={1}
            value={data.timer_restart}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            onChange={(value) =>
              act('set_restart_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Czas do wyłączenia">
          <NumberInput
            step={1}
            value={data.timer_shutdown}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            onChange={(value) =>
              act('set_shutdown_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        {!!data.can_trigger && (
          <>
            <LabeledList.Item label="Powtarzanie wyzwolenia">
              <NumberInput
                step={1}
                value={data.timer_trigger}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                onChange={(value) =>
                  act('set_trigger_timer', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Opóźnienie wyzwolenia">
              <NumberInput
                step={1}
                value={data.timer_trigger_delay}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                onChange={(value) =>
                  act('set_timer_trigger_delay', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};

export const NaniteExtraEntry = (props) => {
  const { extra_setting } = props;
  const { name, type } = extra_setting;
  const typeComponentMap = {
    number: <NaniteExtraNumber extra_setting={extra_setting} />,
    text: <NaniteExtraText extra_setting={extra_setting} />,
    type: <NaniteExtraType extra_setting={extra_setting} />,
    boolean: <NaniteExtraBoolean extra_setting={extra_setting} />,
  };
  return (
    <LabeledList.Item label={naniteSettingName(name)}>
      {typeComponentMap[type]}
    </LabeledList.Item>
  );
};

export const NaniteExtraNumber = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend<Data>();
  const { name, value, min, max, unit } = extra_setting;
  return (
    <NumberInput
      step={1}
      value={value}
      width="64px"
      minValue={min}
      maxValue={max}
      unit={unit}
      onChange={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraText = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend<Data>();
  const { name, value } = extra_setting;
  return (
    <Input
      value={value}
      width="200px"
      onChange={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraType = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend<Data>();
  const { name, value, types } = extra_setting;
  return (
    <Dropdown
      over
      selected={value}
      displayText={naniteValueName(value, name)}
      width="150px"
      options={(types || []).map((option) => ({
        displayText: naniteValueName(option, name),
        value: option,
      }))}
      onSelected={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
};

export const NaniteExtraBoolean = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend<Data>();
  const { name, value, true_text, false_text } = extra_setting;
  return (
    <Button.Checkbox
      content={value ? true_text : false_text}
      checked={value}
      onClick={() =>
        act('set_extra_setting', {
          target_setting: name,
        })
      }
    />
  );
};

export const NaniteProgrammer = (props) => {
  return (
    <Window width={420} height={550}>
      <Window.Content scrollable>
        <NaniteProgrammerContent />
      </Window.Content>
    </Window>
  );
};

export const NaniteProgrammerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_disk,
    has_program,
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activated,
    has_extra_settings,
    extra_settings = {},
  } = data;

  if (!has_disk) {
    return (
      <NoticeBox textAlign="center">Włóż dysk z programem nanitów</NoticeBox>
    );
  }

  if (!has_program) {
    return (
      <Section
        title="Pusty dysk"
        buttons={
          <Button icon="eject" content="Wysuń" onClick={() => act('eject')} />
        }
      />
    );
  }

  return (
    <Section
      title={name}
      buttons={
        <Button icon="eject" content="Wysuń" onClick={() => act('eject')} />
      }
    >
      <Section title="Informacje">
        <Grid>
          <Grid.Column>{desc}</Grid.Column>
          <Grid.Column size={0.7}>
            <LabeledList>
              <LabeledList.Item label="Zużycie">{use_rate}</LabeledList.Item>
              {!!can_trigger && (
                <>
                  <LabeledList.Item label="Koszt wyzwolenia">
                    {trigger_cost}
                  </LabeledList.Item>
                  <LabeledList.Item label="Odnowienie wyzwolenia">
                    {trigger_cooldown}
                  </LabeledList.Item>
                </>
              )}
            </LabeledList>
          </Grid.Column>
        </Grid>
      </Section>
      <Section
        title="Ustawienia"
        buttons={
          <Button
            icon={activated ? 'power-off' : 'times'}
            content={activated ? 'Aktywny' : 'Nieaktywny'}
            selected={activated}
            color="bad"
            bold
            onClick={() => act('toggle_active')}
          />
        }
      >
        <Grid>
          <Grid.Column>
            <NaniteCodes />
          </Grid.Column>
          <Grid.Column>
            <NaniteDelays />
          </Grid.Column>
        </Grid>
        {!!has_extra_settings && (
          <Section title="Special">
            <LabeledList>
              {extra_settings.map((setting) => (
                <NaniteExtraEntry key={setting.name} extra_setting={setting} />
              ))}
            </LabeledList>
          </Section>
        )}
      </Section>
    </Section>
  );
};

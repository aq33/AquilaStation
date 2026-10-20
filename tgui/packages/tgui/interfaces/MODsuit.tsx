import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  ColorBox,
  Dimmer,
  Dropdown,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { formatSiUnit } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MODsuitData = {
  // Static
  ui_theme: string;
  complexity_max: number;
  // Dynamic
  suit_status: SuitStatus;
  user_status: UserStatus;
  module_custom_status: ModuleCustomStatus;
  module_info: Module[];
  control: string;
  parts: PartData[];
};

type PartData = {
  slot: string;
  name: string;
  deployed: BooleanLike;
  ref: string;
};

type SuitStatus = {
  core_name: string;
  // AQUILA: ładunek liczony w oknie (tg wysyła gotowy pasek z DM)
  cell_charge_current: number;
  cell_charge_max: number;
  active: BooleanLike;
  open: BooleanLike;
  seconds_electrified: number;
  malfunctioning: BooleanLike;
  locked: BooleanLike;
  interface_break: BooleanLike;
  complexity: number;
  selected_module: string;
  ai_name: string;
  has_pai: BooleanLike;
  is_ai: BooleanLike;
};

type UserStatus = {
  user_name: string;
  user_assignment: string;
};

type ModuleCustomStatus = {
  health: number;
  health_max: number;
  loss_brute: number;
  loss_fire: number;
  loss_tox: number;
  loss_oxy: number;
  is_user_irradiated: BooleanLike;
  background_radiation_level: number;
  display_time: BooleanLike;
  shift_time: string;
  shift_id: string;
  body_temperature: number;
  nutrition: number;
  dna_unique_identity: string;
  dna_unique_enzymes: string;
  viruses: VirusData[];
};

type VirusData = {
  name: string;
  type: string;
  stage: number;
  maxstage: number;
  cure: string;
};

type Module = {
  module_name: string;
  description: string;
  module_type: number;
  module_active: BooleanLike;
  pinned: BooleanLike;
  idle_power: number;
  active_power: number;
  use_power: number;
  module_complexity: number;
  cooldown_time: number;
  cooldown: number;
  id: string;
  ref: string;
  configuration_data: ModuleConfig[];
};

type ModuleConfig = {
  display_name: string;
  type: string;
  value: number;
  values: [];
};

export const MODsuit = (props) => {
  const { data } = useBackend<MODsuitData>();
  const { ui_theme } = data;
  const { interface_break } = data.suit_status;
  return (
    <Window
      width={600}
      height={600}
      theme={ui_theme}
      title="Panel interfejsu MOD"
    >
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};

export const MODsuitContent = (props) => {
  const { data } = useBackend<MODsuitData>();
  const { interface_break } = data.suit_status;
  return (
    <Box>
      {interface_break ? (
        <LockedInterface />
      ) : (
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <SuitStatusSection />
              </Stack.Item>
              <Stack.Item grow>
                <UserStatusSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <ModuleSection />
          </Stack.Item>
          <Stack.Item>
            <HardwareSection />
          </Stack.Item>
        </Stack>
      )}
    </Box>
  );
};

const ConfigureNumberEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      step={1}
      stepPixelSize={5}
      width="39px"
      onChange={(value) =>
        act('configure', {
          key: name,
          value: value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureBoolEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('configure', {
          key: name,
          value: !value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureColorEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() =>
          act('configure', {
            key: name,
            ref: module_ref,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
    </>
  );
};

const ConfigureListEntry = (props) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend();
  return (
    <Dropdown
      selected={value}
      options={values}
      onSelected={(value) =>
        act('configure', {
          key: name,
          value: value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigurePinEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button
      onClick={() =>
        act('configure', { key: name, value: !value, ref: module_ref })
      }
      icon="thumbtack"
      selected={value}
      tooltip="Przypnij"
      tooltipPosition="left"
    />
  );
};

const ConfigureButtonEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button
      onClick={() => act('configure', { key: name, ref: module_ref })}
      icon={value}
    />
  );
};

const ConfigureDataEntry = (props) => {
  const { display_name, type } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
    button: <ConfigureButtonEntry {...props} />,
    pin: <ConfigurePinEntry {...props} />,
  };
  return (
    <LabeledList.Item label={display_name}>
      {configureEntryTypes[type]}
    </LabeledList.Item>
  );
};

const LockedInterface = () => (
  <Section align="center" fill>
    <Icon color="red" name="exclamation-triangle" size={15} />
    <Box fontSize="30px" color="red">
      BŁĄD: INTERFEJS NIE ODPOWIADA
    </Box>
  </Section>
);

const LockedModule = (props) => (
  <Dimmer>
    <Stack>
      <Stack.Item fontSize="16px" color="blue">
        SKAFANDER BEZ ZASILANIA
      </Stack.Item>
    </Stack>
  </Dimmer>
);

const ConfigureScreen = (props) => {
  const { configuration_data, module_ref } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Box pb={1}>
      <LabeledList>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <ConfigureDataEntry
              key={key}
              name={key}
              display_name={data.display_name}
              type={data.type}
              value={data.value}
              values={data.values}
              module_ref={module_ref}
            />
          );
        })}
      </LabeledList>
    </Box>
  );
};

const moduleTypeAction = (param) => {
  switch (param) {
    case 1:
      return 'Użyj';
    case 2:
      return 'Przełącz';
    case 3:
      return 'Wybierz';
  }
};

const radiationLevels = (param) => {
  switch (param) {
    case 1:
      return 'niskie';
    case 2:
      return 'średnie';
    case 3:
      return 'wysokie';
    case 4:
      return 'ekstremalne';
  }
};

const SuitStatusSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const {
    core_name,
    cell_charge_current,
    cell_charge_max,
    active,
    open,
    seconds_electrified,
    malfunctioning,
    locked,
    ai_name,
    has_pai,
    is_ai,
  } = data.suit_status;
  const { display_time, shift_time, shift_id } = data.module_custom_status;
  const status = malfunctioning ? 'Awaria' : active ? 'Aktywny' : 'Nieaktywny';
  // AQUILA: opis ładunku w dżulach (u nas 1 jednostka ogniwa = 1 kJ),
  // w tg ten tekst przychodzi gotowy z DM (chargebar_string)
  const charge_percent = Math.round(
    (100 * cell_charge_current) / cell_charge_max,
  );

  return (
    <Section
      title="Stan skafandra"
      fill
      buttons={
        <Button
          icon="power-off"
          color={active ? 'good' : 'default'}
          onClick={() => act('activate')}
        >
          {status}
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Ładunek">
          <ProgressBar
            value={cell_charge_current / cell_charge_max}
            ranges={{
              good: [0.6, Infinity],
              average: [0.3, 0.6],
              bad: [-Infinity, 0.3],
            }}
            style={{
              textShadow: '1px 1px 0 black',
            }}
          >
            {!core_name
              ? 'Nie wykryto rdzenia'
              : cell_charge_max === 1
                ? 'Brak ogniwa zasilającego'
                : cell_charge_current === 1e31
                  ? 'Nieskończony'
                  : `${formatSiUnit(cell_charge_current * 1000, 0, 'J')} z ${formatSiUnit(
                      cell_charge_max * 1000,
                      0,
                      'J',
                    )} (${charge_percent}%)`}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Blokada ID">
          <Button
            icon={locked ? 'lock' : 'lock-open'}
            color={locked ? 'good' : 'default'}
            onClick={() => act('lock')}
          >
            {locked ? 'Zablokowany' : 'Odblokowany'}
          </Button>
        </LabeledList.Item>
        {!!open && (
          <LabeledList.Item label="Pokrywa">
            <Box color="red">Otwarta</Box>
          </LabeledList.Item>
        )}
        {!!seconds_electrified && (
          <LabeledList.Item label="Obwody">
            <Box color="red">Zwarte</Box>
          </LabeledList.Item>
        )}
        {!!ai_name && (
          <LabeledList.Item label="Sterowanie pAI">
            {!!has_pai && (
              <Button
                icon="eject"
                disabled={is_ai}
                onClick={() => act('eject_pai')}
              >
                Wysuń pAI
              </Button>
            )}
          </LabeledList.Item>
        )}
      </LabeledList>

      {!!display_time && (
        <Section title="Operacja" mt={2}>
          <LabeledList.Item label="Czas">
            {active ? shift_time : '00:00:00'}
          </LabeledList.Item>
          <LabeledList.Item label="Numer">
            {active && shift_id ? shift_id : '???'}
          </LabeledList.Item>
        </Section>
      )}
    </Section>
  );
};

const HardwareSection = (props) => {
  const { data } = useBackend<MODsuitData>();
  const { control } = data;
  const { ai_name, core_name } = data.suit_status;
  return (
    <Section title="Sprzęt" style={{ textTransform: 'capitalize' }}>
      <LabeledList>
        <LabeledList.Item label="Jednostka sterująca">
          {control}
        </LabeledList.Item>
        <LabeledList.Item label="Rdzeń">
          {core_name || 'Nie wykryto rdzenia'}
        </LabeledList.Item>
        <ModParts />
        <LabeledList.Item label="Asystent SI">
          {ai_name || 'Nie wykryto SI'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ModParts = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { parts } = data;
  return (
    <>
      {parts.map((part) => {
        return (
          <LabeledList.Item
            key={part.slot}
            label={`Slot: ${part.slot}`}
            buttons={
              <Button
                selected={part.deployed}
                icon={part.deployed ? 'arrow-down' : 'arrow-up'}
                onClick={() => act('deploy', { ref: part.ref })}
              >
                {part.deployed ? 'Schowaj' : 'Rozłóż'}
              </Button>
            }
          >
            {part.name}
          </LabeledList.Item>
        );
      })}
    </>
  );
};

const UserStatusSection = (props) => {
  const { data } = useBackend<MODsuitData>();
  const { active } = data.suit_status;
  const { user_name, user_assignment } = data.user_status;
  const {
    health,
    health_max,
    loss_brute,
    loss_fire,
    loss_tox,
    loss_oxy,
    is_user_irradiated,
    background_radiation_level,
    body_temperature,
    nutrition,
    dna_unique_identity,
    dna_unique_enzymes,
    viruses,
  } = data.module_custom_status;
  return (
    <Section title="Stan użytkownika" fill>
      {!active && <LockedModule />}
      <LabeledList>
        {health !== undefined && (
          <LabeledList.Item label="Zdrowie">
            <ProgressBar
              value={active ? health / health_max : 0}
              ranges={{
                good: [0.5, Infinity],
                average: [0.2, 0.5],
                bad: [-Infinity, 0.2],
              }}
            >
              <AnimatedNumber value={active ? health : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_brute !== undefined && (
          <LabeledList.Item label="Obrażenia fizyczne">
            <ProgressBar
              value={active ? loss_brute / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_brute : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_fire !== undefined && (
          <LabeledList.Item label="Oparzenia">
            <ProgressBar
              value={active ? loss_fire / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_fire : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_oxy !== undefined && (
          <LabeledList.Item label="Niedotlenienie">
            <ProgressBar
              value={active ? loss_oxy / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_oxy : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_tox !== undefined && (
          <LabeledList.Item label="Zatrucie">
            <ProgressBar
              value={active ? loss_tox / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_tox : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {background_radiation_level !== undefined && (
          <LabeledList.Item label="Promieniowanie">
            {!active ? (
              'Nieznane'
            ) : is_user_irradiated ? (
              <NoticeBox danger>Użytkownik napromieniowany</NoticeBox>
            ) : background_radiation_level ? (
              <NoticeBox>
                {`Tło: ${radiationLevels(background_radiation_level)}`}
              </NoticeBox>
            ) : (
              <NoticeBox info>Nie wykryto</NoticeBox>
            )}
          </LabeledList.Item>
        )}
        {body_temperature !== undefined && (
          <LabeledList.Item label="Temp. ciała">
            {`${active ? Math.round(body_temperature) : 0} K`}
          </LabeledList.Item>
        )}
        {nutrition !== undefined && (
          <LabeledList.Item label="Sytość">
            {`${active ? Math.round(nutrition) : 0}`}
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Imię">{user_name}</LabeledList.Item>
        <LabeledList.Item label="Stanowisko">
          {user_assignment}
        </LabeledList.Item>
        {dna_unique_identity !== undefined && (
          <LabeledList.Item label="Odciski palców">
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_identity : '???'}
            </Box>
          </LabeledList.Item>
        )}
        {dna_unique_enzymes !== undefined && (
          <LabeledList.Item label="Enzymy">
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_enzymes : '???'}
            </Box>
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!viruses && (
        <Section title="Choroby">
          {viruses.map((virus) => {
            return (
              <Collapsible title={virus.name} key={virus.name}>
                <LabeledList>
                  <LabeledList.Item label="Rozprzestrzenianie">
                    {virus.type}
                  </LabeledList.Item>
                  <LabeledList.Item label="Stadium">
                    {virus.stage}/{virus.maxstage}
                  </LabeledList.Item>
                  <LabeledList.Item label="Lekarstwo">
                    {virus.cure}
                  </LabeledList.Item>
                </LabeledList>
              </Collapsible>
            );
          })}
        </Section>
      )}
    </Section>
  );
};

const ModuleSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { complexity_max, module_info } = data;
  const { complexity } = data.suit_status;
  const [configureState, setConfigureState] = useState('');

  return (
    <Section
      title="Moduły"
      fill
      buttons={`Złożoność: ${complexity} z ${complexity_max}`}
    >
      {!module_info.length ? (
        <NoticeBox>Nie wykryto modułów</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell colSpan={3}>Akcje</Table.Cell>
            <Table.Cell>Nazwa</Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="plug"
                tooltip="Pobór energii w spoczynku"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="lightbulb"
                tooltip="Pobór energii przy działaniu"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="bolt"
                tooltip="Koszt energii za użycie"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="save"
                tooltip="Złożoność"
                tooltipPosition="top"
              />
            </Table.Cell>
          </Table.Row>
          {module_info.map((module) => {
            return (
              <Table.Row key={module.ref}>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('select', { ref: module.ref })}
                    icon={
                      module.module_type === 3
                        ? module.module_active
                          ? 'check-square-o'
                          : 'square-o'
                        : 'power-off'
                    }
                    selected={module.module_active}
                    tooltip={moduleTypeAction(module.module_type)}
                    tooltipPosition="left"
                    disabled={!module.module_type || module.cooldown > 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() =>
                      setConfigureState(
                        configureState === module.ref ? '' : module.ref,
                      )
                    }
                    icon="cog"
                    selected={configureState === module.ref}
                    tooltip="Konfiguruj"
                    tooltipPosition="left"
                    disabled={module.configuration_data.length === 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('pin', { ref: module.ref })}
                    icon="thumbtack"
                    selected={module.pinned}
                    tooltip="Przypnij"
                    tooltipPosition="left"
                    disabled={!module.module_type}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Collapsible
                    title={module.module_name}
                    color={module.module_active ? 'green' : 'default'}
                  >
                    <Section mr={-19}>{module.description}</Section>
                  </Collapsible>
                  {configureState === module.ref && (
                    <ConfigureScreen
                      configuration_data={module.configuration_data}
                      module_ref={module.ref}
                    />
                  )}
                </Table.Cell>
                {/* AQUILA: koszty w jednostkach ogniwa (Bee), bez jednostek SI z tg */}
                <Table.Cell textAlign="center">{module.idle_power}</Table.Cell>
                <Table.Cell textAlign="center">
                  {module.active_power}
                </Table.Cell>
                <Table.Cell textAlign="center">{module.use_power}</Table.Cell>
                <Table.Cell textAlign="center">
                  {module.module_complexity}
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      )}
    </Section>
  );
};

import { Box, Button, Icon, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type AirlockControllerData = {
  airlockState: string;
  sensorPressure: number | string;
  pumpStatus: string;
  interiorStatus: string;
  exteriorStatus: string;
};

type AirlockStatus = {
  primary: string;
  icon: string;
  color: string;
};

const STATUS_TEXT: Record<string, string> = {
  open: 'Otwarte',
  closed: 'Zamknięte',
  locked: 'Zablokowane',
  release: 'Tłoczenie',
  siphon: 'Odsysanie',
  off: 'Wyłączona',
};

const statusText = (status: string) => STATUS_TEXT[status] || status;

export const AirlockController = (props) => {
  const { data } = useBackend<AirlockControllerData>();
  const { airlockState, pumpStatus, interiorStatus, exteriorStatus } = data;
  const currentStatus: AirlockStatus = getAirlockStatus(airlockState);

  return (
    <Window width={500} height={190}>
      <Window.Content>
        <Section title="Stan śluzy" buttons={<AirLockButtons />}>
          <LabeledList>
            <LabeledList.Item label="Obecny stan">
              {currentStatus.primary}
            </LabeledList.Item>
            <LabeledList.Item label="Ciśnienie w komorze">
              <PressureIndicator currentStatus={currentStatus} />
            </LabeledList.Item>
            <LabeledList.Item label="Pompa">
              {statusText(pumpStatus)}
            </LabeledList.Item>
            <LabeledList.Item label="Drzwi wewnętrzne">
              <Box color={interiorStatus === 'open' && 'good'}>
                {statusText(interiorStatus)}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Drzwi zewnętrzne">
              <Box color={exteriorStatus === 'open' && 'good'}>
                {statusText(exteriorStatus)}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

/** Przyciski cyklu śluzy nad oknem */
const AirLockButtons = (props) => {
  const { act, data } = useBackend<AirlockControllerData>();
  const { airlockState } = data;
  switch (airlockState) {
    case 'pressurize':
    case 'depressurize':
      return (
        <Button icon="stop-circle" onClick={() => act('abort')}>
          Przerwij
        </Button>
      );
    case 'closed':
      return (
        <>
          <Button icon="lock-open" onClick={() => act('cycle_interior')}>
            Otwórz wewnętrzną
          </Button>
          <Button icon="lock-open" onClick={() => act('cycle_exterior')}>
            Otwórz zewnętrzną
          </Button>
        </>
      );
    case 'inopen':
      return (
        <>
          <Button icon="lock" onClick={() => act('cycle_closed')}>
            Zamknij wewnętrzną
          </Button>
          <Button icon="sync" onClick={() => act('cycle_exterior')}>
            Cykl do zewnętrznej
          </Button>
        </>
      );
    case 'outopen':
      return (
        <>
          <Button icon="lock" onClick={() => act('cycle_closed')}>
            Zamknij zewnętrzną
          </Button>
          <Button icon="sync" onClick={() => act('cycle_interior')}>
            Cykl do wewnętrznej
          </Button>
        </>
      );
    default:
      return null;
  }
};

/** Ciśnienie z ikoną stanu */
const PressureIndicator = (props) => {
  const { data } = useBackend<AirlockControllerData>();
  const { sensorPressure } = data;
  const {
    currentStatus: { icon, color },
  } = props;
  const spin = icon === 'fan';

  return (
    <Box color={color}>
      {sensorPressure} kPa {icon && <Icon name={icon} spin={spin} />}
    </Box>
  );
};

/** Opis obecnego stanu śluzy */
const getAirlockStatus = (airlockState): AirlockStatus => {
  switch (airlockState) {
    case 'inopen':
      return {
        primary: 'Wewnętrzna śluza otwarta',
        icon: '',
        color: 'good',
      };
    case 'pressurize':
      return {
        primary: 'Cykl do wewnętrznej śluzy',
        icon: 'fan',
        color: 'average',
      };
    case 'closed':
      return {
        primary: 'Nieaktywna',
        icon: '',
        color: 'white',
      };
    case 'depressurize':
      return {
        primary: 'Cykl do zewnętrznej śluzy',
        icon: 'fan',
        color: 'average',
      };
    case 'outopen':
      return {
        primary: 'Zewnętrzna śluza otwarta',
        icon: 'exclamation-triangle',
        color: 'bad',
      };
    default:
      return {
        primary: 'Nieznany',
        icon: '',
        color: 'average',
      };
  }
};

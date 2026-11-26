// NSV13
// AQUILA: okno starego komputera FTL w wyglądzie konsoli rozpoznania (aquila/code/modules/overmap/consoles/ftl_computer_window.dm):
// stan napędu, rozkręcanie, skok awaryjny, śledzone okręty i położenie na mapie hex. Skacze się z konsoli nawigacji.
import { Box, Button } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { t } from '../i18n';
import {
  COLOR,
  ConsoleBar,
  ConsoleBody,
  ConsoleEmpty,
  ConsoleMeter,
  ConsolePanel,
  ConsoleRow,
  ConsoleWindow,
  MONO,
} from './common/ShipConsole';

type Tracked = {
  name: string;
  current_system: string;
  target_system: string;
};

type FtlTabData = {
  kind: 'legacy';
  can_control: BooleanLike;
  name?: string;
  powered?: BooleanLike;
  progress?: number;
  goal?: number;
  state?: number;
  ready?: BooleanLike;
  allowed?: BooleanLike;
  await_emergency_ftl_confirm?: BooleanLike;
  tracking?: Tracked[];
};

type Position = {
  system?: string;
  hex?: string;
  sector?: string;
  target?: string;
};

type Data = {
  ftl: FtlTabData;
  safety_override: BooleanLike;
  position: Position;
};

// FTL_STATE_* z nsv13/code/__DEFINES/ftl.dm
const STATE_NAMES: Record<number, string> = {
  1: 'bezczynny',
  2: 'rozkręcanie',
  3: 'gotowy do skoku',
  4: 'skok w toku',
};

const stateName = (state?: number) =>
  t(STATE_NAMES[state || 1] || STATE_NAMES[1]);

const stateColour = (state?: number) =>
  state === 3
    ? COLOR.good
    : state === 2 || state === 4
      ? COLOR.warn
      : COLOR.ink;

const spoolValue = (ftl: FtlTabData) =>
  ftl.goal ? (ftl.progress || 0) / ftl.goal : 0;

const LegacyDrive = (props: { ftl: FtlTabData }) => {
  const { act } = useBackend();
  const { ftl } = props;
  const canAct = !!ftl.can_control && !!ftl.allowed;
  const value = spoolValue(ftl);
  return (
    <>
      {!!ftl.await_emergency_ftl_confirm && (
        <ConsolePanel title="NADPISANIE">
          <Button
            icon="exclamation-triangle"
            fluid
            color="red"
            disabled={!canAct}
            onClick={() => act('emergency_jump')}
          >
            POTWIERDZIĆ SKOK AWARYJNY?
          </Button>
        </ConsolePanel>
      )}
      <ConsolePanel title="Akcje">
        <ConsoleRow label="Napęd:">{ftl.name}</ConsoleRow>
        <ConsoleRow label="Stan:" colour={stateColour(ftl.state)}>
          {stateName(ftl.state)}
        </ConsoleRow>
        <Box style={{ marginTop: '8px' }}>
          <Button
            icon="power-off"
            selected={!!ftl.powered}
            disabled={!canAct}
            onClick={() => act('toggle_power')}
          >
            {ftl.powered
              ? t('Wyłącz rozkręcanie')
              : t('Rozpocznij rozkręcanie')}
          </Button>
        </Box>
        {!ftl.can_control && (
          <Box style={{ color: COLOR.muted, marginTop: '6px' }}>
            Ta konsola tylko pokazuje stan napędu.
          </Box>
        )}
        {!!ftl.can_control && !ftl.allowed && (
          <Box style={{ color: COLOR.warn, marginTop: '6px' }}>
            Brak dostępu: sterowanie napędem wymaga dostępu do sprzętu
            maszynowni.
          </Box>
        )}
      </ConsolePanel>
      <ConsolePanel title="Rozkręcanie FTL">
        <ConsoleMeter
          value={value}
          colour={
            value >= 0.9 ? COLOR.good : value >= 0.15 ? COLOR.warn : COLOR.bad
          }
        />
      </ConsolePanel>
      <ConsolePanel title="Śledzenie">
        {(ftl.tracking || []).length === 0 && (
          <ConsoleEmpty>Brak śledzonych okrętów.</ConsoleEmpty>
        )}
        {(ftl.tracking || []).map((value, index) => (
          <ConsoleRow key={index} label={value.name}>
            {`Obecne położenie: ${value.current_system}`}
          </ConsoleRow>
        ))}
      </ConsolePanel>
    </>
  );
};

export const FTLComputer = () => {
  const { data } = useBackend<Data>();
  const { ftl, position, safety_override } = data;
  return (
    <ConsoleWindow width={360} height={520}>
      <ConsoleBar>
        <span style={{ color: COLOR.muted }}>Napęd FTL:</span>
        <span style={{ fontFamily: MONO, color: stateColour(ftl.state) }}>
          {stateName(ftl.state)}
        </span>
      </ConsoleBar>
      <ConsoleBody>
        {!!safety_override && (
          <ConsolePanel>
            <Box style={{ color: COLOR.bad, fontWeight: 600 }}>
              Bezpieczniki FTL są nadpisane: skok z nawigacji będzie skokiem
              awaryjnym i wymaga potwierdzenia tutaj.
            </Box>
          </ConsolePanel>
        )}
        <ConsolePanel title="Położenie">
          <ConsoleRow label="Układ:">{position.system || '—'}</ConsoleRow>
          <ConsoleRow label="Kafel:">{position.hex || '—'}</ConsoleRow>
          <ConsoleRow label="Sektor:">{position.sector || '—'}</ConsoleRow>
          {!!position.target && (
            <ConsoleRow label="Cel skoku:" colour={COLOR.warn}>
              {position.target}
            </ConsoleRow>
          )}
          <Box style={{ color: COLOR.muted, marginTop: '6px' }}>
            Cel skoku wybiera się na mapie w konsoli nawigacji.
          </Box>
        </ConsolePanel>
        <LegacyDrive ftl={ftl} />
      </ConsoleBody>
    </ConsoleWindow>
  );
};

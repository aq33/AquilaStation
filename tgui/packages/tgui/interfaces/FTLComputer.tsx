// NSV13
// AQUILA: dawne okno starego komputera FTL to teraz zakładka „Napęd FTL” okna „Nawigacja i skok” (Starmap.tsx).
// Pokazuje napęd okrętu: stary komputer FTL z jego sterowaniem albo stan napędu modułowego (sterowanie w maszynowni).
import { Box, Button } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { t } from '../i18n';
import {
  COLOR,
  ConsoleEmpty,
  ConsoleMeter,
  ConsolePanel,
  ConsoleRow,
} from './common/ShipConsole';

type Tracked = {
  name: string;
  current_system: string;
  target_system: string;
};

export type FtlTabData = {
  kind: 'none' | 'legacy' | 'modular';
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
  cooldown?: BooleanLike;
  pylons?: number;
  active_pylons?: number;
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

const ModularDrive = (props: { ftl: FtlTabData }) => {
  const { ftl } = props;
  const value = spoolValue(ftl);
  return (
    <>
      <ConsolePanel title="Stan napędu">
        <ConsoleRow label="Napęd:">{ftl.name}</ConsoleRow>
        <ConsoleRow label="Stan:" colour={stateColour(ftl.state)}>
          {stateName(ftl.state)}
        </ConsoleRow>
        <ConsoleRow label="Aktywne pylony:">
          {(ftl.active_pylons || 0) + ' / ' + (ftl.pylons || 0)}
        </ConsoleRow>
        <ConsoleRow
          label="Chłodzenie rdzenia:"
          colour={ftl.cooldown ? COLOR.warn : COLOR.ink}
        >
          {ftl.cooldown ? t('trwa') : '—'}
        </ConsoleRow>
        <Box style={{ marginTop: '6px' }}>
          <ConsoleMeter
            value={value}
            colour={
              value >= 0.95
                ? COLOR.good
                : value >= 0.15
                  ? COLOR.warn
                  : COLOR.bad
            }
          />
        </Box>
        {!!ftl.await_emergency_ftl_confirm && (
          <Box style={{ color: COLOR.bad, marginTop: '6px', fontWeight: 600 }}>
            Skok awaryjny czeka na potwierdzenie na konsoli napędu w maszynowni.
          </Box>
        )}
      </ConsolePanel>
      <ConsolePanel>
        <Box style={{ color: COLOR.muted }}>
          Ten okręt ma napęd modułowy (rdzeń i pylony). Rozkręcanie, pylony i
          potwierdzenie skoku awaryjnego są na konsoli napędu w maszynowni.
        </Box>
      </ConsolePanel>
    </>
  );
};

/** Zawartość zakładki „Napęd FTL” */
export const FTLDriveTab = (props: {
  ftl: FtlTabData;
  safetyOverride?: boolean;
}) => {
  const { ftl, safetyOverride } = props;
  return (
    <>
      {!!safetyOverride && (
        <ConsolePanel>
          <Box style={{ color: COLOR.bad, fontWeight: 600 }}>
            Bezpieczniki FTL są nadpisane: skok z mapy będzie skokiem awaryjnym
            i wymaga potwierdzenia.
          </Box>
        </ConsolePanel>
      )}
      {ftl.kind === 'legacy' && <LegacyDrive ftl={ftl} />}
      {ftl.kind === 'modular' && <ModularDrive ftl={ftl} />}
      {ftl.kind === 'none' && (
        <ConsolePanel>
          <ConsoleEmpty>
            Okręt nie ma napędu FTL połączonego z nawigacją.
          </ConsoleEmpty>
        </ConsolePanel>
      )}
    </>
  );
};

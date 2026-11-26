// AQUILA - wspólny wygląd okien konsol okrętu, wzięty ze stanowiska rozpoznania (SensorConsole.tsx): ciemne tło,
// panele oddzielone liną, tytuły sekcji wersalikami, liczby czcionką o stałej szerokości. Każde okno konsoli okrętu
// składa się z ConsoleWindow, ewentualnie ConsoleBar u góry, ConsoleTabs i paneli ConsolePanel.
import type { CSSProperties, ReactNode } from 'react';
import { Box, Button } from 'tgui-core/components';

import { Window } from '../../layouts';
import { card, COLOR, MONO, sectionTitle } from '../SensorConsole';

export { card, COLOR, MONO, sectionTitle };

/** Okno konsoli: tło, kolor tekstu i układ kolumnowy jak w stanowisku rozpoznania */
export const ConsoleWindow = (props: {
  width: number;
  height: number;
  title?: string;
  children: ReactNode;
}) => {
  const { width, height, title, children } = props;
  return (
    <Window width={width} height={height} title={title}>
      <Window.Content
        style={{
          background: COLOR.bg,
          color: COLOR.ink,
          padding: 0,
          fontSize: '13px',
        }}
      >
        <Box
          style={{ display: 'flex', flexDirection: 'column', height: '100%' }}
        >
          {children}
        </Box>
      </Window.Content>
    </Window>
  );
};

/** Pasek stanu u góry okna (jak pasek „CICHO / Ciepło napędu” rozpoznania) */
export const ConsoleBar = (props: { children: ReactNode }) => (
  <Box
    style={{
      display: 'flex',
      alignItems: 'center',
      flexWrap: 'wrap',
      gap: '10px',
      padding: '8px 10px',
      borderBottom: '1px solid ' + COLOR.line,
      background: COLOR.panel,
    }}
  >
    {props.children}
  </Box>
);

/** Zakładki okna: rząd przycisków pod paskiem stanu */
export const ConsoleTabs = <T extends string>(props: {
  tabs: [T, ReactNode][];
  active: T;
  onChange: (tab: T) => void;
  right?: ReactNode;
}) => {
  const { tabs, active, onChange, right } = props;
  return (
    <Box
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: '4px',
        padding: '6px 10px',
        borderBottom: '1px solid ' + COLOR.line,
        background: COLOR.panel2,
      }}
    >
      {tabs.map(([id, label]) => (
        <Button key={id} selected={id === active} onClick={() => onChange(id)}>
          {label}
        </Button>
      ))}
      {!!right && (
        <span style={{ marginLeft: 'auto', color: COLOR.muted }}>{right}</span>
      )}
    </Box>
  );
};

/** Przewijana część okna pod paskami */
export const ConsoleBody = (props: {
  children: ReactNode;
  style?: CSSProperties;
}) => (
  <Box
    style={{
      flex: 1,
      minHeight: 0,
      overflowY: 'auto',
      display: 'flex',
      flexDirection: 'column',
      ...props.style,
    }}
  >
    {props.children}
  </Box>
);

/** Panel z tytułem sekcji; right to przyciski albo licznik po prawej stronie tytułu */
export const ConsolePanel = (props: {
  title?: ReactNode;
  right?: ReactNode;
  children?: ReactNode;
  style?: CSSProperties;
}) => (
  <Box style={{ ...card, ...props.style }}>
    {!!(props.title || props.right) && (
      <div style={sectionTitle}>
        {props.title}
        {!!props.right && (
          <span
            style={{
              marginLeft: 'auto',
              textTransform: 'none',
              letterSpacing: 0,
              fontWeight: 400,
            }}
          >
            {props.right}
          </span>
        )}
      </div>
    )}
    {props.children}
  </Box>
);

/** Wiersz „etykieta: wartość”, wartość czcionką o stałej szerokości */
export const ConsoleRow = (props: {
  label: ReactNode;
  children: ReactNode;
  colour?: string;
}) => (
  <Box style={{ display: 'flex', gap: '10px', padding: '2px 0' }}>
    <span style={{ color: COLOR.muted, minWidth: '140px' }}>{props.label}</span>
    <span
      style={{ fontFamily: MONO, color: props.colour || COLOR.ink, flex: 1 }}
    >
      {props.children}
    </span>
  </Box>
);

/** Pasek postępu w stylu paska ciepła napędu; value 0–1 */
export const ConsoleMeter = (props: {
  value: number;
  colour?: string;
  label?: ReactNode;
  width?: string;
}) => {
  const pct = Math.max(0, Math.min(1, props.value || 0)) * 100;
  const colour =
    props.colour || (pct > 66 ? COLOR.good : pct > 33 ? COLOR.warn : COLOR.bad);
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '8px',
        width: props.width || '100%',
      }}
    >
      <span
        style={{
          flex: 1,
          height: '8px',
          borderRadius: '4px',
          background: '#1c2735',
          overflow: 'hidden',
          display: 'inline-block',
        }}
      >
        <span
          style={{
            display: 'block',
            height: '100%',
            width: pct + '%',
            background: colour,
          }}
        />
      </span>
      <span
        style={{
          fontFamily: MONO,
          minWidth: '44px',
          textAlign: 'right',
          color: COLOR.ink2,
        }}
      >
        {props.label ?? Math.round(pct) + '%'}
      </span>
    </span>
  );
};

/** Pusta lista: szary tekst w panelu */
export const ConsoleEmpty = (props: { children: ReactNode }) => (
  <Box style={{ color: COLOR.muted, padding: '4px 0' }}>{props.children}</Box>
);

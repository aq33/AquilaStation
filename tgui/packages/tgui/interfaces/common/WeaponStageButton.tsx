// AQUILA: przycisk etapu broni statkowej (I1, I2, I4), który nabija się paskiem, dopóki etap trwa
import {
  type ComponentProps,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import { Button } from 'tgui-core/components';

/** Dane etapu wysyłane przez cycle_stage_ui_data() w DM */
export type WeaponStageData = {
  cycle_stage?: string | null;
  cycle_stage_progress?: number;
  cycle_stage_time_left?: number;
};

type Props = Omit<
  ComponentProps<typeof Button>,
  'children' | 'content' | 'ellipsis'
> & {
  children?: ReactNode;
  content?: ReactNode;
  data: WeaponStageData;
  /** Etapy z DM, które pokazuje ten przycisk (np. ['feed', 'unload'] dla I1) */
  stages: string[];
};

export const WeaponStageButton = (props: Props) => {
  const { data, stages, style, content, children, ...rest } = props;
  const active = !!data.cycle_stage && stages.includes(data.cycle_stage);
  return (
    <Button
      {...rest}
      // W trakcie etapu przycisk jest ciemny i nabija się zielenią (motywy broni mają zielone zwykłe przyciski)
      color={active ? 'transparent' : rest.color}
      selected={active ? false : rest.selected}
      // Własny kontekst warstw: pasek z zIndex -1 jest nad tłem przycisku, ale pod ikoną i tekstem
      style={{
        ...style,
        position: 'relative',
        overflow: 'hidden',
        zIndex: 0,
        ...(active && {
          backgroundColor: 'rgba(0, 0, 0, 0.55)',
          color: '#eaffea',
          outline: '1px solid rgba(40, 220, 40, 0.8)',
        }),
      }}
      content={
        <>
          {active && (
            <StageFill
              progress={data.cycle_stage_progress ?? 0}
              timeLeft={data.cycle_stage_time_left ?? 0}
            />
          )}
          {content ?? children}
        </>
      }
    />
  );
};

/** Pasek od postępu z ostatnich danych do pełna w czasie, który etapowi został. */
const StageFill = (props: { progress: number; timeLeft: number }) => {
  const { progress, timeLeft } = props;
  const [full, setFull] = useState(false);

  useEffect(() => {
    setFull(false);
    let second = 0;
    // Dwie klatki: najpierw szerokość z danych bez przejścia, dopiero potem przejście do pełna
    const first = requestAnimationFrame(() => {
      second = requestAnimationFrame(() => setFull(true));
    });
    return () => {
      cancelAnimationFrame(first);
      cancelAnimationFrame(second);
    };
  }, [progress, timeLeft]);

  return (
    <div
      style={{
        position: 'absolute',
        left: 0,
        top: 0,
        bottom: 0,
        zIndex: -1,
        pointerEvents: 'none',
        background: 'rgba(30, 210, 30, 0.9)',
        width: full ? '100%' : `${progress * 100}%`,
        transition: full ? `width ${timeLeft / 10}s linear` : 'none',
      }}
    />
  );
};

import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: szef gangu wybiera nazwę i mundur (motyw „gang” jak okno roli gangu).
type UniformSet = {
  path: string;
  outfit: string;
  uniform_name: string;
  hat_name: string;
  uniform_icon: string;
  hat_icon: string;
};

type Data = {
  gang_name: string;
  gang_color: string;
  current_outfit: string;
  error: string | null;
  taken: string[];
  sets: UniformSet[];
};

const Sprite = (props: { icon: string; title: string }) => (
  <img
    src={`data:image/png;base64,${props.icon}`}
    title={props.title}
    style={{
      width: '64px',
      height: '64px',
      imageRendering: 'pixelated',
    }}
  />
);

export const GangIdentity = () => {
  const { act, data } = useBackend<Data>();
  const {
    gang_name,
    gang_color,
    current_outfit,
    error,
    taken = [],
    sets = [],
  } = data;
  const [name, setName] = useState(gang_name);
  const [picked, setPicked] = useState(
    sets.find((set) => set.outfit === current_outfit)?.path ?? '',
  );
  const available = sets.filter((set) => !taken.includes(set.outfit));

  return (
    <Window width={560} height={640} theme="gang">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item textAlign="center">
            <Box
              inline
              px={1.5}
              py={0.5}
              fontSize="24px"
              bold
              textColor={gang_color}
              style={{
                fontFamily: 'Georgia, serif',
                letterSpacing: '0.12em',
                border: `2px solid ${gang_color}`,
                textShadow: '2px 2px 0 #000',
                transform: 'rotate(-2deg)',
              }}
            >
              Gang {name || gang_name}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Section title="Nazwa gangu">
              <Input
                fluid
                maxLength={24}
                value={name}
                onChange={(value) => setName(value)}
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Mundur gangu"
              buttons={
                <Box color="label">
                  Pełny mundur na waszym terenie daje premie.
                </Box>
              }
            >
              <Box
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(3, 1fr)',
                  gap: '8px',
                }}
              >
                {available.map((set) => (
                  <Box
                    key={set.path}
                    p={1}
                    textAlign="center"
                    onClick={() => setPicked(set.path)}
                    style={{
                      cursor: 'pointer',
                      border: `2px solid ${
                        picked === set.path ? gang_color : 'rgba(0,0,0,0.4)'
                      }`,
                      background:
                        picked === set.path
                          ? 'rgba(255,255,255,0.08)'
                          : 'rgba(0,0,0,0.25)',
                    }}
                  >
                    <Box>
                      <Sprite
                        icon={set.uniform_icon}
                        title={set.uniform_name}
                      />
                      <Sprite icon={set.hat_icon} title={set.hat_name} />
                    </Box>
                    <Box fontSize="11px">{set.uniform_name}</Box>
                    <Box fontSize="11px" color="label">
                      {set.hat_name}
                    </Box>
                  </Box>
                ))}
              </Box>
            </Section>
          </Stack.Item>
          {!!error && (
            <Stack.Item>
              <Box color="bad" textAlign="center">
                {error}
              </Box>
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              fluid
              textAlign="center"
              fontSize="16px"
              disabled={!picked}
              onClick={() => act('confirm', { name, set: picked })}
            >
              Zatwierdź nazwę i mundur
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

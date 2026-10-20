import { Box, Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { MainData } from './data';

// AQUILA: tg ma osobny system modułów (sloty, "snowflake" UI dla każdego
// modułu). U nas moduły mają własne akcje jako odnośniki w get_equip_info(),
// więc pokazujemy ten HTML (odnośniki byond:// działają w TGUI), a obok
// przyciski wyboru i odłączenia.
export const ModulesPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const { modules = [], max_equip, has_cargo, cargo = [] } = data;
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Wyposażenie"
          buttons={
            <Box color="label" mt={0.5}>
              Wolne gniazda: {Math.max(max_equip - modules.length, 0)} /{' '}
              {max_equip}
            </Box>
          }
        >
          {!modules.length && (
            <NoticeBox>Brak zamontowanego wyposażenia.</NoticeBox>
          )}
          {modules.map((module) => (
            <Box
              key={module.ref}
              className="candystripe"
              p={0.5}
              style={
                module.selected
                  ? { borderLeft: '3px solid #20b142', paddingLeft: '6px' }
                  : undefined
              }
            >
              <Stack align="center">
                <Stack.Item grow>
                  {module.info ? (
                    <Box dangerouslySetInnerHTML={{ __html: module.info }} />
                  ) : (
                    <Box>{module.name}</Box>
                  )}
                </Stack.Item>
                {!!module.selectable && (
                  <Stack.Item>
                    <Button
                      icon="crosshairs"
                      selected={!!module.selected}
                      tooltip="Wybierz"
                      onClick={() => act('select_equip', { ref: module.ref })}
                    />
                  </Stack.Item>
                )}
                <Stack.Item>
                  <Button
                    icon="eject"
                    color="bad"
                    disabled={!module.detachable}
                    tooltip={
                      module.detachable
                        ? 'Odłącz'
                        : 'Wbudowane, nie da się odłączyć'
                    }
                    onClick={() => act('detach', { ref: module.ref })}
                  />
                </Stack.Item>
              </Stack>
            </Box>
          ))}
        </Section>
      </Stack.Item>
      {!!has_cargo && (
        <Stack.Item maxHeight="35%">
          <Section fill scrollable title="Ładownia">
            {!cargo.length && <Box color="label">Pusto.</Box>}
            {cargo.map((item) => (
              <Stack key={item.ref} align="center" className="candystripe">
                <Stack.Item grow>{item.name}</Stack.Item>
                <Stack.Item>
                  <Button
                    icon="box-open"
                    onClick={() => act('drop_from_cargo', { ref: item.ref })}
                  >
                    Wyładuj
                  </Button>
                </Stack.Item>
              </Stack>
            ))}
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

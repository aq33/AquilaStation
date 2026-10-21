import { Box, Button, Image, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  server_connected: BooleanLike;
  busy: BooleanLike;
  loaded_item: string | null;
  item_icon: string;
  indestructible: BooleanLike;
  already_deconstructed: BooleanLike;
  recoverable_points: string[] | null;
  // AQUILA: materiały odzyskiwane do połączonego protolathe
  item_mats: string[];
  node_data: NodeData[];
};

type NodeData = {
  node_name: string;
  node_path: string;
  node_hidden: BooleanLike;
  // AQUILA: u nas analiza może też przyspieszyć badanie węzła (boost)
  node_available: BooleanLike;
  node_boost: string[] | null;
};

export const DestructiveAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    server_connected,
    busy,
    indestructible,
    loaded_item,
    item_icon,
    already_deconstructed,
    recoverable_points,
    item_mats = [],
    node_data = [],
  } = data;
  if (!server_connected) {
    return (
      <Window width={400} height={300} title="Analizator destrukcyjny">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            Brak połączenia z konsolą B+R. Połącz analizator z konsolą.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  if (!loaded_item) {
    return (
      <Window width={400} height={300} title="Analizator destrukcyjny">
        <Window.Content>
          <NoticeBox textAlign="center" danger>
            Analizator jest pusty! <br />
            Włóż dowolny przedmiot, żeby sprawdzić, co można z niego wyciągnąć.
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={400} height={360} title="Analizator destrukcyjny">
      <Window.Content scrollable>
        <Section
          title={loaded_item}
          buttons={
            <Button
              icon="eject"
              disabled={!!busy}
              tooltip="Wysuwa przedmiot znajdujący się w maszynie."
              onClick={() => act('eject_item')}
            />
          }
        >
          <Image
            src={`data:image/jpeg;base64,${item_icon}`}
            height="64px"
            width="64px"
            verticalAlign="middle"
          />
          {item_mats.length > 0 && (
            <Box mt={1}>
              <Box bold>Materiały do odzyskania:</Box>
              {item_mats.map((line) => (
                <Box key={line}>{line}</Box>
              ))}
            </Box>
          )}
        </Section>
        <Section title="Metody rozbiórki">
          {!indestructible && (
            <NoticeBox textAlign="center" danger>
              Tego przedmiotu nie da się zniszczyć!
            </NoticeBox>
          )}
          {!!indestructible && (
            <>
              {!!recoverable_points?.length && !already_deconstructed && (
                <>
                  <Box fontSize="14px">Punkty badań z rozbiórki</Box>
                  {recoverable_points.map((line) => (
                    <Box key={line}>{line}</Box>
                  ))}
                </>
              )}
              <Button.Confirm
                icon="hammer"
                mt={1}
                disabled={!!busy}
                confirmContent="Na pewno?"
                tooltip={
                  already_deconstructed
                    ? 'Ten przedmiot był już analizowany i nie da więcej punktów.'
                    : 'Niszczy przedmiot znajdujący się w maszynie.'
                }
                onClick={() => act('deconstruct')}
              >
                Zniszcz
              </Button.Confirm>
              {node_data.map((node) => (
                <Box key={node.node_path} mt={1}>
                  <Button.Confirm
                    icon="cash-register"
                    disabled={!node.node_available || !!busy}
                    confirmContent="Na pewno?"
                    tooltip={
                      node.node_available
                        ? node.node_hidden
                          ? 'Zniszcz przedmiot, żeby odkryć ten węzeł.'
                          : 'Zniszcz przedmiot, żeby przyspieszyć badanie tego węzła.'
                        : 'Ten węzeł jest już zbadany lub przyspieszony.'
                    }
                    onClick={() =>
                      act('deconstruct', { deconstruct_path: node.node_path })
                    }
                  >
                    {node.node_name}
                  </Button.Confirm>
                  {!!node.node_boost?.length && (
                    <Box inline ml={1} color="label">
                      {node.node_boost.join(', ')}
                    </Box>
                  )}
                </Box>
              ))}
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

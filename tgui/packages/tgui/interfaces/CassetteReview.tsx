// AQUILA - recenzja kasety przez admina (port z Monkestation, CassetteReview.tsx)
import { Box, Button, LabeledList, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { formatLength } from './CassetteDeck';

type Song = {
  name: string;
  url: string;
  length: number;
  artist?: string;
};

type Side = {
  name: string;
  songs: Song[];
};

type Data = {
  submitter: string;
  name: string;
  desc: string;
  author: string;
  sides: Side[];
  can_approve: boolean;
};

export const CassetteReview = () => {
  const { act, data } = useBackend<Data>();
  const { submitter, name, desc, author, sides, can_approve } = data;
  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Section
          title={name}
          buttons={
            <>
              <Button
                icon="check"
                color="good"
                disabled={!can_approve}
                onClick={() => act('approve')}
              >
                Zatwierdź
              </Button>
              <Button
                icon="xmark"
                color="bad"
                disabled={!can_approve}
                onClick={() => act('deny')}
              >
                Odrzuć
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Zgłasza">{submitter}</LabeledList.Item>
            <LabeledList.Item label="Postać">{author}</LabeledList.Item>
            <LabeledList.Item label="Opis">{desc}</LabeledList.Item>
          </LabeledList>
          {!can_approve && (
            <Box mt={1} color="average">
              Zatwierdzać i odrzucać może tylko admin z uprawnieniem FUN.
            </Box>
          )}
        </Section>
        {sides.map((side) => (
          <Section key={side.name} title={`Strona ${side.name}`}>
            {side.songs.length === 0 ? (
              <Box color="label">Pusta.</Box>
            ) : (
              <Table>
                {side.songs.map((song, index) => (
                  <Table.Row key={index} className="candystripe">
                    <Table.Cell collapsing color="label">
                      {index + 1}.
                    </Table.Cell>
                    <Table.Cell>
                      {song.name}
                      {!!song.artist && <Box color="label">{song.artist}</Box>}
                      <Box color="label" fontSize="0.85em">
                        {song.url}
                      </Box>
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      {formatLength(song.length)}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

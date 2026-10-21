import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  answers: Answer[];
  question: string;
  shaking: BooleanLike;
};

type Answer = {
  amount: number;
  answer: string;
  selected: BooleanLike;
};

export function EightBallVote(props) {
  const { data } = useBackend<Data>();
  const { shaking } = data;

  return (
    <Window width={400} height={shaking ? 600 : 70}>
      <Window.Content scrollable={!!shaking}>
        {!shaking ? (
          <NoticeBox danger textAlign="center">
            Nikt teraz nie zadaje pytania.
          </NoticeBox>
        ) : (
          <>
            <NoticeBox success textAlign="center">
              Ktoś właśnie zadaje pytanie!
            </NoticeBox>
            <EightBallVoteQuestion />
          </>
        )}
      </Window.Content>
    </Window>
  );
}

function EightBallVoteQuestion(props) {
  const { act, data } = useBackend<Data>();
  const { shaking, question, answers = [] } = data;

  // AQUILA EDIT - nasza kula ma 20 odpowiedzi, więc zostaje pionowa lista
  return (
    <Section>
      <Box bold textAlign="center" fontSize="16px" m={1}>
        &quot;{question}&quot;
      </Box>
      <Table>
        {answers.map((answer) => (
          <Table.Row key={answer.answer}>
            <Table.Cell>
              <Button
                fluid
                bold
                disabled={!shaking}
                selected={answer.selected}
                fontSize="16px"
                lineHeight="24px"
                textAlign="center"
                mb={1}
                onClick={() =>
                  act('vote', {
                    answer: answer.answer,
                  })
                }
              >
                {toTitleCase(answer.answer)}
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>
              <Box bold textAlign="center" fontSize="20px" ml={1}>
                {answer.amount}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

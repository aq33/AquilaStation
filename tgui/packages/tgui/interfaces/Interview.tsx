import { type ReactNode, useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  NoticeBox,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  connected: BooleanLike;
  is_admin: BooleanLike;
  questions: Question[];
  queue_pos: number;
  read_only: BooleanLike;
  status: string;
  welcome_message: string;
};

type Question = {
  qidx: number;
  question: string;
  response: string | null;
};

enum STATUS {
  Approved = 'interview_approved',
  Denied = 'interview_denied',
}

// Matches a complete markdown-style link, capturing the whole [...](...)
const linkRegex = /(\[[^[]+\]\([^)]+\))/;
// Decomposes a markdown-style link into the link and display text
const linkDecomposeRegex = /\[([^[]+)\]\(([^)]+)\)/;

// Renders any markdown-style links within a provided body of text
const linkifyText = (text: string) => {
  const parts: ReactNode[] = text.split(linkRegex);
  for (let i = 1; i < parts.length; i += 2) {
    const match = linkDecomposeRegex.exec(parts[i] as string);
    if (!match) continue;

    parts[i] = (
      <a key={`link${i}`} href={match[2]}>
        {match[1]}
      </a>
    );
  }
  return parts;
};

export const Interview = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    connected,
    is_admin,
    questions = [],
    queue_pos,
    read_only,
    status,
    welcome_message = '',
  } = data;

  const allAnswered = questions.every((q) => q.response);
  const numAnswered = questions.filter((q) => q.response)?.length;

  return (
    <Window
      width={550}
      height={600}
      canClose={is_admin || status === 'interview_approved'}
    >
      <Window.Content scrollable>
        {(!read_only && (
          <Section title="Witaj!">
            <p>{linkifyText(welcome_message)}</p>
          </Section>
        )) || <RenderedStatus status={status} queue_pos={queue_pos} />}
        <Section
          title="Ankieta"
          buttons={
            <span>
              <Button
                onClick={() => act('submit')}
                disabled={read_only || !allAnswered || !questions.length}
                icon="envelope"
                tooltip={
                  !allAnswered &&
                  `Odpowiedz na wszystkie pytania.
                     ${numAnswered} / ${questions.length}`
                }
              >
                {read_only ? 'Wysłano' : 'Wyślij'}
              </Button>
              {!!is_admin && status === 'interview_pending' && (
                <span>
                  <Button disabled={!connected} onClick={() => act('adminpm')}>
                    PW do gracza
                  </Button>
                  <Button color="good" onClick={() => act('approve')}>
                    Zatwierdź
                  </Button>
                  <Button color="bad" onClick={() => act('deny')}>
                    Odrzuć
                  </Button>
                </span>
              )}
            </span>
          }
        >
          {!read_only && (
            <>
              <Box as="p" color="label">
                Odpowiedz na poniższe pytania.
                <ul>
                  <li>
                    Odpowiedź zapiszesz klawiszem Enter albo przyciskiem zapisu.
                  </li>
                  <li>Odpowiedzi możesz poprawiać aż do wysłania ankiety.</li>
                  <li>Gdy skończysz, naciśnij WYŚLIJ.</li>
                </ul>
              </Box>
              <NoticeBox info align="center">
                Po wysłaniu nie będzie można zmienić odpowiedzi.
              </NoticeBox>
            </>
          )}
          {questions.map((question) => (
            <QuestionArea key={question.qidx} {...question} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RenderedStatus = (props: { status: string; queue_pos: number }) => {
  const { status, queue_pos } = props;

  switch (status) {
    case STATUS.Approved:
      return <NoticeBox success>Ankieta została zatwierdzona.</NoticeBox>;
    case STATUS.Denied:
      return <NoticeBox danger>Ankieta została odrzucona.</NoticeBox>;
    default:
      return (
        <NoticeBox info>
          Twoje odpowiedzi zostały wysłane. Jesteś na pozycji {queue_pos} w
          kolejce.
        </NoticeBox>
      );
  }
};

const QuestionArea = (props: Question) => {
  const { qidx, question, response } = props;
  const { act, data } = useBackend<Data>();
  const { is_admin, read_only } = data;

  const [userInput, setUserInput] = useState(response);

  const saveResponse = () => {
    act('update_answer', {
      qidx,
      answer: userInput,
    });
  };

  const changedResponse = userInput !== response;

  const saveAvailable = !read_only && !!userInput && changedResponse;

  const isSaved = !!response && !changedResponse;

  return (
    <Section
      title={`Pytanie ${qidx}`}
      buttons={
        <Button
          disabled={!saveAvailable}
          onClick={saveResponse}
          icon={isSaved ? 'check' : 'save'}
        >
          {isSaved ? 'Zapisano' : 'Zapisz'}
        </Button>
      }
    >
      <p>{linkifyText(question)}</p>
      {read_only || is_admin ? (
        <BlockQuote>{response || 'Brak odpowiedzi.'}</BlockQuote>
      ) : (
        <TextArea
          fluid
          height={10}
          maxLength={500}
          onChange={setUserInput}
          onEnter={saveResponse}
          placeholder="Wpisz tu odpowiedź, maksymalnie 500 znaków. Enter zapisuje."
          value={response || undefined}
        />
      )}
    </Section>
  );
};

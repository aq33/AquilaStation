import {
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  pen: string;
  integrated_pen: BooleanLike;
  top_paper: string;
  top_paper_ref: string;
  paper: string[];
  paper_ref: string[];
};

export const Clipboard = (props) => {
  const { act, data } = useBackend<Data>();
  const { pen, integrated_pen, top_paper, top_paper_ref, paper, paper_ref } =
    data;
  return (
    <Window title="Podkładka" width={400} height={500}>
      <Window.Content backgroundColor="#704D25" scrollable>
        <Section>
          {pen ? (
            <LabeledList>
              <LabeledList.Item
                label="Długopis"
                buttons={
                  <Button
                    icon="eject"
                    tooltip="Wyjmij długopis"
                    onClick={() => act('remove_pen')}
                  />
                }
              >
                {pen}
              </LabeledList.Item>
            </LabeledList>
          ) : integrated_pen ? (
            <Box color="white" align="center">
              W klips podkładki jest wbudowany długopis.
            </Box>
          ) : (
            <Box color="white" align="center">
              Brak długopisu!
            </Box>
          )}
        </Section>
        <Divider />
        {top_paper ? (
          <Flex
            color="black"
            backgroundColor="white"
            style={{ padding: '2px 2px 0 2px' }}
          >
            <Flex.Item align="center" grow={1}>
              <Box align="center">{top_paper}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon={pen ? 'pen' : 'eye'}
                tooltip={pen ? 'Pisz' : 'Czytaj'}
                onClick={() => act('edit_paper', { ref: top_paper_ref })}
              />
              <Button
                icon="tag"
                tooltip="Zmień nazwę"
                onClick={() => act('rename_paper', { ref: top_paper_ref })}
              />
              <Button
                icon="eject"
                tooltip="Wyjmij"
                onClick={() => act('remove_paper', { ref: top_paper_ref })}
              />
            </Flex.Item>
          </Flex>
        ) : (
          <Section>
            <Box color="white" align="center">
              Podkładka jest pusta!
            </Box>
          </Section>
        )}
        {paper.length > 0 && <Divider />}
        {paper.map((paper_item, index) => (
          <Flex
            key={paper_ref[index]}
            color="black"
            backgroundColor="white"
            style={{ padding: '2px 2px 0 2px' }}
            mb={0.5}
          >
            <Flex.Item>
              <Button
                icon="chevron-up"
                tooltip="Na wierzch"
                color="transparent"
                iconColor="black"
                onClick={() => act('move_top_paper', { ref: paper_ref[index] })}
              />
            </Flex.Item>
            <Flex.Item align="center" grow={1}>
              <Box align="center">{paper_item}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon={pen ? 'pen' : 'eye'}
                tooltip={pen ? 'Pisz' : 'Czytaj'}
                onClick={() => act('edit_paper', { ref: paper_ref[index] })}
              />
              <Button
                icon="tag"
                tooltip="Zmień nazwę"
                onClick={() => act('rename_paper', { ref: paper_ref[index] })}
              />
              <Button
                icon="eject"
                tooltip="Wyjmij"
                onClick={() => act('remove_paper', { ref: paper_ref[index] })}
              />
            </Flex.Item>
          </Flex>
        ))}
      </Window.Content>
    </Window>
  );
};

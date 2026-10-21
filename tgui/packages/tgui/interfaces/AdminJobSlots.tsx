import { Box, Button, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Job = {
  title: string;
  current: number;
  total: number;
};

type Data = {
  jobs: Job[];
};

export const AdminJobSlots = (props) => {
  const { act, data } = useBackend<Data>();
  const { jobs = [] } = data;
  return (
    <Window
      title="Wolne stanowiska"
      theme="admin"
      width={560}
      height={Math.min(120 + jobs.length * 26, 680)}
    >
      <Window.Content scrollable>
        <Section>
          <Table>
            <Table.Row header>
              <Table.Cell>Stanowisko</Table.Cell>
              <Table.Cell collapsing textAlign="center">
                Zajęte / limit
              </Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {jobs.map((job) => {
              const unlimited = job.total < 0;
              return (
                <Table.Row key={job.title} className="candystripe">
                  <Table.Cell py={0.25}>{job.title}</Table.Cell>
                  <Table.Cell collapsing textAlign="center">
                    {job.current} /{' '}
                    {unlimited ? (
                      <Box inline color="good">
                        bez limitu
                      </Box>
                    ) : (
                      job.total
                    )}
                  </Table.Cell>
                  <Table.Cell collapsing style={{ whiteSpace: 'nowrap' }}>
                    {unlimited ? (
                      <Button
                        onClick={() => act('limit', { title: job.title })}
                      >
                        Ogranicz
                      </Button>
                    ) : (
                      <>
                        <Button
                          onClick={() => act('custom', { title: job.title })}
                        >
                          Ustaw
                        </Button>
                        <Button
                          icon="plus"
                          onClick={() => act('add', { title: job.title })}
                        >
                          1
                        </Button>
                        <Button
                          icon="minus"
                          disabled={job.total <= job.current}
                          onClick={() => act('remove', { title: job.title })}
                        >
                          1
                        </Button>
                        <Button
                          onClick={() => act('unlimit', { title: job.title })}
                        >
                          Bez limitu
                        </Button>
                      </>
                    )}
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

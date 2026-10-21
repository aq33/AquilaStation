import { sortBy } from 'es-toolkit';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Modal,
  Section,
  VirtualList,
} from 'tgui-core/components';

import { useRemappedBackend } from '../helpers';
import { TechNode } from '../nodes/TechNode';
import type { TechwebNode } from '../types';

export function TechwebDesignDisk(props) {
  const { act, data } = useRemappedBackend();
  const { design_cache, researched_designs, d_disk } = data;
  // AQUILA: zapisywanie zbadanych projektów na dysk (z NSV13)
  const [selectedDesign, setSelectedDesign] = useState<string | null>(null);
  const [slotToWrite, setSlotToWrite] = useState(-1);

  if (!d_disk) return;

  const { blueprints } = d_disk;

  const designOptions = sortBy(
    Object.keys(researched_designs || {})
      .filter((id) => id.toLowerCase() !== 'error' && !!design_cache[id])
      .map((id) => ({ displayText: design_cache[id].name, value: id })),
    [(x) => x.displayText],
  );

  function closeModal() {
    setSlotToWrite(-1);
    setSelectedDesign(null);
  }

  return (
    <Section fill scrollable>
      {slotToWrite >= 0 && (
        <Modal width="20em">
          <Flex direction="column" className="Techweb__DesignModal">
            <Flex.Item>Wybierz projekt do zapisania...</Flex.Item>
            <Flex.Item>
              <Dropdown
                width="100%"
                options={designOptions}
                selected={selectedDesign}
                displayText={
                  selectedDesign
                    ? design_cache[selectedDesign]?.name
                    : undefined
                }
                placeholder="Brak wyboru"
                onSelected={(val) => setSelectedDesign(val)}
              />
            </Flex.Item>
            <Flex.Item align="center">
              <Button onClick={closeModal}>Anuluj</Button>
              <Button
                disabled={selectedDesign === null}
                onClick={() => {
                  act('writeDesign', {
                    slot: slotToWrite + 1,
                    selectedDesign: selectedDesign,
                  });
                  closeModal();
                }}
              >
                Zapisz
              </Button>
            </Flex.Item>
          </Flex>
        </Modal>
      )}
      {blueprints.map((x, i) => (
        <Section
          key={i}
          title={`Slot ${i + 1}`}
          buttons={
            <>
              {x !== null && (
                <Button
                  icon="upload"
                  onClick={() => act('uploadDesignSlot', { slot: i + 1 })}
                >
                  Wgraj do sieci
                </Button>
              )}
              <Button icon="save" onClick={() => setSlotToWrite(i)}>
                {x !== null ? 'Nadpisz slot' : 'Zapisz projekt w slocie'}
              </Button>
              {x !== null && (
                <Button
                  icon="trash"
                  onClick={() => act('clearDesignSlot', { slot: i + 1 })}
                >
                  Wyczyść slot
                </Button>
              )}
            </>
          }
        >
          {x === null ? (
            'Pusty'
          ) : (
            <>
              Zawiera projekt: <b>{design_cache[x]?.name ?? x}</b>
              <br />
              <Box
                inline
                className={`${design_cache[x]?.class} Techweb__DesignIcon`}
              />
            </>
          )}
        </Section>
      ))}
    </Section>
  );
}

export function TechwebTechDisk(props) {
  const { data } = useRemappedBackend();
  const { t_disk } = data;
  if (!t_disk) return;

  const { stored_research } = t_disk;

  return (
    <Section scrollable fill>
      <VirtualList>
        {Object.keys(stored_research)
          .map((x) => ({ id: x }) as TechwebNode)
          .map((n) => (
            <TechNode key={n.id} nocontrols node={n} />
          ))}
      </VirtualList>
    </Section>
  );
}

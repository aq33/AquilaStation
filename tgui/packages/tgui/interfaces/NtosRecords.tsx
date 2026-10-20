import { useState } from 'react';
import { Box, Icon, Input, Section } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type SecurityRecord = {
  id: string;
  name: string;
  rank: string;
  species: string;
  sex: string;
  age: string;
  fingerprint: string;
  wanted: string | null;
};

type MedicalRecord = {
  id: string;
  name: string;
  rank: string;
  species: string;
  sex: string;
  age: string;
  b_dna: string;
  bloodtype: string;
  mi_dis: string;
  ma_dis: string;
  notes: string;
  cnotes: string;
};

type Data =
  | {
      mode: 'security';
      records: SecurityRecord[];
    }
  | {
      mode: 'medical';
      records: MedicalRecord[];
    };

/** Wpisy rozdzielane w DM znacznikiem <br> wypisuje jako punkty */
const BulletList = (props: { text?: string }) => {
  const { text } = props;
  if (!text) {
    return <Box>&#8226; brak</Box>;
  }
  return (
    <>
      {text.split('<br>').map((entry, index) => (
        <Box key={index}>&#8226; {entry}</Box>
      ))}
    </>
  );
};

export const NtosRecords = (props) => {
  const { data } = useBackend<Data>();
  const [searchTerm, setSearchTerm] = useState('');
  const { mode, records = [] } = data;

  const isMatchingSearchTerms = createSearch(searchTerm);
  const isHidden = (searchable: string) =>
    !(searchTerm === '' || isMatchingSearchTerms(searchable));

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">AKTA PERSONELU NANOTRASEN (POUFNE)</Section>
        <Section>
          <Input
            placeholder="Filtruj wyniki..."
            value={searchTerm}
            fluid
            textAlign="center"
            onChange={setSearchTerm}
            expensive
          />
        </Section>
        {mode === 'security' &&
          (records as SecurityRecord[]).map((record) => (
            <Section
              key={record.id}
              style={
                isHidden(
                  [
                    record.name,
                    record.rank,
                    record.species,
                    record.sex,
                    record.age,
                    record.fingerprint,
                  ].join(' '),
                )
                  ? { display: 'none' }
                  : undefined
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Stanowisko: {record.rank}
              <br />
              Gatunek: {record.species}
              <br />
              Płeć: {record.sex}
              <br />
              Wiek: {record.age}
              <br />
              Odcisk palca: {record.fingerprint}
              <br />
              <br />
              Status karny: {record.wanted || 'USUNIĘTY'}
            </Section>
          ))}
        {mode === 'medical' &&
          (records as MedicalRecord[]).map((record) => (
            <Section
              key={record.id}
              style={
                isHidden(
                  [
                    record.name,
                    record.rank,
                    record.species,
                    record.sex,
                    record.age,
                    record.bloodtype,
                    record.mi_dis,
                    record.ma_dis,
                  ].join(' '),
                )
                  ? { display: 'none' }
                  : undefined
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Stanowisko: {record.rank}
              <br />
              Gatunek: {record.species}
              <br />
              Płeć: {record.sex}
              <br />
              Wiek: {record.age}
              <br />
              DNA: {record.b_dna}
              <br />
              <br />
              Grupa krwi: {record.bloodtype}
              <br />
              Drobne niepełnosprawności:
              <BulletList text={record.mi_dis} />
              Poważne niepełnosprawności:
              <BulletList text={record.ma_dis} />
              <br />
              Notatki: {record.notes}
              {!!record.cnotes && (
                <>
                  <br />
                  Notatki cd.: {record.cnotes}
                </>
              )}
            </Section>
          ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

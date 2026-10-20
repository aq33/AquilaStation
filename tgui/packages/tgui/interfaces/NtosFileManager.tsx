import { Button, NoticeBox, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type FileEntry = {
  name: string;
  type: string;
  size: number;
  undeletable: BooleanLike;
  alert_able?: BooleanLike;
  alert_silenced?: BooleanLike;
};

type Data = {
  error?: string;
  usbconnected: BooleanLike;
  files: FileEntry[];
  usbfiles: FileEntry[];
};

// tg ma tu jeszcze drukowanie plików graficznych; u nas pliki nie mają obrazów, więc go nie ma.
export const NtosFileManager = (props) => {
  const { act, data } = useBackend<Data>();
  const { error, usbconnected, files = [], usbfiles = [] } = data;
  return (
    <NtosWindow>
      <NtosWindow.Content scrollable>
        {!!error && <NoticeBox danger>{error}</NoticeBox>}
        <Section>
          <FileTable
            files={files}
            usbconnected={usbconnected}
            onUpload={(file) => act('PRG_copytousb', { name: file })}
            onDelete={(file) => act('PRG_deletefile', { name: file })}
            onRename={(file, newName) =>
              act('PRG_renamefile', {
                name: file,
                new_name: newName,
              })
            }
            onToggleSilence={(file) => act('PRG_togglesilence', { name: file })}
          />
        </Section>
        {!!usbconnected && (
          <Section title="Dysk danych">
            <FileTable
              usbmode
              files={usbfiles}
              usbconnected={usbconnected}
              onUpload={(file) => act('PRG_copyfromusb', { name: file })}
              onDelete={(file) => act('PRG_usbdeletefile', { name: file })}
              onRename={(file, newName) =>
                act('PRG_usbrenamefile', {
                  name: file,
                  new_name: newName,
                })
              }
            />
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type FileTableProps = {
  files: FileEntry[];
  usbconnected: BooleanLike;
  usbmode?: BooleanLike;
  onUpload: (file: string) => void;
  onDelete: (file: string) => void;
  onRename: (file: string, newName: string) => void;
  onToggleSilence?: (file: string) => void;
};

const FileTable = (props: FileTableProps) => {
  const {
    files = [],
    usbconnected,
    usbmode,
    onUpload,
    onDelete,
    onRename,
    onToggleSilence,
  } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell>Plik</Table.Cell>
        <Table.Cell collapsing>Typ</Table.Cell>
        <Table.Cell collapsing>Rozmiar</Table.Cell>
      </Table.Row>
      {files.map((file) => (
        <Table.Row key={file.name} className="candystripe">
          <Table.Cell>
            {!file.undeletable ? (
              <Button.Input
                fluid
                value={file.name}
                tooltip="Zmień nazwę"
                onCommit={(value) => onRename(file.name, value)}
              />
            ) : (
              file.name
            )}
          </Table.Cell>
          <Table.Cell>{file.type}</Table.Cell>
          <Table.Cell>{file.size}</Table.Cell>
          <Table.Cell collapsing>
            {!!file.alert_able && !!onToggleSilence && (
              <Button
                icon={file.alert_silenced ? 'bell-slash' : 'bell'}
                color={file.alert_silenced ? 'red' : 'default'}
                tooltip={
                  file.alert_silenced
                    ? 'Włącz powiadomienia'
                    : 'Wycisz powiadomienia'
                }
                onClick={() => onToggleSilence(file.name)}
              />
            )}
            {!file.undeletable && (
              <>
                <Button.Confirm
                  icon="trash"
                  confirmIcon="times"
                  confirmContent=""
                  tooltip="Usuń"
                  onClick={() => onDelete(file.name)}
                />
                {!!usbconnected &&
                  (usbmode ? (
                    <Button
                      icon="download"
                      tooltip="Skopiuj na dysk komputera"
                      onClick={() => onUpload(file.name)}
                    />
                  ) : (
                    <Button
                      icon="upload"
                      tooltip="Skopiuj na dysk danych"
                      onClick={() => onUpload(file.name)}
                    />
                  ))}
              </>
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};

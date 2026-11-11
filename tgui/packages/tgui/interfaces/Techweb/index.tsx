import { NtosWindow, Window } from '../../layouts';
import { isTechwebReady, useRemappedBackend } from './helpers';
import { TechwebStart } from './Start';

export function Techweb(props) {
  useRemappedBackend();
  if (!isTechwebReady()) {
    return null;
  }
  return (
    <Window width={1200} height={800}>
      <Window.Content>
        <TechwebStart />
      </Window.Content>
    </Window>
  );
}

export function AppTechweb(props) {
  useRemappedBackend();
  if (!isTechwebReady()) {
    return null;
  }
  return (
    <NtosWindow width={640} height={735}>
      <NtosWindow.Content>
        <TechwebStart />
      </NtosWindow.Content>
    </NtosWindow>
  );
}

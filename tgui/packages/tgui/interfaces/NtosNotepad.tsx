/**
 * @file
 * @copyright 2022 raffclar
 * @license MIT
 */

import { useEffect, useRef, useState } from 'react';
import { Box, Dialog, Divider, MenuBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

const DEFAULT_DOCUMENT_NAME = 'Notatki';

type PartiallyUnderlinedProps = {
  str: string;
  indexStart: number;
};

const PartiallyUnderlined = (props: PartiallyUnderlinedProps) => {
  const { str, indexStart } = props;
  const start = str.substring(0, indexStart);
  const underlined = str.substring(indexStart, indexStart + 1);
  const end = indexStart < str.length - 1 ? str.substring(indexStart + 1) : '';
  return (
    <>
      {start}
      <span style={{ textDecoration: 'underline' }}>{underlined}</span>
      {end}
    </>
  );
};

enum Dialogs {
  NONE = 0,
  UNSAVED_CHANGES = 1,
  ABOUT = 3,
}

type MenuBarProps = {
  onSave: () => void;
  onExit: () => void;
  onNewNote: () => void;
  onCutSelected: () => void;
  onCopySelected: () => void;
  onPasteSelected: () => void;
  onDeleteSelected: () => void;
  // AQUILA: podgląd zeskanowanej kartki trzymanej w tablecie
  hasPaper: boolean;
  onShowPaper: () => void;
  showStatusBar: boolean;
  setShowStatusBar: (value: boolean) => void;
  wordWrap: boolean;
  setWordWrap: (value: boolean) => void;
  aboutNotepadDialog: () => void;
};

const NtosNotepadMenuBar = (props: MenuBarProps) => {
  const {
    onSave,
    onExit,
    onNewNote,
    onCutSelected,
    onCopySelected,
    onPasteSelected,
    onDeleteSelected,
    hasPaper,
    onShowPaper,
    setShowStatusBar,
    showStatusBar,
    wordWrap,
    setWordWrap,
    aboutNotepadDialog,
  } = props;
  const [openOnHover, setOpenOnHover] = useState(false);
  const [openMenuBar, setOpenMenuBar] = useState<string | null>(null);
  const onMenuItemClick = (value) => {
    setOpenOnHover(false);
    setOpenMenuBar(null);
    switch (value) {
      case 'save':
        onSave();
        break;
      case 'exit':
        onExit();
        break;
      case 'new':
        onNewNote();
        break;
      case 'paper':
        onShowPaper();
        break;
      case 'cut':
        onCutSelected();
        break;
      case 'copy':
        onCopySelected();
        break;
      case 'paste':
        onPasteSelected();
        break;
      case 'delete':
        onDeleteSelected();
        break;
      case 'statusBar':
        setShowStatusBar(!showStatusBar);
        break;
      case 'wordWrap':
        setWordWrap(!wordWrap);
        break;
      case 'aboutNotepad':
        aboutNotepadDialog();
        break;
    }
  };
  // Adds the key using the value
  const getMenuItemProps = (value: string, displayText: string) => {
    return {
      key: value,
      value,
      displayText,
      onClick: onMenuItemClick,
    };
  };
  const itemProps = {
    openOnHover,
    setOpenOnHover,
    openMenuBar,
    setOpenMenuBar,
  };

  return (
    <MenuBar>
      <MenuBar.Dropdown
        entry="file"
        openWidth="22rem"
        display={<PartiallyUnderlined str="Plik" indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('new', 'Nowy')} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('save', 'Zapisz')} />
        {hasPaper && (
          <MenuBar.Dropdown.MenuItem
            {...getMenuItemProps('paper', 'Pokaż zeskanowaną kartkę')}
          />
        )}
        <MenuBar.Dropdown.Separator key="firstSep" />
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('exit', 'Zamknij...')}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="edit"
        openWidth="22rem"
        display={<PartiallyUnderlined str="Edycja" indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('cut', 'Wytnij')} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('copy', 'Kopiuj')} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('paste', 'Wklej')} />
        <MenuBar.Dropdown.MenuItem {...getMenuItemProps('delete', 'Usuń')} />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="format"
        openWidth="15rem"
        display={<PartiallyUnderlined str="Format" indexStart={1} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItemToggle
          checked={wordWrap}
          {...getMenuItemProps('wordWrap', 'Zawijanie wierszy')}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="view"
        openWidth="15rem"
        display={<PartiallyUnderlined str="Widok" indexStart={0} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItemToggle
          checked={showStatusBar}
          {...getMenuItemProps('statusBar', 'Pasek stanu')}
        />
      </MenuBar.Dropdown>
      <MenuBar.Dropdown
        entry="help"
        openWidth="17rem"
        display={<PartiallyUnderlined str="Pomoc" indexStart={2} />}
        {...itemProps}
      >
        <MenuBar.Dropdown.MenuItem
          {...getMenuItemProps('aboutNotepad', 'O Notatniku')}
        />
      </MenuBar.Dropdown>
    </MenuBar>
  );
};

type Statuses = {
  line: number;
  column: number;
};

type StatusBarProps = {
  statuses: Statuses;
};

const StatusBar = (props: StatusBarProps) => {
  const { statuses } = props;
  return (
    <Box className="NtosNotepad__StatusBar">
      <Box className="NtosNotepad__StatusBar__entry" minWidth="15rem">
        Wiersz {statuses.line}, kol. {statuses.column}
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="5rem">
        100%
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">
        NtOS (LF)
      </Box>
      <Box className="NtosNotepad__StatusBar__entry" minWidth="12rem">
        UTF-8
      </Box>
    </Box>
  );
};

const getStatusCounts = (text: string, selectionStart: number): Statuses => {
  const lines = text.substring(0, selectionStart).split('\n');
  return {
    line: lines.length,
    column: lines[lines.length - 1].length + 1,
  };
};

type NotePadTextAreaProps = {
  text: string;
  wordWrap: boolean;
  setText: (text: string) => void;
  setStatuses: (statuses: Statuses) => void;
};

function NotePadTextArea(props: NotePadTextAreaProps) {
  const { text, setText, wordWrap, setStatuses } = props;

  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  function handleEvent(event) {
    const area = event.target as HTMLTextAreaElement;
    setStatuses(getStatusCounts(area.value, area.selectionStart));
  }

  return (
    <textarea
      autoFocus
      className="NtosNotepad__textarea"
      onClick={handleEvent}
      onMouseUp={handleEvent}
      onKeyUp={handleEvent}
      onChange={(event) => {
        setText(event.currentTarget.value);
        handleEvent(event);
      }}
      ref={textareaRef}
      spellCheck={false}
      style={{
        whiteSpace: wordWrap ? 'pre-wrap' : 'pre',
        overflow: wordWrap ? 'hidden auto' : 'auto',
      }}
      value={text}
    />
  );
}

type AboutDialogProps = {
  close: () => void;
  owner: string | null;
};

const AboutDialog = (props: AboutDialogProps) => {
  const { close, owner } = props;
  const paragraphStyle = { padding: '.5rem 1rem 0 2rem' };

  return (
    <Dialog title="O Notatniku" onClose={close} width="500px">
      <div className="Dialog__body">
        <span className="NtosNotepad__AboutDialog__logo">NtOS</span>
        <Divider />
        <Box className="NtosNotepad__AboutDialog__text">
          <span style={paragraphStyle}>Nanotrasen NtOS</span>
          <span style={paragraphStyle}>
            Wersja 7815696ecbf1c96e6894b779456d330e
          </span>
          <span style={paragraphStyle}>
            &copy; NT Corporation. Wszelkie prawa zastrzeżone.
          </span>
          <span style={{ padding: '3rem 1rem 3rem 2rem' }}>
            System operacyjny NtOS i jego interfejs są chronione znakami
            towarowymi oraz innymi istniejącymi lub zgłoszonymi prawami
            własności intelektualnej w Układzie Słonecznym i innych regionach.
          </span>
          <span
            style={{
              padding: '3rem 1rem 0.5rem 2rem',
              maxWidth: '35rem',
            }}
          >
            Ten produkt jest licencjonowany na warunkach NT Corporation dla:
          </span>
          <span style={{ padding: '0 1rem 0 4rem' }}>
            {owner || 'Nieznany'}
          </span>
        </Box>
      </div>
      <div className="Dialog__footer">
        <Dialog.Button onClick={close}>OK</Dialog.Button>
      </div>
    </Dialog>
  );
};

type NoteData = {
  note: string | null;
  // AQUILA: zeskanowana kartka w tablecie
  has_paper: boolean;
  owner: string | null;
};
type RetryActionType = (retrying?: boolean) => void;

export const NtosNotepad = (props) => {
  const { act, data } = useBackend<NoteData>();
  const { note: backendNote, has_paper, owner } = data;
  const note = backendNote || '';
  const [originalText, setOriginalText] = useState(note);
  const [text, setText] = useState(note);
  const [statuses, setStatuses] = useState<Statuses>({
    line: 0,
    column: 0,
  });
  const [activeDialog, setActiveDialog] = useState(Dialogs.NONE);
  const [retryAction, setRetryAction] = useState<RetryActionType | null>(null);
  const [showStatusBar, setShowStatusBar] = useState(true);
  const [wordWrap, setWordWrap] = useState(true);

  useEffect(() => {
    setText(note);
    setOriginalText(note);
    setStatuses(getStatusCounts(note, note.length));
  }, [note]);

  const handleCloseDialog = () => {
    setRetryAction(null);
    setActiveDialog(Dialogs.NONE);
  };
  // Notatka jest trzymana w tablecie (nasz DM), zapis podmienia ją w całości
  const saveNote = () => {
    act('UpdateNote', { newnote: text });
    setOriginalText(text);
  };
  const handleSave = () => {
    saveNote();
    setActiveDialog(Dialogs.NONE);
  };
  const ensureUnsavedChangesAreHandled = (
    action: RetryActionType,
    retrying = false,
  ): boolean => {
    // Pokazuje okno „niezapisane zmiany”, jeśli akcja wyrzuciłaby tekst
    if (!retrying && originalText !== text) {
      setRetryAction(() => action);
      setActiveDialog(Dialogs.UNSAVED_CHANGES);
      return true;
    }
    return false;
  };
  const exit = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(exit, retrying)) {
      return;
    }
    act('PC_exit');
  };
  // Czyści tylko pole tekstowe: zapisana notatka zostaje, dopóki gracz
  // nie kliknie „Zapisz”
  const newNote = (retrying = false) => {
    if (ensureUnsavedChangesAreHandled(newNote, retrying)) {
      return;
    }
    setText('');
    setStatuses({ line: 1, column: 1 });
  };

  // Jak w Notatniku MS: gwiazdka przy niezapisanych zmianach
  const unsavedAsterisk = text !== originalText ? '*' : '';
  return (
    <NtosWindow
      title={`${unsavedAsterisk}${DEFAULT_DOCUMENT_NAME} - Notatnik`}
      width={600}
      height={700}
    >
      <NtosWindow.Content>
        <Box className="NtosNotepad__layout">
          <NtosNotepadMenuBar
            onSave={handleSave}
            onExit={exit}
            onNewNote={newNote}
            hasPaper={!!has_paper}
            onShowPaper={() => act('ShowPaper')}
            onCutSelected={() => document.execCommand('cut')}
            onCopySelected={() => document.execCommand('copy')}
            onPasteSelected={() => document.execCommand('paste')}
            onDeleteSelected={() => document.execCommand('delete')}
            showStatusBar={showStatusBar}
            setShowStatusBar={setShowStatusBar}
            wordWrap={wordWrap}
            setWordWrap={setWordWrap}
            aboutNotepadDialog={() => setActiveDialog(Dialogs.ABOUT)}
          />
          <Section fill>
            <NotePadTextArea
              text={text}
              setText={setText}
              wordWrap={wordWrap}
              setStatuses={setStatuses}
            />
          </Section>
          {showStatusBar && <StatusBar statuses={statuses} />}
        </Box>
      </NtosWindow.Content>
      {activeDialog === Dialogs.UNSAVED_CHANGES && (
        <Dialog title="Notatnik" onClose={handleCloseDialog}>
          <div className="Dialog__body">Czy zapisać zmiany w notatkach?</div>
          <div className="Dialog__footer">
            <Dialog.Button
              onClick={() => {
                const retry = retryAction;
                saveNote();
                handleCloseDialog();
                retry?.(true);
              }}
            >
              Zapisz
            </Dialog.Button>
            <Dialog.Button
              onClick={() => {
                const retry = retryAction;
                handleCloseDialog();
                retry?.(true);
              }}
            >
              Nie zapisuj
            </Dialog.Button>
            <Dialog.Button onClick={handleCloseDialog}>Anuluj</Dialog.Button>
          </div>
        </Dialog>
      )}
      {activeDialog === Dialogs.ABOUT && (
        <AboutDialog close={handleCloseDialog} owner={owner} />
      )}
    </NtosWindow>
  );
};

import { useBackend } from '../../backend';
import { Box, Tooltip } from '../../components';
import { PreferencesMenuData } from './data';

export const SaveStatus = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  const {
    save_in_progress = false,
    is_db = true,
    is_guest = false,
    save_sucess = true,
  } = data;
  const innerBox = (
    <Box
      backgroundColor={
        is_guest || !is_db
          ? '#cc0000'
          : save_in_progress
            ? '#666666'
            : save_sucess
              ? '#00cc00'
              : '#cc0000'
      }
      textColor="white"
      textAlign="center"
      ml={1}
      style={{
        borderRadius: '2px',
        display: 'inline',
        padding: '2px 5px',
      }}
    >
      {!is_db ? (
        <strong>Brak bazy</strong>
      ) : is_guest ? (
        <strong>Gość</strong>
      ) : null}
      {!is_guest && is_db ? (
        save_in_progress ? (
          <span>
            Zapisywanie
            <span className="loading-one">.</span>
            <span className="loading-two">.</span>
            <span className="loading-three">.</span>
          </span>
        ) : (
          <strong>{save_sucess ? 'Zapisano' : 'Błąd'}</strong>
        )
      ) : null}
    </Box>
  );
  if (!is_db || is_guest) {
    return (
      <Tooltip
        content={`Nie można zapisać ustawień: ${
          !is_db
            ? 'brak połączenia z bazą danych.'
            : 'jesteś gościem. Zarejestruj się i zaloguj na konto BYOND.'
        }`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  if (!save_in_progress && !save_sucess) {
    return (
      <Tooltip
        content={`Nie udało się zapisać danych. Zgłoś ten błąd operatorowi serwera albo maintainerowi.`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  if (save_in_progress) {
    return (
      <Tooltip
        content={`Poczekaj do 5 sekund na zapis danych. Przy dużym obciążeniu zapis może potrwać dłużej, ale twoje dane i tak czekają w kolejce do zapisu.`}
        position="bottom"
      >
        {innerBox}
      </Tooltip>
    );
  }
  return innerBox;
};

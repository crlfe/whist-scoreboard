import "./index.css";

import { h, render } from "preact";
import { useCallback, useMemo, useState, useEffect } from "preact/hooks";

/*
Tables and Games inputs can probably select() now that the incremental update is removed.
Open and Save support
Fix the getStatic to work in electron/webpack dev and prod
*/

interface State {
  numTables: number;
  numGames: number;
  scoreRows: number[][];
}

const fillWidth = true;

function Header({
  numTables,
  numGames,
  onOpen,
  onSave,
  onClear,
  onAddGame,
  onRemoveGame,
  onSetTables,
  onSetGames
}: {
  numTables: number;
  numGames: number;
  onOpen: () => void;
  onSave: () => void;
  onClear: () => void;
  onAddGame: () => void;
  onRemoveGame: () => void;
  onSetTables: (value: string) => void;
  onSetGames: (value: string) => void;
}) {
  return [
    h("tr", {}, [
      h("th", { class: "hdr-table", scope: "col" }, [
        "Table",
        h("div", { class: "tools-left" }, [
          h("button", {}, "Menu"),
          h("ul", {}, [
            h("li", { class: "input-grid" }, [
              h("label", { for: "numTables" }, "Tables"),
              h("input", {
                id: "numTables",
                type: "number",
                min: "1",
                max: "100",
                value: numTables,
                onChange: useCallback(
                  (event: Event) => {
                    const target = event.target as HTMLInputElement;
                    onSetTables(target.value);
                    target.value = String(numTables);
                  },
                  [onSetTables]
                )
              }),
              h("label", { for: "numGames" }, "Games"),
              h("input", {
                id: "numGames",
                type: "number",
                min: "1",
                max: "100",
                value: numGames,
                onChange: useCallback(
                  (event: Event) => {
                    const target = event.target as HTMLInputElement;
                    onSetGames(target.value);
                    target.value = String(numGames);
                  },
                  [onSetGames]
                )
              })
            ]),
            h("li", {}, h("button", { onClick: onOpen }, "Open...")),
            h("li", {}, h("button", { onClick: onSave }, "Save As...")),
            h("li", {}, h("button", { onClick: onClear }, "Clear"))
          ])
        ])
      ]),
      h(
        "th",
        {
          class: "hdr-games",
          colspan: numGames + (fillWidth ? 1 : 0),
          scope: "colgroup"
        },
        [h("span", { class: "title" }, "Games")]
      ),
      h("th", { class: "hdr-total", scope: "col" }, [
        "Total",
        h("div", { class: "tools-right" }, [
          h(
            "button",
            {
              title: "Remove Game",
              onClick: onRemoveGame
            },
            "-"
          ),
          h(
            "button",
            {
              title: "Add Game",
              onClick: onAddGame
            },
            "+"
          )
        ])
      ]),
      h("th", { class: "hdr-table2", scope: "col" }, "Table")
    ]),
    h("tr", {}, [
      h("td", { class: "hdr-table" }),
      Array.from({ length: numGames }, (_, col) =>
        h("th", { class: "hdr-game", id: `game-${col}` }, `${col + 1}`)
      ),
      fillWidth && h("td", { class: "col-stretch" }),
      h("td", { class: "hdr-total" }),
      h("td", { class: "hdr-table2" })
    ])
  ];
}

function Cells({
  row,
  numGames,
  scores
}: {
  row: number;
  numGames: number;
  scores: number[];
}) {
  if (!scores) {
    scores = [];
  }

  let total = 0;
  for (let i = 0; i < numGames; i++) {
    total += scores[i] || 0;
  }

  return [
    h("th", { class: "table", scope: "row" }, `${row + 1}`),
    Array.from({ length: numGames }, (_, col) => {
      const score = scores[col] || 0;
      return h(
        "td",
        { class: "score", id: `score-${row}-${col}`, tabindex: 0 },
        [h("img", { src: `tally-${score}.svg` })]
      );
    }),
    fillWidth && h("td", { class: "col-stretch" }),
    h("td", { class: "total" }, total),
    h("th", { class: "table2", scope: "row" }, `${row + 1}`)
  ];
}

function App() {
  const initialState = useMemo(localLoad, []) as State;

  const [numTables, setNumTables] = useState(initialState.numTables);
  const [numGames, setNumGames] = useState(initialState.numGames);
  const [scoreRows, setScoreRows] = useState(initialState.scoreRows);

  useEffect(() => {
    localSave({ numTables, numGames, scoreRows });
  }, [numTables, numGames, scoreRows]);

  function scrollToRightSoon() {
    setTimeout(function() {
      window.scrollTo(document.body.scrollWidth, document.body.scrollTop);
    }, 0);
  }

  function updateScoreAt(
    row: number,
    col: number,
    updater: (value: number) => number
  ): void {
    let nextRows = Array.from(scoreRows);
    nextRows[row] = Array.from(nextRows[row] || []);
    nextRows[row][col] = updater(nextRows[row][col] || 0);
    setScoreRows(nextRows);
  }

  const handlers: any = {
    onOpen: useCallback(() => {
      window.alert("Sorry, loading from file is not implemented yet.");
    }, []),
    onSave: useCallback(() => {
      window.alert("Sorry, saving to file is not implemented yet.");
    }, []),
    onClear: useCallback(
      (event: Event) => {
        if (window.confirm("Do you really want to erase all scores?")) {
          setScoreRows([]);
        }
        if (event.target) {
          (event.target as HTMLElement).blur();
        }
      },
      [setScoreRows]
    ),
    onAddGame: useCallback(() => {
      setNumGames(Math.min(numGames + 1, 100));
      scrollToRightSoon();
    }, [numGames, setNumGames]),
    onRemoveGame: useCallback(() => {
      setNumGames(Math.max(numGames - 1, 1));
      scrollToRightSoon();
    }, [numGames, setNumGames]),
    onSetTables: useCallback(
      (value: string) => {
        const n = parseInt(value, 10);
        if (isNaN(n)) {
          return;
        }
        setNumTables(Math.min(Math.max(n, 1), 100));
      },
      [numTables, setNumTables]
    ),
    onSetGames: useCallback(
      (value: string) => {
        const n = parseInt(value, 10);
        if (isNaN(n)) {
          return;
        }
        setNumGames(Math.min(Math.max(n, 1), 100));
        scrollToRightSoon();
      },
      [numGames, setNumGames]
    )
  };

  function findCurrentCell(event: Event): [number, number] {
    let target = event.target as Element | null;
    for (; target; target = target.parentNode as Element | null) {
      if (target.id) {
        let m: RegExpExecArray | null;
        if (null != (m = /^score-(\d+)-(\d+)$/.exec(target.id))) {
          return [parseInt(m[1]), parseInt(m[2])];
        } else if (null != (m = /^game-(\d+)/.exec(target.id))) {
          return [-1, parseInt(m[1])];
        }
      }
    }
    return [-1, -1];
  }

  function focusCellAt(row: number, col: number) {
    const target = document.querySelector(`#score-${row}-${col}`);
    if (target) {
      (target as HTMLElement).focus();
    }
  }

  function onClick(event: MouseEvent) {
    const [row, col] = findCurrentCell(event);
    if (row >= 0) {
      event.preventDefault();
      updateScoreAt(row, col, value => (value + 1) % 5);
    } else if (col >= 0) {
      event.preventDefault();
      focusCellAt(0, col);
    }
  }

  function onKeydown(event: KeyboardEvent) {
    const [row, col] = findCurrentCell(event);
    if (
      row < 0 ||
      col < 0 ||
      event.altKey ||
      event.ctrlKey ||
      event.metaKey ||
      event.shiftKey
    ) {
      return;
    }
    console.log(event.key);
    switch (event.key) {
      case "ArrowLeft":
        focusCellAt(row, col - 1);
        break;
      case "ArrowRight":
        focusCellAt(row, col + 1);
        break;
      case "ArrowUp":
        focusCellAt(row - 1, col);
        break;
      case "ArrowDown":
      case "Enter":
        focusCellAt(row + 1, col);
        break;
      case " ":
        updateScoreAt(row, col, value => (value + 1) % 5);
        break;
      case "Escape":
        const e = document.activeElement as HTMLElement | null;
        if (e != null) {
          e.blur();
        }
        break;
      case "0":
      case "1":
      case "2":
      case "3":
      case "4":
        updateScoreAt(row, col, () => parseInt(event.key));
        break;
      default:
        return;
    }
    event.preventDefault();
  }

  return h(
    "table",
    {
      onClick,
      onKeydown
    },
    [
      h("col", { class: "col-table" }),
      h(
        "colgroup",
        {},
        Array.from({ length: numGames }, () => h("col", { class: "col-game" }))
      ),
      fillWidth && h("col", { class: "col-stretch" }),
      h("col", { class: "col-total" }),
      h("thead", {}, [
        h(Header as any, {
          numTables,
          numGames,
          ...handlers
        })
      ]),
      Array.from({ length: numTables }, (_, i) =>
        h(
          "tr",
          { class: "score" },
          Cells({
            row: i,
            numGames,
            scores: scoreRows[i]
          })
        )
      ),
      h("tr", {}, [
        h("td", { class: "hdr-table" }),
        Array.from({ length: numGames }, (_, col) =>
          h("th", { class: "hdr-game", id: `game-${col}-footer` }, `${col + 1}`)
        ),
        fillWidth && h("td", { class: "col-stretch" }),
        h("td", { class: "hdr-total" }),
        h("td", { class: "hdr-table2" })
      ])
    ]
  );
}

const LOCAL_NAME = "whist-scoreboard";
const LOCAL_VERSION = 1;

const LOCAL_DEFAULT = {
  numTables: 15,
  numGames: 20,
  scoreRows: [[0]]
};

function localSave(state: State) {
  try {
    const data = Object.assign({ version: LOCAL_VERSION }, state);
    window.localStorage.setItem(LOCAL_NAME, JSON.stringify(data));
  } catch (err) {
    console.error(err);
    try {
      window.localStorage.removeItem(LOCAL_NAME);
    } catch (err) {
      /* Ignore failure to remove saved data. */
    }
  }
}

function localLoad(): State {
  try {
    const text = window.localStorage.getItem("whist-scoreboard");
    if (text == null) {
      return LOCAL_DEFAULT;
    }

    const data = JSON.parse(text);
    if (data.version !== LOCAL_VERSION) {
      throw new Error(`Unsupported version in local storage: ${data.version}`);
    }

    let { numTables, numGames, scoreRows } = data;

    if (typeof numTables !== "number" || numTables < 1 || numTables > 100) {
      numTables = LOCAL_DEFAULT.numTables;
    }
    if (typeof numGames !== "number" || numGames < 1 || numGames > 100) {
      numGames = LOCAL_DEFAULT.numGames;
    }
    if (!Array.isArray(scoreRows)) {
      scoreRows = LOCAL_DEFAULT.scoreRows;
    }

    return { numTables, numGames, scoreRows };
  } catch (err) {
    console.error(err);
    try {
      window.localStorage.removeItem(LOCAL_NAME);
    } catch (err) {
      /* Ignore failure to remove saved data. */
    }

    return LOCAL_DEFAULT;
  }
}

render(h(App, {}), document.getElementById("app") as HTMLElement);

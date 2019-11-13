/**
 * @author Chris Wolfe (https://crlfe.ca)
 * @license MIT
 */

const { h, render } = window.preact;
const { useEffect, useState, useRef } = window.preactHooks;

function ScoresTable() {
  const tableRef = useRef(null);
  const [data, setData] = useLocalStorage("whist-scoreboard", {
    rows: 4,
    cols: 4,
    values: [[0, 1, 0, 1], [1, 2, 3, 4], [4, 3, 2, 1], [0, 0, 1, 0]]
  });

  function onClick(row, col, event) {
    setScore(row, col, (data.values[row][col] + 1) % 5);
  }

  function setScore(row, col, value) {
    const { rows, cols, values } = data;
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return;
    }

    const newValues = Array.from(values);
    newValues[row] = Array.from(newValues[row]);
    newValues[row][col] = value;
    setData({ rows, cols, values: newValues });
  }

  const { rows, cols, values } = data;

  return h("table", { ref: tableRef }, [
    h("tr", {}, [
      h("th", { scope: "col", class: "table" }, "Table"),
      h("th", { scope: "colgroup", colspan: cols }, "Game"),
      h("td"),
      h("th", { scope: "col", class: "total" }, "Total")
    ]),
    h("tr", {}, [
      h("td"),
      Array.from({ length: cols }, (_, col) =>
        h("th", { scope: "col", class: "tally" }, `${col + 1}`)
      ),
      h("td"),
      h("td")
    ]),
    Array.from({ length: rows }, (_, row) =>
      h(ScoresRow, { row, values: values[row], onClick })
    )
  ]);
}

function ScoresRow({ row, values, onClick }) {
  const label = `${row + 1}`;
  const total = values.reduce((a, c) => a + c, 0);

  return h("tr", { class: "scores" }, [
    h("th", { scope: "row" }, label),
    values.map((value, col) =>
      h("td", { class: "tally" }, [
        h(
          "button",
          { onClick: event => onClick(row, col, event) },
          TALLY[value]
        )
      ])
    ),
    h("td"),
    h("td", { class: "total" }, String(total))
  ]);
}

function useLocalStorage(keyName, initialValue) {
  const [getValue, setValue] = useState(() => {
    try {
      const json = window.localStorage.getItem(keyName);
      if (!json) {
        return initialValue;
      }
      return JSON.parse(json);
    } catch (err) {
      console.error(err);
      return initialValue;
    }
  });
  function setLocalValue(value) {
    if (value instanceof Function) {
      value = value();
    }
    setValue(value);
    try {
      window.localStorage.setItem(keyName, JSON.stringify(value));
    } catch (err) {
      console.error(err);
    }
  }
  return [getValue, setLocalValue];
}

const TALLY = ["", "\u{1D369}", "\u{1D36A}", "\u{1D36B}", "\u{1D36C}"];

render(h(ScoresTable), document.getElementById("scores"));

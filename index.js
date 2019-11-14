/**
 * @author Chris Wolfe (https://crlfe.ca)
 * @license MIT
 */

const { h, render } = window.preact;
const { useEffect, useState, useRef } = window.preactHooks;

function App() {
  const tableRef = useRef(null);
  const [data, setData] = useLocalStorage("whist-scoreboard", {
    rows: 4,
    cols: 4,
    values: [[0, 1, 0, 1], [1, 2, 3, 4], [4, 3, 2, 1], [0, 0, 1, 0]]
  });

  function getScore(row, col) {
    return (data.values[row] || [])[col] || 0;
  }

  function setScore(row, col, value) {
    const { rows, cols, values } = data;

    const newValues = Array.from(values);
    newValues[row] = Array.from(newValues[row]);
    newValues[row][col] = value;
    setData({ rows, cols, values: newValues });
  }

  function resizeData(rows, cols) {
    let { values } = data;

    const fixRows = values.length < rows;
    const fixCols = values.some(xs => xs.length < cols);

    if (fixRows || fixCols) {
      const oldValues = values;
      values = Array.from({ length: rows }, (_, row) =>
        Array.from(
          { length: cols },
          (_, col) => ((oldValues || [])[row] || [])[col] || 0
        )
      );
      console.log({ oldValues, values });
    }
    setData({ rows, cols, values });
  }

  function onClear() {
    if (window.confirm("Do you really want to clear all scores to zero?")) {
      const { rows, cols } = data;
      const values = Array.from({ length: rows }, () =>
        Array.from({ length: cols }, () => 0)
      );
      setData({ rows, cols, values });
    }
  }

  function onLoad() {
    const input = document.createElement("input");
    const reader = new FileReader();
    input.type = "file";
    input.accept = ".txt,text/plain";
    input.addEventListener("change", () => {
      if (input.files.length === 1) {
        input.files[0]
          .text()
          .then(text => fileImport(text))
          .then(data => setData(data))
          .catch(err => {
            window.alert(err);
          });
      }
    });
    input.click();
  }

  function onSave() {
    Promise.resolve(data)
      .then(data => fileExport(data))
      .then(text => {
        const date = new Date().toISOString().slice(0, 10);
        const link = document.createElement("a");
        link.href = "data:text/plain;base64," + btoa(text);
        link.download = `whist-${date}.txt`;
        link.click();
      })
      .catch(err => {
        window.alert(err);
      });
  }

  function onRowsChange(event) {
    const rows = parseInt(event.target.value);
    if (rows > 0) {
      resizeData(rows, data.cols);
    }
  }

  function onColsChange(event) {
    const cols = parseInt(event.target.value);
    if (cols > 0) {
      resizeData(data.rows, cols);
    }
  }

  function onClick(row, col, event) {
    setScore(row, col, (getScore(row, col) + 1) % 5);
  }

  const { rows, cols, values } = data;

  return h("div", {}, [
    h("ul", {}, [
      h("li", {}, [
        h("button", { onClick: onClear }, "Clear"),
        h("button", { onClick: onLoad }, "Load"),
        h("button", { onClick: onSave }, "Save")
      ]),
      h(
        "li",
        {},
        h("label", {}, [
          "Tables",
          h("input", {
            type: "number",
            min: 1,
            value: rows,
            onChange: onRowsChange
          })
        ])
      ),
      h(
        "li",
        {},
        h("label", {}, [
          "Games",
          h("input", {
            type: "number",
            min: 1,
            value: cols,
            onChange: onColsChange
          })
        ])
      )
    ]),
    h("table", { ref: tableRef }, [
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
        h(ScoresRow, { row, cols, values: values[row], onClick })
      )
    ])
  ]);
}

function ScoresRow({ row, cols, values, onClick }) {
  values = values.slice(0, cols);

  const label = `${row + 1}`;
  const total = values.reduce((a, c) => a + c, 0);

  const TALLY = ["", "\u{1D369}", "\u{1D36A}", "\u{1D36B}", "\u{1D36C}"];

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
    window.localStorage.removeItem(keyName);
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

function fileImport(src) {
  throw new Error("File import is not yet implemented");
}

function fileExport(src) {
  throw new Error("File export is not yet implemented");
}

render(h(App), document.querySelector("main"));

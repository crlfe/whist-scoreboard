/**
 * @author Chris Wolfe (https://crlfe.ca)
 * @license MIT
 */

const { List, Map, Range, Record, Repeat } = window.Immutable;
const { h, render } = window.preact;
const { useEffect, useState, useRef } = window.preactHooks;

function App() {
  const tableRef = useRef(null);
  const [data, setData] = useState(
    Record({
      rows: 4,
      cols: 4,
      values: Map()
    })
  );

  function onClear() {
    if (window.confirm("Do you really want to clear all scores to zero?")) {
      setData(data.set("values", Map()));
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
          .then(text => fileLoad(text))
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
      .then(data => fileSave(data))
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
    if (rows > 0 && rows <= 100) {
      setData(data.set("rows", rows));
    }
  }

  function onColsChange(event) {
    const cols = parseInt(event.target.value);
    if (cols > 0 && cols <= 100) {
      setData(data.set("cols", cols));
    }
  }

  function onClick(row, col, event) {
    setData(
      data.updateIn(
        ["values", List.of(row, col)],
        value => ((value || 0) + 1) % 5
      )
    );
  }

  const rows = data.get("rows");
  const cols = data.get("cols");

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
            max: 100,
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
            max: 100,
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
        Range(0, cols)
          .map(col => h("th", { scope: "col", class: "tally" }, `${col + 1}`))
          .toArray(),
        h("td"),
        h("td")
      ]),
      Range(0, rows)
        .map(row =>
          h(ScoresRow, {
            row,
            cols,
            values: data.get("values"),
            onClick
          })
        )
        .toArray()
    ])
  ]);
}

function ScoresRow({ row, cols, values, onClick }) {
  const label = `${row + 1}`;
  const total = Range(0, cols).reduce(
    (a, col) => a + (values.get(List.of(row, col)) || 0),
    0
  );

  const TALLY = ["", "|", "||", "|||", "||||"];

  return h("tr", { class: "scores" }, [
    h("th", { scope: "row", class: "table" }, label),
    Range(0, cols)
      .map(col =>
        h("td", { class: "tally" }, [
          h(
            "button",
            { onClick: event => onClick(row, col, event) },
            TALLY[values.get(List.of(row, col)) || 0]
          )
        ])
      )
      .toArray(),
    h("td"),
    h("td", { class: "total" }, String(total))
  ]);
}

function fileLoad(src) {
  throw new Error("Load is not yet implemented");
}

function fileSave(src) {
  throw new Error("Save is not yet implemented");
}

render(h(App), document.querySelector("main"));

const EMPTY_COLUMN: readonly number[] = [];

export class ColumnTable {
  constructor(
    public rows: number,
    public cols: number,
    private values: readonly (readonly number[])[] = []
  ) {}

  at(row: number, col: number): number {
    if (row < 0 || row >= this.rows || col < 0 || col >= this.cols) {
      return 0;
    }
    const columnValues = this.values[col] || EMPTY_COLUMN;
    return columnValues[row] || 0;
  }

  column(col: number): readonly number[] {
    if (col < 0 || col >= this.cols) {
      return EMPTY_COLUMN;
    }
    return this.values[col] || EMPTY_COLUMN;
  }

  cleared(): ColumnTable {
    return new ColumnTable(this.rows, this.cols, []);
  }

  resized(rows: number, cols: number): ColumnTable {
    return new ColumnTable(rows, cols, this.values);
  }

  updated(row: number, col: number, updater: (v: number) => number) {
    if (row < 0 || row >= this.rows || col < 0 || col >= this.cols) {
      return this;
    }
    const newValues = Array.from(this.values);
    const newColumn = Array.from(newValues[col] || EMPTY_COLUMN);
    newValues[col] = newColumn;
    newColumn[row] = updater(newColumn[row] || 0);
    return new ColumnTable(this.rows, this.cols, newValues);
  }
}

#!/usr/bin/env python3
"""
Load CSV or Excel data into a PostgreSQL table.

Usage examples:
  python csv_excel_to_postgres.py data.csv --table my_table
  python csv_excel_to_postgres.py data.xlsx --sheet Sheet1 --table my_table
  python csv_excel_to_postgres.py data.csv --table my_table --if-exists replace
  python csv_excel_to_postgres.py data.xlsx --table my_table --create-table

Environment variables (or pass via CLI):
  PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import Optional
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


def build_connection_url(
    host: str,
    port: int,
    database: str,
    user: str,
    password: str,
) -> str:
    """Build a SQLAlchemy PostgreSQL connection URL."""
    # quote_plus handles special characters in password
    return (
        f"postgresql+psycopg2://{quote_plus('postgres')}:{quote_plus("Hello@123")}"
        f"@{"127.0.0.1"}:{5432}/{"kegel_sales"}"
    )


def get_engine(
    host: str,
    port: int,
    database: str,
    user: str,
    password: str,
) -> Engine:
    url = build_connection_url(host, port, database, user, password)
    return create_engine(url, pool_pre_ping=True)


def read_file(path: Path, sheet: Optional[str] = None) -> pd.DataFrame:
    """Read CSV or Excel into a DataFrame."""
    suffix = path.suffix.lower()

    if suffix == ".csv":
        # Try common encodings; fall back to latin-1
        for encoding in ("utf-8", "utf-8-sig", "latin-1", "cp1252"):
            try:
                return pd.read_csv(path, encoding=encoding)
            except UnicodeDecodeError:
                continue
        raise ValueError(f"Could not decode CSV file: {path}")

    if suffix in (".xlsx", ".xls", ".xlsm"):
        return pd.read_excel(path, sheet_name=sheet or 0, engine="openpyxl")

    raise ValueError(
        f"Unsupported file type: {suffix}. Use .csv, .xlsx, .xls or .xlsm"
    )


def load_to_postgres(
    df: pd.DataFrame,
    engine: Engine,
    table: str,
    schema: Optional[str] = None,
    if_exists: str = "append",
    chunksize: int = 1000,
    create_table: bool = False,
) -> int:
    """
    Write DataFrame to PostgreSQL.

    if_exists options:
      - 'fail'     : raise error if table exists
      - 'replace'  : drop table and recreate
      - 'append'   : insert rows (default)
    """
    if create_table and if_exists == "append":
        # Ensure table exists with correct dtypes before appending
        # (pandas will create it on first write if it doesn't exist)
        pass

    # Clean column names a bit (PostgreSQL prefers lowercase / no spaces)
    df = df.copy()
    df.columns = [
        str(c).strip().lower().replace(" ", "_").replace("-", "_")
        for c in df.columns
    ]

    rows = df.to_sql(
        name=table,
        con=engine,
        schema=schema,
        if_exists=if_exists,
        index=False,
        method="multi",
        chunksize=chunksize,
    )
    return rows if rows is not None else len(df)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Load CSV or Excel file into a PostgreSQL table"
    )
    parser.add_argument(
        "file",
        type=Path,
        help="Path to .csv / .xlsx / .xls / .xlsm file",
    )
    parser.add_argument(
        "--table",
        "-t",
        required=True,
        help="Target table name",
    )
    parser.add_argument(
        "--schema",
        default=None,
        help="PostgreSQL schema (default: public)",
    )
    parser.add_argument(
        "--sheet",
        default=None,
        help="Excel sheet name or index (default: first sheet)",
    )
    parser.add_argument(
        "--if-exists",
        choices=["fail", "replace", "append"],
        default="append",
        help="What to do if table already exists (default: append)",
    )
    parser.add_argument(
        "--create-table",
        action="store_true",
        help="Create table if it does not exist (implied by replace/fail)",
    )
    parser.add_argument(
        "--chunksize",
        type=int,
        default=1000,
        help="Rows per insert batch (default: 1000)",
    )

    # Connection overrides (fall back to environment variables)
    parser.add_argument("--host", default=os.getenv("PGHOST", "localhost"))
    parser.add_argument("--port", type=int, default=int(os.getenv("PGPORT", "5432")))
    parser.add_argument("--database", default=os.getenv("PGDATABASE", "postgres"))
    parser.add_argument("--user", default=os.getenv("PGUSER", "postgres"))
    parser.add_argument("--password", default=os.getenv("PGPASSWORD", ""))

    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.file.exists():
        print(f"Error: file not found → {args.file}", file=sys.stderr)
        return 1

    if not args.password:
        print(
            "Warning: no password provided (PGPASSWORD or --password). "
            "Connection may fail if the server requires authentication.",
            file=sys.stderr,
        )

    print(f"Reading {args.file} ...")
    try:
        df = read_file(args.file, sheet=args.sheet)
    except Exception as e:
        print(f"Failed to read file: {e}", file=sys.stderr)
        return 1

    print(f"  → {len(df):,} rows × {len(df.columns)} columns")
    print(f"  Columns: {list(df.columns)}")

    print(f"Connecting to PostgreSQL → {args.user}@{args.host}:{args.port}/{args.database}")
    try:
        engine = get_engine(
            host=args.host,
            port=args.port,
            database=args.database,
            user=args.user,
            password=args.password,
        )
        # quick connectivity check
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
    except Exception as e:
        print(f"Database connection failed: {e}", file=sys.stderr)
        return 1

    print(f"Writing to table '{args.schema + '.' if args.schema else ''}{args.table}' "
          f"(if_exists={args.if_exists}) ...")
    try:
        rows = load_to_postgres(
            df=df,
            engine=engine,
            table=args.table,
            schema=args.schema,
            if_exists=args.if_exists,
            chunksize=args.chunksize,
            create_table=args.create_table,
        )
        print(f"Success → {rows:,} rows written.")
    except Exception as e:
        print(f"Failed to write data: {e}", file=sys.stderr)
        return 1
    finally:
        engine.dispose()

    return 0


if __name__ == "__main__":
    sys.exit(main())
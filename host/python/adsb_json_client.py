#!/usr/bin/env python3
"""Receive decoded ADS-B JSON events from an E200 readsb instance.

The E200 performs IIO acquisition and Mode-S/ADS-B decoding on-board. This
client consumes the decoded newline-delimited JSON stream (TCP port 8081 by
default); it does not access IQ samples and does not require libiio.
"""

from __future__ import annotations

import argparse
import json
import socket
import sys
import time
from pathlib import Path
from typing import Any, TextIO


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Receive decoded ADS-B results from an E200"
    )
    parser.add_argument("--host", default="192.168.10.122", help="E200 IP address")
    parser.add_argument("--port", type=int, default=8081, help="readsb JSON TCP port")
    parser.add_argument(
        "--output", type=Path, help="append complete JSON events to this JSONL file"
    )
    parser.add_argument(
        "--raw", action="store_true", help="print each complete JSON event"
    )
    parser.add_argument(
        "--once", action="store_true", help="exit after the first valid JSON event"
    )
    parser.add_argument(
        "--reconnect",
        type=float,
        default=3.0,
        help="seconds between reconnect attempts",
    )
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("--port must be between 1 and 65535")
    return args


def print_event(event: Any, raw: bool) -> None:
    """Print either the full event or a compact aircraft summary."""
    if raw:
        print(json.dumps(event, ensure_ascii=False, separators=(",", ":")), flush=True)
        return

    if not isinstance(event, dict):
        print("ADS-B " + repr(event), flush=True)
        return

    identity = event.get("hex") or event.get("icao") or event.get("address") or "?"
    flight = event.get("flight") or event.get("callsign") or ""
    altitude = event.get("alt_baro", event.get("altitude"))
    lat = event.get("lat")
    lon = event.get("lon")
    details = [f"hex={identity}"]
    if flight:
        details.append(f"flight={str(flight).strip()}")
    if altitude is not None:
        details.append(f"alt={altitude}")
    if lat is not None and lon is not None:
        details.append(f"pos={lat},{lon}")
    print("ADS-B " + " ".join(details), flush=True)


def receive(args: argparse.Namespace, output: TextIO | None) -> int:
    print(f"connecting to {args.host}:{args.port} ...", file=sys.stderr, flush=True)
    with socket.create_connection((args.host, args.port), timeout=10) as sock:
        sock.settimeout(None)
        print(f"connected to {args.host}:{args.port}", file=sys.stderr, flush=True)
        with sock.makefile("r", encoding="utf-8", errors="replace") as stream:
            for line in stream:
                line = line.strip()
                if not line:
                    continue
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    print(
                        f"warning: ignoring non-JSON line: {line[:160]}",
                        file=sys.stderr,
                    )
                    continue

                print_event(event, args.raw)
                if output:
                    output.write(
                        json.dumps(event, ensure_ascii=False, separators=(",", ":"))
                        + "\n"
                    )
                    output.flush()
                if args.once:
                    return 0
    return 1


def run(args: argparse.Namespace) -> int:
    output = args.output.open("a", encoding="utf-8") if args.output else None
    try:
        while True:
            try:
                result = receive(args, output)
                if result == 0:
                    return 0
                print("connection closed by E200", file=sys.stderr)
                if args.once:
                    return 2
            except OSError as exc:
                print(f"connection failed: {exc}", file=sys.stderr)
                if args.once:
                    return 2
            time.sleep(max(0.1, args.reconnect))
    except KeyboardInterrupt:
        print("\nstopped", file=sys.stderr)
        return 0
    finally:
        if output:
            output.close()


if __name__ == "__main__":
    raise SystemExit(run(parse_args()))

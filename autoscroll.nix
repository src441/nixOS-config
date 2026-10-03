{ config, pkgs, ... }:

let
  mmbConfigFile = pkgs.writeText "mmb-autoscroll.conf" ''
    MMB_MODE=rate
    MMB_DEADZONE=18
    MMB_GAIN=0.020
    MMB_EXPONENT=1.30
    MMB_MAX_SPEED=40
    MMB_TICK_MS=15
    MMB_POSITION_FACTOR=0.06
    MMB_HORIZONTAL=1
    MMB_INVERT_V=0
    MMB_INVERT_H=0
    MMB_MATCH_NAME=(?i)mouse
  '';

  pythonEnv = pkgs.python3.withPackages (ps: [ ps.evdev ]);

  mmb-autoscroll-pkg = pkgs.writeScriptBin "mmb-autoscroll" ''
    #!\${pythonEnv}/bin/python3
    import math
    import os
    import sys
    import time

    def _envf(name, default):
        try: return float(os.environ.get(name, default))
        except (TypeError, ValueError): return float(default)

    def _envi(name, default):
        try: return int(os.environ.get(name, default))
        except (TypeError, ValueError): return int(default)

    class Config:
        def __init__(self):
            self.mode = os.environ.get("MMB_MODE", "rate").strip().lower()
            self.deadzone = _envf("MMB_DEADZONE", 18)
            self.gain = _envf("MMB_GAIN", 0.020)
            self.exponent = _envf("MMB_EXPONENT", 1.30)
            self.max_speed = _envf("MMB_MAX_SPEED", 40.0)
            self.position_factor = _envf("MMB_POSITION_FACTOR", 0.06)
            self.tick_ms = _envi("MMB_TICK_MS", 15)
            self.horizontal = _envi("MMB_HORIZONTAL", 1)
            self.invert_v = _envi("MMB_INVERT_V", 0)
            self.invert_h = _envi("MMB_INVERT_H", 0)
            self.device = os.environ.get("MMB_DEVICE", "").strip()
            self.match_name = os.environ.get("MMB_MATCH_NAME", "(?i)mouse")
            self.uinput_name = os.environ.get("MMB_UINPUT_NAME", "mmb-autoscroll virtual pointer")

    HIRES_PER_NOTCH = 120

    class ScrollEngine:
        def __init__(self, cfg: Config):
            self.cfg = cfg
            self.held = False
            self.moved = False
            self.offx = self.offy = 0.0
            self._acc_v = self._acc_h = 0.0

        def middle_down(self, now):
            self.held, self.moved = True, False
            self.offx = self.offy = 0.0
            self._acc_v = self._acc_h = 0.0
            return []

        def middle_up(self, now):
            was_scroll = self.moved
            self.held = self.moved = False
            self.offx = self.offy = 0.0
            self._acc_v = self._acc_h = 0.0
            return [] if was_scroll else [("click",)]

        def add_motion(self, dx, dy):
            if not self.held: return False
            self.offx += dx
            self.offy += dy
            if not self.moved and math.hypot(self.offx, self.offy) > self.cfg.deadzone:
                self.moved = True
            if self.cfg.mode == "position" and self.moved:
                self._emit_position(dx, dy)
            return True

        def _emit_position(self, dx, dy):
            f = self.cfg.position_factor
            self._acc_v += -dy * f * HIRES_PER_NOTCH if not self.cfg.invert_v else dy * f * HIRES_PER_NOTCH
            if self.cfg.horizontal:
                self._acc_h += dx * f * HIRES_PER_NOTCH if not self.cfg.invert_h else -dx * f * HIRES_PER_NOTCH

        def tick(self, dt):
            if self.cfg.mode != "rate" or not self.held or not self.moved:
                return self._drain()
            self._acc_v += self._velocity(self.offy, self.cfg.invert_v) * dt
            if self.cfg.horizontal:
                self._acc_h += self._velocity(self.offx, self.cfg.invert_h, horiz=True) * dt
            return self._drain()

        def _velocity(self, off, invert, horiz=False):
            eff = abs(off) - self.cfg.deadzone
            if eff <= 0: return 0.0
            notches = min(self.cfg.gain * (eff ** self.cfg.exponent), self.cfg.max_speed)
            hires = notches * HIRES_PER_NOTCH
            if horiz:
                sign = 1.0 if off > 0 else -1.0
                if invert: sign = -sign
            else:
                sign = -1.0 if off > 0 else 1.0
                if invert: sign = -sign
            return sign * hires

        def _drain(self):
            v, h = int(self._acc_v), int(self._acc_h)
            if v == 0 and h == 0: return []
            self._acc_v -= v
            self._acc_h -= h
            return [("wheel", v, h)]

    def _run():
        import re, selectors, evdev
        from evdev import ecodes as e

        cfg = Config()
        sel = selectors.DefaultSelector()

        def looks_like_mouse(d):
            caps = d.capabilities()
            return (e.REL_X in caps.get(e.EV_REL, []) and e.REL_Y in caps.get(e.EV_REL, [])
                    and e.BTN_LEFT in caps.get(e.EV_KEY, []) and e.BTN_MIDDLE in caps.get(e.EV_KEY, []))

        def discover():
            if cfg.device: return [evdev.InputDevice(cfg.device)]
            pat = re.compile(cfg.match_name)
            found = []
            for path in evdev.list_devices():
                try: d = evdev.InputDevice(path)
                except OSError: continue
                if d.name == cfg.uinput_name: continue
                if looks_like_mouse(d) and pat.search(d.name or ""): found.append(d)
                else: d.close()
            return found

        sources = discover()
        if not sources:
            print("mmb-autoscroll: no matching mouse found; waiting...", file=sys.stderr)
            while not sources:
                time.sleep(10)
                sources = discover()

        ui = evdev.UInput.from_device(*sources, name=cfg.uinput_name, filtered_types=(e.EV_SYN, e.EV_FF))
        engines = {}
        for d in sources:
            try: d.grab()
            except OSError: continue
            engines[d.fd] = (d, ScrollEngine(cfg))
            sel.register(d.fd, selectors.EVENT_READ, d)

        if not engines: sys.exit(1)
        tick = cfg.tick_ms / 1000.0

        def emit_wheel(v_hires, h_hires):
            if v_hires:
                ui.write(e.EV_REL, e.REL_WHEEL_HI_RES, v_hires)
                notch = int(round(v_hires / HIRES_PER_NOTCH))
                if notch: ui.write(e.EV_REL, e.REL_WHEEL, notch)
            if h_hires:
                ui.write(e.EV_REL, e.REL_HWHEEL_HI_RES, h_hires)
                notch = int(round(h_hires / HIRES_PER_NOTCH))
                if notch: ui.write(e.EV_REL, e.REL_HWHEEL, notch)
            ui.syn()

        def emit_click():
            ui.write(e.EV_KEY, e.BTN_MIDDLE, 1); ui.syn()
            ui.write(e.EV_KEY, e.BTN_MIDDLE, 0); ui.syn()

        def do_intents(intents):
            for it in intents:
                if it[0] == "click": emit_click()
                elif it[0] == "wheel": emit_wheel(it[1], it[2])

        last = time.monotonic()
        any_scrolling = lambda: any(eng.held and eng.moved for _, eng in engines.values())

        while True:
            events = sel.select(tick if any_scrolling() else None)
            now = time.monotonic()
            for key, _ in events:
                dev = key.data
                eng = engines[dev.fd][1]
                try: batch = list(dev.read())
                except OSError:
                    sel.unregister(dev.fd)
                    try: dev.ungrab(); dev.close()
                    except OSError: pass
                    del engines[dev.fd]
                    if not engines: sys.exit(1)
                    continue

                pending_syn = False
                for ev in batch:
                    if ev.type == e.EV_KEY and ev.code == e.BTN_MIDDLE:
                        if ev.value == 1: do_intents(eng.middle_down(now))
                        elif ev.value == 0: do_intents(eng.middle_up(now))
                    elif ev.type == e.EV_REL and ev.code in (e.REL_X, e.REL_Y):
                        if eng.held:
                            dx = ev.value if ev.code == e.REL_X else 0
                            dy = ev.value if ev.code == e.REL_Y else 0
                            eng.add_motion(dx, dy)
                            if cfg.mode == "position": do_intents(eng._drain())
                        else:
                            ui.write(ev.type, ev.code, ev.value)
                            pending_syn = True
                    elif ev.type == e.EV_SYN:
                        if pending_syn: ui.syn(); pending_syn = False
                    else:
                        ui.write(ev.type, ev.code, ev.value); pending_syn = True
                if pending_syn: ui.syn()

            if cfg.mode == "rate":
                dt = now - last
                for _, eng in engines.values(): do_intents(eng.tick(dt))
            last = now

    if __name__ == "__main__":
        _run()
  '';
in
{
  hardware.uinput.enable = true;
  environment.systemPackages = [ mmb-autoscroll-pkg ];

  systemd.services.mmb-autoscroll = {
    description = "mmb-autoscroll — Windows-style middle-button autoscroll";
    after = [ "systemd-udevd.service" ];
    wants = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    startLimitIntervalSec = 0;    

    serviceConfig = {
      Type = "simple";
      EnvironmentFile = "/etc/mmb-autoscroll.conf";
      ExecStart = "/usr/bin/env mmb-autoscroll";
      Restart = "always";
      RestartSec = 2;
   # disabled hardening
   #   DevicePolicy = "closed";
   #   DeviceAllow = [
   #     "/dev/uinput rw"
   #     "/dev/input/event* rw"
   #   ];
   #   ProtectSystem = "strict";
   #   ProtectHome = true;
   #   PrivateTmp = true;
   #   ProtectControlGroups = true;
   #   ProtectKernelTunables = true;
   #   RestrictAddressFamilies = [ "AF_UNIX" ];
   #   NoNewPrivileges = true;
    };
  };
}

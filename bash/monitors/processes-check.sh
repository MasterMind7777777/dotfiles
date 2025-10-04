bash <<'SH'
set -euo pipefail
OUT="/tmp/proc_audit_$(date +%F_%H%M%S).txt"

hdr(){ printf "\n===== %s =====\n" "$1" >>"$OUT"; }
run(){ echo "\$ $*" >>"$OUT"; eval "$@" >>"$OUT" 2>&1 || true; }

: >"$OUT"
hdr "Host / Kernel / Time"
run 'echo "user=$USER  host=$( { hostnamectl --static 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n; } )  kernel=$(uname -r)  time=$(date -Is)"'

# 1) Top CPU / MEM processes
hdr "Top CPU processes"
run "ps -eo pid,user,comm,pcpu,pmem,etime --sort=-pcpu | head -n 25"

hdr "Top MEM processes"
run "ps -eo pid,user,comm,pmem,pcpu,rss,vsz --sort=-pmem | head -n 25"

# 2) Network: established connections and listening sockets
hdr "Established TCP/UDP connections (processes)"
run "ss -tupan | grep ESTAB || true"

hdr "Listening sockets (who's listening)"
run "ss -tulpen"

# 3) NVIDIA / GPU processes (if present)
if command -v nvidia-smi >/dev/null 2>&1; then
  hdr "NVIDIA GPU processes"
  run "nvidia-smi | sed -n '1,12p'"
  run "nvidia-smi pmon -c 1"
  run "nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader || true"
fi

# 4) Suspicious locations: /tmp, /var/tmp, /home
hdr "Processes executing from /tmp, /var/tmp, or /home"
run 'for p in /proc/[0-9]*; do
        pid=${p#/proc/}
        exe=$(readlink -f "$p/exe" 2>/dev/null || true)
        [ -n "$exe" ] || continue
        case "$exe" in
          /tmp/*|/var/tmp/*|/home/*)
            printf "%-8s %-12s %s\n" "$pid" "$(ps -o user= -p "$pid" 2>/dev/null)" "$exe"
          ;;
        esac
     done | sort -u'

# 5) Deleted-on-disk executables still running
hdr "Processes with deleted executables"
run 'ls -l /proc/*/exe 2>/dev/null | grep "(deleted)" || true'

# 6) Executables not owned by any package (could be custom or odd)
hdr "Executables NOT owned by a package (first 200 unique)"
run 'count=0; 
     for p in /proc/[0-9]*; do 
       exe=$(readlink -f "$p/exe" 2>/dev/null || true); 
       [ -n "$exe" ] && echo "$exe"; 
     done | sort -u | while read -r bin; do 
       [ -x "$bin" ] || continue
       pacman -Qo -- "$bin" >/dev/null 2>&1 || echo "$bin"
       count=$((count+1)); [ "$count" -ge 200 ] && break
     done'

# 7) Running services
hdr "System services (running)"
run "systemctl --no-pager --type=service --state=running | sed -n '1,200p'"

hdr "User services (running)"
run "systemctl --user --no-pager --type=service --state=running | sed -n '1,200p'"

# 8) Environment flags that can affect drivers/rendering
hdr "Env flags that may affect graphics"
run 'env | grep -E "^(MESA_|__GL_|VK_|DXVK_|VKD3D_|vblank_mode=)" || true'

echo "Report saved to: $OUT"
printf "\nTip: send me this file or paste sections you want reviewed.\n"
SH

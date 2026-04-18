#!/bin/bash

echo ""   


while true; do
  tput cuu 15 2>/dev/null
    
  pl1=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl1_spl/current_value 2>/dev/null)
  pl2=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/ppt_pl2_sppt/current_value 2>/dev/null)
  gpu_tgp=$(cat /sys/class/firmware-attributes/asus-armoury/attributes/dgpu_tgp/current_value 2>/dev/null)
    
  cpu_temp=0
  for zone in /sys/class/thermal/thermal_zone*; do   

    type=$(cat $zone/type 2>/dev/null)
    if [[ "$type" == *"x86_pkg_temp"* ]] || [[ "$type" == *"TCPU"* ]]; then
      temp=$(cat $zone/temp 2>/dev/null)
      cpu_temp=$((temp / 1000))
      break
    fi
  done
    
  if [ "$pl1" -ge 60 ]; then
    power_status="ok AC POWER"
    power_mode="Gaming Performance"
  elif [ "$pl1" -ge 45 ]; then

    power_status="~ Balanced"
    power_mode="Moderate Performance"
  else
    power_status="fail BATTERY MODE"
    power_mode="Throttled Performance"
  fi
    
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "  Power Status:  %b\n" "$power_status"
  printf "  Mode:          %s\n" "$power_mode"
  echo ""
  printf "  CPU Power:     %2dW / %2dW (PL1/PL2)\n" "$pl1" "$pl2"
  printf "  GPU Power:     %2dW TGP\n" "$gpu_tgp"
  echo ""
  printf "  CPU Temp:      %2d°C\n" "$cpu_temp"
    
  if [ "$cpu_temp" -gt 90 ]; then
    echo -e "  warn  THERMAL THROTTLING LIKELY"
  elif [ "$cpu_temp" -gt 85 ]; then
    echo -e "   Running Hot"
  else   
    echo -e "  ok Good Temperature"
  fi
    
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "  %s (Ctrl+C to exit)\n" "$(date '+%H:%M:%S')"

  sleep 2
done

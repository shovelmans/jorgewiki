#!/bin/bash
set -euo pipefail

NAMESPACE="${KAFKA_NAMESPACE:-kafka}"
POD="${KAFKA_POD:-kafka-cli}"
BOOTSTRAP="${KAFKA_BOOTSTRAP:-lab-kafka-kafka-bootstrap:9092}"

TOPIC_RE=""
GROUP_RE=""
SHOW_ALL=false
TSV=false

while getopts ":t:g:aqh" opt; do
  case "$opt" in
    t) TOPIC_RE="$OPTARG" ;;
    g) GROUP_RE="$OPTARG" ;;
    a) SHOW_ALL=true ;;
    q) TSV=true ;;
    h)
      cat <<EOH
Uso: $0 [-t topic_regex] [-g group_regex] [-a] [-q]

Opciones:
  -t  Filtrar por topic (regex)
  -g  Filtrar por consumer group (regex)
  -a  Mostrar también particiones con lag = 0
  -q  Salida TSV

Variables:
  KAFKA_NAMESPACE  default: kafka
  KAFKA_POD        default: kafka-cli
  KAFKA_BOOTSTRAP  default: lab-kafka-kafka-bootstrap:9092
EOH
      exit 0
      ;;
    \?) echo "Opción inválida: -$OPTARG" >&2; exit 1 ;;
    :)  echo "Falta argumento para -$OPTARG" >&2; exit 1 ;;
  esac
done

echo "[kubectl] Verificando pod..." >&2
kubectl get pod "$POD" -n "$NAMESPACE" >/dev/null

CONSUMER_GROUPS=$(kubectl exec -n "$NAMESPACE" "$POD" -- \
  bin/kafka-consumer-groups.sh \
    --bootstrap-server "$BOOTSTRAP" \
    --list)

TMP_OUT="$(mktemp)"

for GROUP in $CONSUMER_GROUPS; do
  if [[ -n "$GROUP_RE" && ! "$GROUP" =~ $GROUP_RE ]]; then
    continue
  fi

  OUTPUT=$(kubectl exec -n "$NAMESPACE" "$POD" -- \
    bin/kafka-consumer-groups.sh \
      --bootstrap-server "$BOOTSTRAP" \
      --describe \
      --group "$GROUP" 2>/dev/null || true)

  while IFS= read -r LINE; do
    [[ -z "$LINE" ]] && continue
    [[ "$LINE" =~ ^TOPIC[[:space:]] ]] && continue
    [[ "$LINE" =~ ^GROUP[[:space:]] ]] && continue
    [[ "$LINE" =~ ^Consumer[[:space:]]group ]] && continue

    TOPIC=$(echo "$LINE" | awk '{print $2}')
    PARTITION=$(echo "$LINE" | awk '{print $3}')
    CURRENT=$(echo "$LINE" | awk '{print $4}')
    END=$(echo "$LINE" | awk '{print $5}')
    LAG=$(echo "$LINE" | awk '{print $6}')

    [[ -z "${TOPIC:-}" || -z "${PARTITION:-}" || -z "${LAG:-}" ]] && continue

    if [[ -n "$TOPIC_RE" && ! "$TOPIC" =~ $TOPIC_RE ]]; then
      continue
    fi

    if [[ "$SHOW_ALL" = false && "$LAG" = "0" ]]; then
      continue
    fi

    if [[ "$TSV" = true ]]; then
      printf "%s\t%s\t%s\t%s\n" "$LAG" "$GROUP" "$TOPIC" "$PARTITION" >> "$TMP_OUT"
    else
      printf "%-10s %-20s %-20s %-10s\n" "$LAG" "$GROUP" "$TOPIC" "$PARTITION" >> "$TMP_OUT"
    fi
  done <<< "$OUTPUT"
done

if [[ "$TSV" = true ]]; then
  [[ -s "$TMP_OUT" ]] && sort -nr "$TMP_OUT"
else
  printf "%-10s %-20s %-20s %-10s\n" "LAG" "GROUP" "TOPIC" "PARTITION"
  [[ -s "$TMP_OUT" ]] && sort -nr "$TMP_OUT"
fi

rm -f "$TMP_OUT"
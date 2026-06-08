#!/bin/bash

POD=$(kubectl get pod -n prueba -l app=demo --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')
RUTA="/usr/share/nginx/html"

echo "Poblando PVC en pod: $POD"

kubectl exec -n prueba $POD -- sh -c "
mkdir -p $RUTA/imagenes/2023 $RUTA/imagenes/2024 $RUTA/documentos/pdf $RUTA/documentos/word $RUTA/videos $RUTA/logs

# index
echo '<html><body>Demo RWO Lab</body></html>' > $RUTA/index.html

# imagenes 2023
for i in \$(seq 1 20); do
  dd if=/dev/urandom bs=100K count=1 2>/dev/null | base64 > $RUTA/imagenes/2023/foto_\${i}.jpg
done

# imagenes 2024
for i in \$(seq 1 20); do
  dd if=/dev/urandom bs=100K count=1 2>/dev/null | base64 > $RUTA/imagenes/2024/foto_\${i}.jpg
done

# documentos pdf
for i in \$(seq 1 10); do
  dd if=/dev/urandom bs=50K count=1 2>/dev/null | base64 > $RUTA/documentos/pdf/documento_\${i}.pdf
done

# documentos word
for i in \$(seq 1 10); do
  dd if=/dev/urandom bs=50K count=1 2>/dev/null | base64 > $RUTA/documentos/word/informe_\${i}.docx
done

# videos
for i in \$(seq 1 5); do
  dd if=/dev/urandom bs=1M count=1 2>/dev/null | base64 > $RUTA/videos/video_\${i}.mp4
done

# logs
for i in \$(seq 1 15); do
  echo 'INFO $(date) - Entrada de log numero $i del sistema de demo' >> $RUTA/logs/app.log
done

echo 'Datos creados correctamente'
"

echo ""
echo "=== RESUMEN ==="
kubectl exec -n prueba $POD -- find $RUTA | wc -l
kubectl exec -n prueba $POD -- du -sh $RUTA
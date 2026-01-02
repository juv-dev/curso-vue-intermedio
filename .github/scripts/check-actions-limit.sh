#!/bin/bash
# Verifica si se ha alcanzado el límite de minutos de GitHub Actions

# Verificar que las variables de entorno estén configuradas
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPOSITORY" ]; then
  echo "Error: Las variables GITHUB_TOKEN y GITHUB_REPOSITORY son requeridas"
  exit 1
fi

# Obtener el límite de la API
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/rate_limit")

# Verificar si la respuesta es válida
if [ -z "$RESPONSE" ]; then
  echo "Error: No se pudo obtener la información de límite de la API"
  exit 1
fi

# Extraer minutos restantes
REMAINING=$(echo "$RESPONSE" | jq -r '.resources.actions.remaining // empty')
if [ -z "$REMAINING" ]; then
  echo "Error: No se pudo obtener el límite de minutos restantes"
  echo "Respuesta de la API: $RESPONSE"
  exit 1
fi

echo "Minutos restantes de GitHub Actions: $REMAINING"

# Si quedan menos de 100 minutos, desactivar required_status_checks
if [ "$REMAINING" -lt 100 ]; then
  echo "Pocos minutos restantes, desactivando verificación de estado..."
  
  # Obtener la configuración actual
  CURRENT_CONFIG=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/branches/main/protection")
  
  # Verificar si se obtuvo la configuración correctamente
  if [ -z "$CURRENT_CONFIG" ] || [ "$(echo "$CURRENT_CONFIG" | jq -r '.message?')" = "Not Found" ]; then
    echo "Error: No se pudo obtener la configuración de protección de la rama"
    echo "Respuesta: $CURRENT_CONFIG"
    exit 1
  fi
  
  # Crear payload sin required_status_checks
  PAYLOAD=$(echo "$CURRENT_CONFIG" | jq 'del(.required_status_checks)')
  
  # Aplicar cambios
  RESPONSE=$(echo "$PAYLOAD" | \
    curl -s -X PATCH \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/json" \
    "https://api.github.com/repos/$GITHUB_REPOSITORY/branches/main/protection" \
    -d @-)
  
  # Verificar si hubo errores
  if [ "$(echo "$RESPONSE" | jq -r '.message?')" != "null" ]; then
    echo "Error al actualizar la configuración: $RESPONSE"
    exit 1
  fi
  
  echo "✅ Verificación de estado desactivada temporalmente"
  exit 1
fi

echo "✅ Hay suficientes minutos disponibles"
exit 0
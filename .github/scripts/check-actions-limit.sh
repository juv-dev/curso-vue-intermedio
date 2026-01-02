#!/bin/bash
# Verifica si se ha alcanzado el límite de minutos de GitHub Actions

# Verificar que las variables de entorno estén configuradas
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPOSITORY" ]; then
  echo "Error: Las variables GITHUB_TOKEN y GITHUB_REPOSITORY son requeridas"
  echo "Asegúrate de configurar el secreto ADMIN_TOKEN en GitHub Secrets"
  exit 1
fi

# Verificar si jq está instalado
if ! command -v jq &> /dev/null; then
  echo "Instalando jq..."
  sudo apt-get update && sudo apt-get install -y jq
fi

# Función para manejar errores de la API
handle_api_error() {
  local response="$1"
  local error_msg="$2"
  
  if [ -z "$response" ] || [ "$(echo "$response" | jq -r '.message?')" != "null" ]; then
    echo "Error: $error_msg"
    echo "Respuesta: $response"
    exit 1
  fi
}

# Obtener el límite de la API
echo "🔍 Verificando límite de minutos de GitHub Actions..."
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/rate_limit")

handle_api_error "$RESPONSE" "No se pudo obtener la información de límite de la API"

# Extraer minutos restantes
REMAINING=$(echo "$RESPONSE" | jq -r '.resources.actions.remaining')
echo "⏱️  Minutos restantes: $REMAINING"

# Si quedan suficientes minutos, salir con éxito
if [ "$REMAINING" -ge 100 ]; then
  echo "✅ Hay suficientes minutos disponibles"
  exit 0
fi

echo "⚠️  Pocos minutos restantes, desactivando verificaciones de estado..."

# Obtener la configuración actual de protección
echo "🔒 Obteniendo configuración de protección de la rama main..."
CURRENT_CONFIG=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/branches/main/protection")

handle_api_error "$CURRENT_CONFIG" "No se pudo obtener la configuración de protección de la rama"

# Crear payload sin required_status_checks
echo "🔄 Actualizando configuración de protección..."
PAYLOAD=$(echo "$CURRENT_CONFIG" | jq 'del(.required_status_checks)')

# Aplicar cambios
RESPONSE=$(echo "$PAYLOAD" | \
  curl -s -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/branches/main/protection" \
  -d @-)

handle_api_error "$RESPONSE" "Error al actualizar la configuración de protección"

echo "✅ Verificación de estado desactivada temporalmente"
exit 1
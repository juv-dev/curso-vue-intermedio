#!/bin/bash
# Verifica si se ha alcanzado el límite de minutos de GitHub Actions

# Verificar que las variables de entorno estén configuradas
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPOSITORY" ]; then
  echo "Error: GITHUB_TOKEN and GITHUB_REPOSITORY are required"
  exit 1
fi

# Instalar jq si no está instalado
if ! command -v jq &> /dev/null; then
  echo "Installing jq..."
  sudo apt-get update && sudo apt-get install -y jq
fi

# Obtener el límite de la API
echo "🔍 Checking GitHub Actions minutes limit..."
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/rate_limit")

# Verificar si la respuesta es válida
if [ -z "$RESPONSE" ]; then
  echo "Error: Could not get rate limit information from API"
  exit 1
fi

# Extraer minutos restantes
REMAINING=$(echo "$RESPONSE" | jq -r '.resources.actions.remaining')
if [ "$REMAINING" == "null" ] || [ -z "$REMAINING" ]; then
  echo "⚠️  Could not determine remaining minutes. Response:"
  echo "$RESPONSE"
  echo "Continuing with security check..."
  exit 0  # Continue with security check if we can't determine remaining minutes
fi

echo "⏱️  Remaining minutes: $REMAINING"

# Si quedan suficientes minutos, salir con éxito
if [ "$REMAINING" -ge 100 ]; then
  echo "✅ Sufficient minutes available"
  exit 0
fi

echo "⚠️  Few minutes remaining, disabling status checks..."

# Obtener la configuración actual de protección
echo "🔒 Getting main branch protection..."
CURRENT_CONFIG=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/branches/main/protection")

# Verificar si se obtuvo la configuración correctamente
if [ -z "$CURRENT_CONFIG" ] || [ "$(echo "$CURRENT_CONFIG" | jq -r '.message?')" = "Not Found" ]; then
  echo "⚠️  Warning: Could not get branch protection settings. Make sure the token has admin:repo_hook permissions."
  echo "Response: $CURRENT_CONFIG"
  exit 0  # Continue with security check if we can't modify protection
fi

# Crear payload sin required_status_checks
echo "🔄 Updating protection settings..."
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
  echo "⚠️  Warning: Could not update branch protection:"
  echo "$RESPONSE"
  echo "Continuing with security check..."
  exit 0  # Continue with security check if we can't update protection
fi

echo "✅ Status checks temporarily disabled"
exit 1
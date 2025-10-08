#!/bin/bash

# LocalWhisper - Instalador de Certificados SSL (macOS)

echo "======================================================"
echo "🔐 Instalador de Certificados SSL para Python"
echo "======================================================"
echo ""
echo "Este script corrige o erro:"
echo "  'SSL: CERTIFICATE_VERIFY_FAILED'"
echo ""

# Detectar sistema operacional
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Este script é apenas para macOS"
    echo "No Linux, os certificados geralmente funcionam sem configuração adicional"
    exit 1
fi

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 não encontrado!"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "Python encontrado: $(python3 --version)"
echo ""

# Método 1: Executar Install Certificates.command (método oficial)
echo "Método 1: Executando Install Certificates.command do Python..."
echo ""

# Encontrar diretório do Python
PYTHON_DIR="/Applications/Python ${PYTHON_VERSION}"

if [ -d "$PYTHON_DIR" ]; then
    CERT_COMMAND="$PYTHON_DIR/Install Certificates.command"

    if [ -f "$CERT_COMMAND" ]; then
        echo "Executando: $CERT_COMMAND"
        open "$CERT_COMMAND"
        echo "✓ Comando de instalação executado"
        echo ""
        echo "Aguarde a janela de instalação fechar e pressione Enter..."
        read
    else
        echo "⚠️  Arquivo não encontrado: $CERT_COMMAND"
    fi
else
    echo "⚠️  Diretório do Python não encontrado: $PYTHON_DIR"
fi

echo ""

# Método 2: Instalar certifi via pip
echo "Método 2: Instalando/atualizando pacote certifi..."
echo ""

if [ -d "venv" ]; then
    source venv/bin/activate
    echo "Ambiente virtual ativado"
fi

pip install --upgrade certifi
echo "✓ Pacote certifi instalado/atualizado"

echo ""

# Método 3: Criar link simbólico (fallback)
echo "Método 3: Verificando link simbólico de certificados..."
echo ""

OPENSSL_DIR=$(python3 -c "import ssl; print(ssl.get_default_verify_paths().openssl_cafile)" 2>/dev/null)

if [ -n "$OPENSSL_DIR" ]; then
    echo "Certificados esperados em: $OPENSSL_DIR"

    if [ ! -f "$OPENSSL_DIR" ]; then
        echo "⚠️  Arquivo de certificados não encontrado"

        # Tentar encontrar certificados do certifi
        CERTIFI_PATH=$(python3 -c "import certifi; print(certifi.where())" 2>/dev/null)

        if [ -n "$CERTIFI_PATH" ] && [ -f "$CERTIFI_PATH" ]; then
            echo "Certificados certifi encontrados em: $CERTIFI_PATH"

            # Criar diretório se não existir
            CERT_DIR=$(dirname "$OPENSSL_DIR")
            if [ ! -d "$CERT_DIR" ]; then
                sudo mkdir -p "$CERT_DIR"
            fi

            # Criar link simbólico
            sudo ln -sf "$CERTIFI_PATH" "$OPENSSL_DIR"
            echo "✓ Link simbólico criado"
        fi
    else
        echo "✓ Certificados já configurados"
    fi
else
    echo "⚠️  Não foi possível determinar caminho dos certificados"
fi

echo ""
echo "======================================================"
echo "✅ Instalação concluída!"
echo "======================================================"
echo ""
echo "Agora tente executar a aplicação novamente:"
echo "  ./run.sh"
echo ""
echo "Se o erro persistir, tente as soluções alternativas em:"
echo "  README.md - Seção 'Erro SSL ao baixar modelos'"
echo ""

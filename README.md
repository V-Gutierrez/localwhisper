# 🎤 LocalWhisper

Aplicação web local para transcrição e tradução de áudio usando OpenAI Whisper.

## ✨ Características

- 🎯 **Interface simples e intuitiva** - Uma única tela com tudo que você precisa
- 📁 **Upload de arquivos** - Suporte para MP3, WAV, OGG, M4A, FLAC, WEBM, MP4, AVI
- 🎙️ **Gravação de áudio** - Grave diretamente pelo microfone
- 🌍 **Múltiplos idiomas** - Detecção automática ou seleção manual
- 🔄 **Transcrição e tradução** - Transcreva ou traduza para inglês
- ⚡ **Processamento local** - Seus áudios não saem do seu computador
- 📝 **Timestamps detalhados** - Veja cada segmento com marcação temporal
- 💾 **Exportação** - Copie ou baixe o resultado em .txt

## 🚀 Instalação

### Setup Rápido (Recomendado)

**macOS/Linux:**
```bash
./setup.sh
```

Este script irá:
- ✅ Detectar seu sistema operacional
- ✅ Instalar FFmpeg automaticamente
- ✅ Criar ambiente virtual Python
- ✅ Instalar todas as dependências
- ✅ Iniciar a aplicação (opcional)

Depois de instalado, para executar:
```bash
./run.sh
```

### Instalação Manual

Se preferir instalar manualmente:

#### 1. Instalar FFmpeg

**macOS:**
```bash
brew install ffmpeg
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install ffmpeg
```

#### 2. Configurar Python

```bash
# Criar ambiente virtual
python3 -m venv venv

# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

**Nota:** A instalação pode demorar alguns minutos, pois inclui PyTorch (~1GB).

## 🎬 Como Usar

1. **Inicie a aplicação:**
```bash
./run.sh

# Ou manualmente:
source venv/bin/activate
python app.py
```

2. **Acesse no navegador:**
```
http://localhost:5001
```

3. **Use a aplicação:**
   - Escolha o modelo (recomendado: `base`)
   - Selecione o idioma (ou deixe auto-detectar)
   - Escolha entre:
     - **Arrastar um arquivo** para a área de upload
     - **Gravar áudio** pelo microfone
   - Clique em **Transcrever**
   - Aguarde o processamento
   - Copie ou baixe o resultado

## 🗑️ Desinstalação

Para remover a aplicação e todos os dados:

```bash
./uninstall.sh
```

Este script irá:
- ✅ Remover ambiente virtual Python
- ✅ Limpar arquivos temporários
- ✅ Remover cache dos modelos Whisper (opcional)
- ✅ Desinstalar FFmpeg (opcional)

O código fonte será mantido caso queira reinstalar depois.

## 🔧 Modelos Disponíveis

| Modelo | Tamanho | Velocidade | Qualidade | Recomendação |
|--------|---------|------------|-----------|--------------|
| tiny   | ~75 MB  | Muito rápido | Básica | Testes rápidos |
| base   | ~150 MB | Rápido | Boa | **Uso geral** ✅ |
| small  | ~500 MB | Moderado | Muito boa | Alta qualidade |
| medium | ~1.5 GB | Lento | Excelente | Profissional |
| large  | ~3 GB   | Muito lento | Melhor | Máxima qualidade |

**Dica:** Na primeira vez que usar um modelo, ele será baixado automaticamente. Isso pode levar alguns minutos.

## 🌍 Idiomas Suportados

Português, Inglês, Espanhol, Francês, Alemão, Italiano, Japonês, Coreano, Chinês e [mais de 90 outros idiomas](https://github.com/openai/whisper#available-models-and-languages).

## ⚙️ Opções Avançadas

### Tarefa

- **Transcrever:** Converte áudio para texto no idioma original
- **Traduzir:** Converte áudio para texto em inglês (independente do idioma original)

### Personalização

Edite `app.py` para ajustar:
- Porta do servidor (padrão: 5001)
- Tamanho máximo de arquivo (padrão: 100MB)
- Formatos aceitos

## 🐛 Solução de Problemas

### Erro: "SSL: CERTIFICATE_VERIFY_FAILED" (macOS)

**Causa:** O Python no macOS não consegue verificar certificados SSL ao baixar modelos do Whisper.

**Erro típico:**
```
<urlopen error [SSL: CERTIFICATE_VERIFY_FAILED]
certificate verify failed: self signed certificate in certificate chain>
```

**Soluções (em ordem de preferência):**

1. **Executar script de instalação de certificados:**
   ```bash
   ./install_certificates.sh
   ```
   Este script instala os certificados SSL necessários para o Python.

2. **Instalação manual (macOS):**
   ```bash
   # Abrir pasta do Python
   open "/Applications/Python 3.X"  # Substitua X pela sua versão

   # Execute o arquivo "Install Certificates.command"
   ```

3. **Via pip:**
   ```bash
   source venv/bin/activate
   pip install --upgrade certifi
   ```

4. **Usar modelo menor:**
   - Use `tiny` ou `base` ao invés de `small`/`medium`/`large`
   - Modelos menores podem já estar em cache

5. **Download manual do modelo:**
   ```bash
   # Entre no Python
   python3

   # Execute:
   import whisper
   whisper.load_model("base")  # ou "tiny"
   ```

**Após instalar certificados:**
- Reinicie o terminal
- Execute `./run.sh` novamente

### Erro: "Porta já está em uso" / "Address already in use"

**Causa:** No macOS, a porta 5000 é usada pelo AirPlay Receiver por padrão.

**Soluções:**

1. **Use a porta 5001 (padrão da aplicação):**
   - A aplicação já está configurada para usar porta 5001
   - Acesse: `http://localhost:5001`

2. **Desabilite o AirPlay Receiver no macOS:**
   - Abra **System Preferences** (Preferências do Sistema)
   - Vá em **Sharing** (Compartilhamento)
   - Desmarque **AirPlay Receiver**

3. **Libere a porta manualmente:**
   ```bash
   # Encontre o processo usando a porta
   lsof -i :5001

   # Mate o processo (substitua PID pelo número mostrado)
   kill -9 PID
   ```

4. **Use outra porta:**
   - Edite `app.py` e mude a variável `port` para outra (ex: 8080, 3000)

### Erro: "FFmpeg not found"
- Certifique-se de que FFmpeg está instalado e no PATH do sistema
- Verifique com: `which ffmpeg` (deve retornar um caminho)
- Se não encontrado, execute `./setup.sh` novamente

### Erro ao gravar áudio
- Verifique se o navegador tem permissão para acessar o microfone
- Use HTTPS ou localhost (requisito dos navegadores modernos)

### Transcrição muito lenta
- Use um modelo menor (tiny ou base)
- Se tiver GPU NVIDIA, PyTorch pode usar automaticamente
- Verifique se há outros processos pesados rodando

### Primeira transcrição demora muito
- É normal! O modelo está sendo baixado
- Modelos ficam em cache em: `~/.cache/whisper/`
- Próximas transcrições serão muito mais rápidas

## 📁 Estrutura do Projeto

```
localwhisper/
├── app.py                      # Backend Flask
├── requirements.txt            # Dependências Python
├── README.md                   # Este arquivo
├── setup.sh                    # Script de instalação automática
├── run.sh                      # Script de execução rápida
├── uninstall.sh                # Script de desinstalação
├── install_certificates.sh     # Instalador de certificados SSL (macOS)
├── static/
│   ├── css/
│   │   └── style.css          # Estilos
│   └── js/
│       └── app.js             # Lógica do frontend
├── templates/
│   └── index.html             # Interface
└── uploads/                   # Arquivos temporários (criado automaticamente)
```

## 🔒 Privacidade

- **100% local**: Seus áudios nunca saem do seu computador
- Arquivos são processados localmente e deletados após transcrição
- Nenhuma conexão com servidores externos (exceto download inicial do modelo)

## 📝 Tecnologias

- **Backend:** Flask, OpenAI Whisper, PyTorch
- **Frontend:** HTML5, CSS3, JavaScript (Vanilla)
- **IA:** Whisper (OpenAI)

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para abrir issues ou pull requests.

## 📄 Licença

MIT License - veja o arquivo LICENSE para detalhes.

## 🙏 Agradecimentos

- [OpenAI Whisper](https://github.com/openai/whisper) - Modelo de transcrição
- Flask, PyTorch e toda comunidade open source

---

Feito com ❤️ para facilitar transcrições locais

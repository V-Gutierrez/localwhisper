import os
import sys
import ssl
import whisper
from flask import Flask, render_template, request, jsonify
from werkzeug.utils import secure_filename
import tempfile

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # 100MB max

# Extensões permitidas
ALLOWED_EXTENSIONS = {'mp3', 'wav', 'ogg', 'm4a', 'flac', 'webm', 'mp4', 'avi'}

# Cache do modelo carregado
loaded_model = None
loaded_model_name = None

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def load_whisper_model(model_name='base'):
    """Carrega o modelo Whisper (com cache e tratamento de erro SSL)"""
    global loaded_model, loaded_model_name

    if loaded_model is None or loaded_model_name != model_name:
        print(f"Carregando modelo {model_name}...")

        try:
            loaded_model = whisper.load_model(model_name)
            loaded_model_name = model_name
            print(f"Modelo {model_name} carregado!")

        except ssl.SSLError as e:
            print(f"\n❌ Erro SSL ao baixar modelo: {str(e)}")
            print("\n🔐 Solução:")
            print("   Execute: ./install_certificates.sh")
            print("   Ou veja: README.md - Seção 'Erro SSL ao baixar modelos'\n")
            raise Exception(
                "Erro SSL ao baixar modelo. "
                "Execute './install_certificates.sh' para instalar certificados SSL. "
                "Ou use um modelo menor (tiny/base) que pode já estar em cache."
            )

        except Exception as e:
            # Verificar se é erro relacionado a SSL (urllib.error.URLError)
            error_msg = str(e).lower()
            if 'ssl' in error_msg or 'certificate' in error_msg or 'urlopen' in error_msg:
                print(f"\n❌ Erro SSL detectado: {str(e)}")
                print("\n🔐 Solução:")
                print("   Execute: ./install_certificates.sh")
                print("   Ou veja: README.md - Seção 'Erro SSL ao baixar modelos'\n")
                raise Exception(
                    "Erro SSL ao baixar modelo. "
                    "Execute './install_certificates.sh' para instalar certificados SSL. "
                    "Ou use um modelo menor (tiny/base) que pode já estar em cache."
                )
            else:
                # Outro tipo de erro
                raise

    return loaded_model

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/transcribe', methods=['POST'])
def transcribe():
    try:
        # Verifica se há arquivo
        if 'audio' not in request.files:
            return jsonify({'error': 'Nenhum arquivo de áudio enviado'}), 400

        file = request.files['audio']

        if file.filename == '':
            return jsonify({'error': 'Nenhum arquivo selecionado'}), 400

        if not allowed_file(file.filename):
            return jsonify({'error': 'Formato de arquivo não suportado'}), 400

        # Parâmetros
        model_name = request.form.get('model', 'base')
        language = request.form.get('language', None)  # None = auto-detect
        task = request.form.get('task', 'transcribe')  # transcribe ou translate

        # Salva arquivo temporário
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        try:
            # Carrega modelo
            model = load_whisper_model(model_name)

            # Opções de transcrição
            options = {
                'task': task,
                'fp16': False  # Desabilita FP16 para compatibilidade
            }

            if language:
                options['language'] = language

            # Transcreve
            print(f"Transcrevendo {filename}...")
            result = model.transcribe(filepath, **options)

            # Remove arquivo temporário
            os.remove(filepath)

            return jsonify({
                'text': result['text'],
                'language': result.get('language', 'unknown'),
                'segments': [{
                    'start': seg['start'],
                    'end': seg['end'],
                    'text': seg['text']
                } for seg in result.get('segments', [])]
            })

        except Exception as e:
            # Remove arquivo em caso de erro
            if os.path.exists(filepath):
                os.remove(filepath)
            raise e

    except Exception as e:
        print(f"Erro: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/models', methods=['GET'])
def get_models():
    """Retorna modelos disponíveis"""
    return jsonify({
        'models': [
            {'name': 'tiny', 'size': '~75 MB', 'speed': 'Muito rápido', 'quality': 'Básica'},
            {'name': 'base', 'size': '~150 MB', 'speed': 'Rápido', 'quality': 'Boa'},
            {'name': 'small', 'size': '~500 MB', 'speed': 'Moderado', 'quality': 'Muito boa'},
            {'name': 'medium', 'size': '~1.5 GB', 'speed': 'Lento', 'quality': 'Excelente'},
            {'name': 'large', 'size': '~3 GB', 'speed': 'Muito lento', 'quality': 'Melhor'},
        ]
    })

if __name__ == '__main__':
    # Cria pasta de uploads se não existir
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    # Porta padrão (5001 ao invés de 5000 para evitar conflito com AirPlay no macOS)
    port = 5001

    print("\n" + "="*50)
    print("🎤 LocalWhisper - Transcrição Local com Whisper")
    print("="*50)
    print(f"\nAcesse: http://localhost:{port}")
    print("\nPressione Ctrl+C para sair")

    # Dica para macOS se porta 5000 estiver ocupada
    if port == 5001:
        print("\n💡 Dica: No macOS, a porta 5000 é usada pelo AirPlay Receiver.")
        print("   Para liberar: System Preferences → Sharing → Desabilite 'AirPlay Receiver'\n")
    else:
        print()

    try:
        app.run(debug=True, host='0.0.0.0', port=port)
    except OSError as e:
        if 'Address already in use' in str(e):
            print(f"\n❌ Erro: Porta {port} já está em uso!")
            print(f"\nTente uma das soluções:\n")
            print(f"1. Encontre e pare o processo na porta {port}:")
            print(f"   lsof -ti:{port} | xargs kill -9")
            print(f"\n2. Ou edite app.py e mude a variável 'port' para outra porta (ex: 8080)")
            print(f"\n3. No macOS, desabilite AirPlay Receiver:")
            print(f"   System Preferences → Sharing → Desabilite 'AirPlay Receiver'\n")
        else:
            raise

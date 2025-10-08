// Estado da aplicação
let selectedFile = null;
let mediaRecorder = null;
let audioChunks = [];
let recordingStartTime = null;
let recordingInterval = null;

// Elementos DOM
const dropZone = document.getElementById('drop-zone');
const fileInput = document.getElementById('file-input');
const fileInfo = document.getElementById('file-info');
const fileName = document.getElementById('file-name');
const fileSize = document.getElementById('file-size');
const clearFileBtn = document.getElementById('clear-file');
const transcribeBtn = document.getElementById('transcribe-btn');
const recordBtn = document.getElementById('record-btn');
const recordingStatus = document.getElementById('recording-status');
const recordingTime = document.getElementById('recording-time');
const loading = document.getElementById('loading');
const resultSection = document.getElementById('result-section');
const resultText = document.getElementById('result-text');
const detectedLanguage = document.getElementById('detected-language');
const segmentsContainer = document.getElementById('segments-container');
const copyBtn = document.getElementById('copy-btn');
const downloadBtn = document.getElementById('download-btn');
const newTranscriptionBtn = document.getElementById('new-transcription-btn');
const modelSelect = document.getElementById('model');
const languageSelect = document.getElementById('language');
const taskSelect = document.getElementById('task');

// Upload de arquivo via input
fileInput.addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (file) handleFileSelect(file);
});

// Drag and drop
dropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.add('dragging');
});

dropZone.addEventListener('dragleave', () => {
    dropZone.classList.remove('dragging');
});

dropZone.addEventListener('drop', (e) => {
    e.preventDefault();
    dropZone.classList.remove('dragging');
    const file = e.dataTransfer.files[0];
    if (file) handleFileSelect(file);
});

// Click na drop zone abre o file input
dropZone.addEventListener('click', () => {
    fileInput.click();
});

// Função para manipular arquivo selecionado
function handleFileSelect(file) {
    selectedFile = file;

    // Mostra info do arquivo
    fileName.textContent = file.name;
    fileSize.textContent = formatFileSize(file.size);
    fileInfo.style.display = 'flex';
    transcribeBtn.style.display = 'block';
    dropZone.style.display = 'none';
    recordBtn.style.display = 'none';
}

// Limpar arquivo selecionado
clearFileBtn.addEventListener('click', () => {
    resetUpload();
});

function resetUpload() {
    selectedFile = null;
    fileInput.value = '';
    fileInfo.style.display = 'none';
    transcribeBtn.style.display = 'none';
    dropZone.style.display = 'block';
    recordBtn.style.display = 'inline-flex';
    resultSection.style.display = 'none';
}

// Gravação de áudio
recordBtn.addEventListener('click', async () => {
    if (!mediaRecorder || mediaRecorder.state === 'inactive') {
        await startRecording();
    } else {
        stopRecording();
    }
});

async function startRecording() {
    try {
        const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

        mediaRecorder = new MediaRecorder(stream);
        audioChunks = [];

        mediaRecorder.ondataavailable = (e) => {
            audioChunks.push(e.data);
        };

        mediaRecorder.onstop = () => {
            const audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
            const audioFile = new File([audioBlob], 'recording.webm', { type: 'audio/webm' });
            handleFileSelect(audioFile);
            stream.getTracks().forEach(track => track.stop());
        };

        mediaRecorder.start();
        recordingStartTime = Date.now();

        // UI
        recordBtn.classList.add('recording');
        recordBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="6" width="12" height="12"></rect></svg><span>Parar Gravação</span>';
        recordingStatus.style.display = 'flex';
        dropZone.style.display = 'none';

        // Atualizar timer
        recordingInterval = setInterval(updateRecordingTime, 100);

    } catch (error) {
        alert('Erro ao acessar o microfone: ' + error.message);
    }
}

function stopRecording() {
    if (mediaRecorder && mediaRecorder.state === 'recording') {
        mediaRecorder.stop();
        recordBtn.classList.remove('recording');
        recordBtn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="8"></circle></svg><span>Gravar Áudio</span>';
        recordingStatus.style.display = 'none';
        clearInterval(recordingInterval);
    }
}

function updateRecordingTime() {
    const elapsed = Date.now() - recordingStartTime;
    const seconds = Math.floor(elapsed / 1000);
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    recordingTime.textContent = `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

// Transcrever
transcribeBtn.addEventListener('click', async () => {
    if (!selectedFile) return;

    // Esconde upload, mostra loading
    document.querySelector('.upload-section').style.display = 'none';
    loading.style.display = 'block';
    resultSection.style.display = 'none';

    try {
        const formData = new FormData();
        formData.append('audio', selectedFile);
        formData.append('model', modelSelect.value);
        formData.append('task', taskSelect.value);

        if (languageSelect.value) {
            formData.append('language', languageSelect.value);
        }

        const response = await fetch('/transcribe', {
            method: 'POST',
            body: formData
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.error || 'Erro ao transcrever');
        }

        // Mostra resultado
        displayResult(data);

    } catch (error) {
        alert('Erro: ' + error.message);
        loading.style.display = 'none';
        document.querySelector('.upload-section').style.display = 'block';
    }
});

// Exibir resultado
function displayResult(data) {
    loading.style.display = 'none';
    resultSection.style.display = 'block';

    // Texto
    resultText.textContent = data.text.trim();

    // Idioma detectado
    const languageNames = {
        'pt': 'Português',
        'en': 'Inglês',
        'es': 'Espanhol',
        'fr': 'Francês',
        'de': 'Alemão',
        'it': 'Italiano',
        'ja': 'Japonês',
        'ko': 'Coreano',
        'zh': 'Chinês'
    };
    const lang = languageNames[data.language] || data.language.toUpperCase();
    detectedLanguage.textContent = `Idioma: ${lang}`;

    // Segmentos
    if (data.segments && data.segments.length > 0) {
        segmentsContainer.innerHTML = '';
        data.segments.forEach(segment => {
            const segmentEl = document.createElement('div');
            segmentEl.className = 'segment';
            segmentEl.innerHTML = `
                <div class="segment-time">${formatTime(segment.start)} - ${formatTime(segment.end)}</div>
                <div class="segment-text">${segment.text.trim()}</div>
            `;
            segmentsContainer.appendChild(segmentEl);
        });
    }
}

// Copiar resultado
copyBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(resultText.textContent).then(() => {
        const originalText = copyBtn.textContent;
        copyBtn.textContent = 'Copiado!';
        setTimeout(() => {
            copyBtn.textContent = originalText;
        }, 2000);
    });
});

// Baixar resultado
downloadBtn.addEventListener('click', () => {
    const text = resultText.textContent;
    const blob = new Blob([text], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'transcricao.txt';
    a.click();
    URL.revokeObjectURL(url);
});

// Nova transcrição
newTranscriptionBtn.addEventListener('click', () => {
    resetUpload();
    document.querySelector('.upload-section').style.display = 'block';
});

// Utilitários
function formatFileSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

function formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

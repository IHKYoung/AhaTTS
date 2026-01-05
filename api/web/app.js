/**
 * AhaTTS - Frontend Application
 */

// API Base URL
const API_BASE = window.location.origin;

const LANGUAGE_LABELS = {
    A: 'English (US)',
    B: 'English (UK)',
    E: 'Spanish',
    F: 'French',
    H: 'Hindi',
    I: 'Italian',
    J: 'Japanese',
    P: 'Portuguese',
    Z: 'Chinese',
};

// Language code to flag mapping
const LANGUAGE_FLAGS = {
    a: '🇺🇸',
    b: '🇬🇧',
    e: '🇪🇸',
    f: '🇫🇷',
    h: '🇮🇳',
    i: '🇮🇹',
    j: '🇯🇵',
    p: '🇧🇷',
    z: '🇨🇳',
};

// Gender code to icon mapping
const GENDER_ICONS = {
    f: '♀',
    m: '♂',
};

const PREVIEW_TEXT_BY_LANG = window.PREVIEW_TEXT_BY_LANG || {
    A: 'Hello, this is a voice preview.',
    B: 'Hello, this is a voice preview.',
    E: 'Hola, esta es una vista previa de la voz.',
    F: 'Bonjour, ceci est un apercu de la voix.',
    H: 'Namaste, yah awaaz ka preview hai.',
    I: 'Ciao, questa e una anteprima della voce.',
    J: 'Konnichiwa, kore wa boisu purebyu desu.',
    P: 'Ola, esta e uma previa da voz.',
    Z: 'Ni hao, zhe shi shengyin yulan.',
    OTHER: 'Hello, this is a voice preview.',
};

// DOM Elements
const elements = {
    textInput: document.getElementById('textInput'),
    charCount: document.getElementById('charCount'),
    voiceSelect: document.getElementById('voiceSelect'),
    previewVoice: document.getElementById('previewVoice'),
    speedSlider: document.getElementById('speedSlider'),
    speedValue: document.getElementById('speedValue'),
    formatSelect: document.getElementById('formatSelect'),
    generateBtn: document.getElementById('generateBtn'),
    playerSection: document.getElementById('playerSection'),
    audioPlayer: document.getElementById('audioPlayer'),
    downloadBtn: document.getElementById('downloadBtn'),
    statusMessage: document.getElementById('statusMessage'),
};

// State
let currentAudioBlob = null;
let isGenerating = false;

function getVoiceLanguageCode(voice) {
    return (voice || '').charAt(0).toUpperCase();
}

function getVoiceLanguageLabel(voice) {
    return LANGUAGE_LABELS[getVoiceLanguageCode(voice)] || 'Other';
}

function getPreviewTextForVoice(voice) {
    const langCode = getVoiceLanguageCode(voice);
    return PREVIEW_TEXT_BY_LANG[langCode]
        || PREVIEW_TEXT_BY_LANG.OTHER
        || 'Hello, this is a voice preview.';
}

/**
 * Format voice name for display
 * Converts "af_alloy" to "🇺🇸 ♀ Alloy"
 * @param {string} voiceName - Raw voice name (e.g., "af_alloy")
 * @returns {string} Formatted display name
 */
function formatVoiceName(voiceName) {
    if (!voiceName || voiceName.length < 3) {
        return voiceName;
    }

    // Extract parts: language code (1st char), gender code (2nd char), name (after underscore)
    const langCode = voiceName.charAt(0).toLowerCase();
    const genderCode = voiceName.charAt(1).toLowerCase();
    const underscoreIndex = voiceName.indexOf('_');
    const namePart = underscoreIndex >= 0
        ? voiceName.substring(underscoreIndex + 1)
        : voiceName.substring(2);

    // Get language flag
    const languageFlag = LANGUAGE_FLAGS[langCode] || '🌐';

    // Get gender icon
    const genderIcon = GENDER_ICONS[genderCode] || '';

    // Capitalize name part
    const formattedName = namePart.charAt(0).toUpperCase() + namePart.slice(1);

    // Combine: flag + gender icon + name
    return `${languageFlag} ${genderIcon} ${formattedName}`.trim();
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initEventListeners();
    loadVoices();
});

/**
 * Initialize event listeners
 */
function initEventListeners() {
    // Text input - character count
    elements.textInput.addEventListener('input', () => {
        elements.charCount.textContent = elements.textInput.value.length;
    });

    // Speed slider
    elements.speedSlider.addEventListener('input', (e) => {
        elements.speedValue.textContent = parseFloat(e.target.value).toFixed(1);
    });

    // Preview voice button
    elements.previewVoice.addEventListener('click', previewVoice);

    // Generate button
    elements.generateBtn.addEventListener('click', generateSpeech);

    // Download button
    elements.downloadBtn.addEventListener('click', downloadAudio);

    // Keyboard shortcut - Cmd/Ctrl + Enter to generate
    elements.textInput.addEventListener('keydown', (e) => {
        if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
            e.preventDefault();
            generateSpeech();
        }
    });
}

/**
 * Load available voices from API
 */
async function loadVoices() {
    try {
        const response = await fetch(`${API_BASE}/v1/audio/voices`);
        if (!response.ok) throw new Error('Failed to load voices');

        const data = await response.json();
        const voices = data.voices || [];

        // Clear and populate voice select
        elements.voiceSelect.innerHTML = '';

        // Group voices by language
        const voiceGroups = {};
        voices.forEach(voice => {
            const lang = getVoiceLanguageLabel(voice);
            if (!voiceGroups[lang]) {
                voiceGroups[lang] = [];
            }
            voiceGroups[lang].push(voice);
        });

        // Create optgroups
        Object.entries(voiceGroups).forEach(([lang, voiceList]) => {
            const optgroup = document.createElement('optgroup');
            optgroup.label = lang;

            voiceList.forEach(voice => {
                const option = document.createElement('option');
                option.value = voice;
                option.textContent = formatVoiceName(voice);
                optgroup.appendChild(option);
            });

            elements.voiceSelect.appendChild(optgroup);
        });

        // If no voices loaded, show default
        if (voices.length === 0) {
            const option = document.createElement('option');
            option.value = 'af_heart';
            option.textContent = formatVoiceName('af_heart');
            elements.voiceSelect.appendChild(option);
        }

    } catch (error) {
        console.error('Error loading voices:', error);
        showStatus('Failed to load voices', 'error');
    }
}

/**
 * Preview selected voice with sample text
 */
async function previewVoice() {
    const voice = elements.voiceSelect.value;
    const sampleText = getPreviewTextForVoice(voice);

    // Disable preview button during playback
    elements.previewVoice.disabled = true;

    try {
        showStatus('Generating preview...', 'info');

        const response = await fetch(`${API_BASE}/v1/audio/speech`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                input: sampleText,
                voice: voice,
                response_format: 'mp3',
                speed: 1.0,
            }),
        });

        if (!response.ok) {
            throw new Error('Failed to generate preview');
        }

        const audioBlob = await response.blob();
        const audioUrl = URL.createObjectURL(audioBlob);

        // Play preview
        const previewAudio = new Audio(audioUrl);
        previewAudio.onended = () => {
            URL.revokeObjectURL(audioUrl);
            elements.previewVoice.disabled = false;
        };
        previewAudio.onerror = () => {
            elements.previewVoice.disabled = false;
        };

        hideStatus();
        await previewAudio.play();

    } catch (error) {
        console.error('Error previewing voice:', error);
        showStatus('Preview failed', 'error');
        elements.previewVoice.disabled = false;
    }
}

/**
 * Generate speech from input text
 */
async function generateSpeech() {
    const text = elements.textInput.value.trim();

    if (!text) {
        showStatus('Please enter some text', 'error');
        return;
    }

    if (isGenerating) return;

    const voice = elements.voiceSelect.value;
    const speed = parseFloat(elements.speedSlider.value);
    const format = elements.formatSelect.value;

    setGenerating(true);
    hidePlayer();

    try {
        showStatus('Generating speech...', 'info');

        const response = await fetch(`${API_BASE}/v1/audio/speech`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                input: text,
                voice: voice,
                response_format: format,
                speed: speed,
                stream: false,
            }),
        });

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.detail || 'Generation failed');
        }

        currentAudioBlob = await response.blob();
        const audioUrl = URL.createObjectURL(currentAudioBlob);

        // Show player and set audio source
        elements.audioPlayer.src = audioUrl;
        showPlayer();
        hideStatus();

        // Auto-play
        await elements.audioPlayer.play().catch(() => {
            // Autoplay might be blocked, that's okay
        });

    } catch (error) {
        console.error('Error generating speech:', error);
        showStatus(error.message || 'Generation failed', 'error');
    } finally {
        setGenerating(false);
    }
}

/**
 * Download the generated audio
 */
function downloadAudio() {
    if (!currentAudioBlob) return;

    const format = elements.formatSelect.value;
    const timestamp = new Date().toISOString().slice(0, 19).replace(/[:-]/g, '');
    const filename = `ahatts_${timestamp}.${format}`;

    const url = URL.createObjectURL(currentAudioBlob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

/**
 * UI Helper Functions
 */
function setGenerating(generating) {
    isGenerating = generating;
    elements.generateBtn.disabled = generating;

    const btnText = elements.generateBtn.querySelector('.btn-text');
    const btnLoading = elements.generateBtn.querySelector('.btn-loading');

    if (generating) {
        btnText.classList.add('hidden');
        btnLoading.classList.remove('hidden');
    } else {
        btnText.classList.remove('hidden');
        btnLoading.classList.add('hidden');
    }
}

function showPlayer() {
    elements.playerSection.classList.remove('hidden');
}

function hidePlayer() {
    elements.playerSection.classList.add('hidden');
}

function showStatus(message, type = 'info') {
    elements.statusMessage.textContent = message;
    elements.statusMessage.className = `status-message ${type}`;
    elements.statusMessage.classList.remove('hidden');
}

function hideStatus() {
    elements.statusMessage.classList.add('hidden');
}

const lcdTestButton = document.getElementById('lcdTestButton');
const cameraTestButton = document.getElementById('cameraTestButton');
const video = document.getElementById('video');
const canvas = document.getElementById('canvas');
const captureButton = document.getElementById('captureButton');
const micTestButton = document.getElementById('micTestButton');
const speakerTestButton = document.getElementById('speakerTestButton');
const speakerControls = document.getElementById('speakerControls');
const playLeftButton = document.getElementById('playLeftButton');
const playAllButton = document.getElementById('playAllButton');
const playRightButton = document.getElementById('playRightButton');

lcdTestButton.addEventListener('click', startLcdTest);
cameraTestButton.addEventListener('click', startCameraTest);
captureButton.addEventListener('click', captureImage);
micTestButton.addEventListener('click', startMicTest);
speakerTestButton.addEventListener('click', showSpeakerControls);
playLeftButton.addEventListener('click', toggleLeftAudio);
playAllButton.addEventListener('click', toggleAllAudio);
playRightButton.addEventListener('click', toggleRightAudio);

const colors = ['black', 'white', 'red', 'green', 'blue'];
let currentColorIndex = 0;
let cameraOpen = false;
let micOpen = false;
let mediaRecorder;
let audioChunks = [];

/// Function to start the LCD test
function startLcdTest() {
    openFullscreen();
    document.body.style.backgroundColor = colors[currentColorIndex]; // Initial color
    document.body.style.overflow = 'hidden'; // Hide scrollbar
    hideContent(true); // Hide all text

    cleanUpListeners();
    document.addEventListener('keydown', handleKeyDown);
    document.addEventListener('mousedown', changeColor); // Change color on mouse click
}

// Handle keydown events
function handleKeyDown(event) {
    if (event.key === 'Escape') {
        if (document.fullscreenElement) {
            closeFullscreen();
        } else {
            exitLcdTest();
        }
    } else {
        changeColor();
    }
}

// Change the background color
function changeColor() {
    currentColorIndex = (currentColorIndex + 1) % colors.length;
    document.body.style.backgroundColor = colors[currentColorIndex];
}

// Exit the LCD test
function exitLcdTest() {
    document.body.style.backgroundColor = '#f0f0f0'; // Reset background
    document.body.style.overflow = ''; // Show scrollbar again
    hideContent(false); // Show all text

    cleanUpListeners();
}

// Clean up event listeners
function cleanUpListeners() {
    document.removeEventListener('keydown', handleKeyDown);
    document.removeEventListener('mousedown', changeColor);
}

// Open fullscreen mode
function openFullscreen() {
    if (document.documentElement.requestFullscreen) {
        document.documentElement.requestFullscreen();
    }
}

// Close fullscreen mode
function closeFullscreen() {
    if (document.exitFullscreen) {
        document.exitFullscreen().catch(err => {
            console.error(`Error attempting to exit fullscreen: ${err.message}`);
        });
    }
}

// Start the camera test
async function startCameraTest() {
    if (cameraOpen) {
        stopCamera(); // If camera is already open, stop it
    } else {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            video.srcObject = stream;
            cameraOpen = true;
            cameraTestButton.textContent = 'Stop Camera';
            document.getElementById('cameraContainer').style.display = 'block';
        } catch (error) {
            console.error("Error accessing the camera:", error);
            alert("Camera access denied.");
        }
    }
}

// Stop the camera
function stopCamera() {
    const stream = video.srcObject;
    if (stream) {
        const tracks = stream.getTracks();
        tracks.forEach(track => track.stop()); // Stop each track
    }
    video.srcObject = null; // Clear the video source
    cameraOpen = false; // Update the state
    cameraTestButton.textContent = 'Start Camera'; // Update button text
    document.getElementById('cameraContainer').style.display = 'none'; // Hide camera container
}

// Capture an image from the video stream
function captureImage() {
    const context = canvas.getContext('2d');
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    // Draw the current frame from the video onto the canvas
    context.drawImage(video, 0, 0, canvas.width, canvas.height);

    // Create a blob from the canvas image data
    canvas.toBlob(blob => {
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'capture.png'; // Set the default file name
        link.click(); // Trigger the download
    }, 'image/png'); // Specify the image format
}

// Start the microphone test
let recordingInterval; // Variable to hold the interval for the recording timer
let recordingTime = 0; // Variable to track recording time

// Start the microphone test
async function startMicTest() {
    if (!micOpen) {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorder = new MediaRecorder(stream);

            mediaRecorder.ondataavailable = event => {
                audioChunks.push(event.data);
            };

            mediaRecorder.onstop = () => {
                const audioBlob = new Blob(audioChunks);
                const audioURL = URL.createObjectURL(audioBlob);
                const audio = new Audio(audioURL);
                audio.play();
                audioChunks = []; // Reset chunks
                clearInterval(recordingInterval); // Stop the recording timer
                document.getElementById('timerDisplay').textContent = '00:00'; // Reset recording display
                document.getElementById('timerDisplay').style.display = 'none'; // Hide recording timer
            };

            mediaRecorder.start();
            micOpen = true;
            micTestButton.textContent = 'Stop Microphone'; // Update button text
            
            // Show recording timer
            recordingTime = 0; // Reset recording time
            document.getElementById('timerDisplay').textContent = formatTime(recordingTime); // Display initial time
            document.getElementById('timerDisplay').style.display = 'block'; // Show recording timer
            recordingInterval = setInterval(() => {
                recordingTime++;
                document.getElementById('timerDisplay').textContent = formatTime(recordingTime); // Update display
            }, 1000); // Update every second
            
            setTimeout(() => stopMicTest(), 5000); // Record for 5 seconds
        } catch (error) {
            console.error("Error accessing the microphone:", error);
            alert("Microphone access denied.");
        }
    } else {
        stopMicTest();
    }
}

// Stop the microphone test
function stopMicTest() {
    if (mediaRecorder && micOpen) {
        mediaRecorder.stop();
        micOpen = false;
        micTestButton.textContent = 'Start Microphone'; // Update button text
        document.getElementById('timerDisplay').style.display = 'none'; // Hide recording timer
    }
}

// Format time for display
function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

// Format time for display
function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
}

// Show speaker controls
// Show or hide speaker controls
function showSpeakerControls() {
    // Toggle display of speaker controls
    if (speakerControls.style.display === 'block') {
        speakerControls.style.display = 'none'; // Hide controls
    } else {
        speakerControls.style.display = 'block'; // Show controls
    }
}

// Update the event listener for the speaker test button
speakerTestButton.addEventListener('click', showSpeakerControls);

// Play audio through a specific channel
const leftAudio = new Audio('speaker-test-left.mp3');
const allAudio = new Audio('speaker-test.mp3');
const rightAudio = new Audio('speaker-test-right.mp3');

// Function to toggle left audio
function toggleLeftAudio() {
    if (!leftAudio.paused) {
        leftAudio.pause();
        leftAudio.currentTime = 0; // Reset to the start
        playLeftButton.textContent = 'Play Left'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        leftAudio.play();
        playLeftButton.textContent = 'Stop Left'; // Change button text
    }
}

// Function to toggle all audio
function toggleAllAudio() {
    if (!allAudio.paused) {
        allAudio.pause();
        allAudio.currentTime = 0; // Reset to the start
        playAllButton.textContent = 'Play All'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        allAudio.play();
        playAllButton.textContent = 'Stop All'; // Change button text
    }
}

// Function to toggle right audio
function toggleRightAudio() {
    if (!rightAudio.paused) {
        rightAudio.pause();
        rightAudio.currentTime = 0; // Reset to the start
        playRightButton.textContent = 'Play Right'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        rightAudio.play();
        playRightButton.textContent = 'Stop Right'; // Change button text
    }
}

// Function to stop all audio
function stopAllAudio() {
    leftAudio.pause();
    leftAudio.currentTime = 0; // Reset to the start
    allAudio.pause();
    allAudio.currentTime = 0; // Reset to the start
    rightAudio.pause();
    rightAudio.currentTime = 0; // Reset to the start

    // Reset button texts
    playLeftButton.textContent = 'Play Left';
    playAllButton.textContent = 'Play All';
    playRightButton.textContent = 'Play Right';
}

// Event listeners for audio ended
leftAudio.addEventListener('ended', function() {
    playLeftButton.textContent = 'Play Left';
});

allAudio.addEventListener('ended', function() {
    playAllButton.textContent = 'Play All';
});

rightAudio.addEventListener('ended', function() {
    playRightButton.textContent = 'Play Right';
});
// Hide or show content
function hideContent(hide) {
    const elements = document.body.children;
    for (let i = 0; i < elements.length; i++) {
        if (elements[i].id !== 'cameraContainer') { // Keep camera container visible
            elements[i].style.display = hide ? 'none' : '';
        }
    }
}

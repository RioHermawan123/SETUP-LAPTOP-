    // At the beginning of your script
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('testContainer').style.display = 'none';
    document.getElementById('fullscreenPrompt').style.display = 'block';
    
    document.addEventListener('keydown', startFullscreenTest);
});

function startFullscreenTest(event) {
    // Remove the event listener so this only happens once
    document.removeEventListener('keydown', startFullscreenTest);
    
    // Hide the fullscreen prompt
    document.getElementById('fullscreenPrompt').style.display = 'none';
    
    // Request fullscreen
    if (document.documentElement.requestFullscreen) {
        document.documentElement.requestFullscreen().then(() => {
            // After fullscreen is activated, show the test container and start the tests
            document.getElementById('testContainer').style.display = 'flex';
            initTestEnvironment();
        }).catch((error) => {
            console.error('Error attempting to enable fullscreen:', error.message);
            // If fullscreen fails, still show the test container and start the tests
            document.getElementById('testContainer').style.display = 'flex';
            initTestEnvironment();
        });
    } else {
        // If fullscreen is not supported, just show the test container and start the tests
        document.getElementById('testContainer').style.display = 'flex';
        initTestEnvironment();
    }
}


    
    // DOM Elements
    const video = document.getElementById('video');
    const canvas = document.getElementById('canvas');
    const captureButton = document.getElementById('captureButton');
    const currentTestDisplay = document.getElementById('currentTestDisplay');
    const testTitle = document.getElementById('testTitle');


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

    // Global variables
    const colors = ['black', 'red', 'green', 'blue', 'white'];
    let currentColorIndex = 0;
    let currentTest = 0;
    const tests = ['lcd', 'camera', 'speaker', 'mic'];
    


    // Initialize the test environment
// Modify your existing initTestEnvironment function
function initTestEnvironment() {
    currentTestDisplay.textContent = tests[currentTest];
    switchTest();
    document.addEventListener('keydown', handleKeyDown);
}
    
let debugInfoTimeout;

function showDebugInfo(testName) {
    const debugInfo = document.getElementById('debugInfo');
    const currentTestDisplay = document.getElementById('currentTestDisplay');
    
    if (debugInfo && currentTestDisplay) {
        currentTestDisplay.textContent = testName;
        debugInfo.style.opacity = '1';
        
        // Clear any existing timeout
        if (debugInfoTimeout) {
            clearTimeout(debugInfoTimeout);
        }
        
        // Set a new timeout to hide the debug info after 3 seconds
        debugInfoTimeout = setTimeout(() => {
            debugInfo.style.opacity = '0';
        }, 1500);
    }
}

    // Handle keydown events ----------------------------------------------------------------------
    function handleKeyDown(event) {
        switch(event.key) {
            case 'Escape':
                exitTestEnvironment();
                break;
            case 'ArrowLeft':
                if (currentTest > 0) {
                    currentTest--;
                    switchTest();
                }
                break;
            case 'ArrowRight':
                if (currentTest < tests.length - 1) {
                        currentTest++;
                        switchTest();
                } else if (tests[currentTest] === 'mic') {
                        exitFullscreen();
                        showTestComplete();
                    }
                break;
            default:
                if (tests[currentTest] === 'lcd') {
                    changeColor();
                }
        }
    }
    
    // Switch between tests --------------------------------------------------------------------
    function switchTest() {
        hideAllTests();
        document.body.style.backgroundColor = 'white';
        const currentTestName = tests[currentTest];
        showDebugInfo(currentTestName);
        
        switch(currentTestName) {
            case 'lcd':
                startLcdTest();
                stopCameraTest();
                break;
            case 'camera':
                startCameraTest();
                break;
            case 'speaker':
                startSpeakerTest();
                stopCameraTest();
                break;
            case 'mic':
                startMicTest();
                break;
        }
        testTitle.textContent = `TES ${currentTestName.toUpperCase()}`;
    }
    
    // LCD Test -------------------------------------------------------------------------------
    function startLcdTest() {
        document.getElementById('lcdTest').style.display = 'block';
        changeColor();
    }
    
    function changeColor() {
        currentColorIndex = (currentColorIndex + 1) % colors.length;
        document.body.style.backgroundColor = colors[currentColorIndex];
    }
    
// Camera Test --------------------------------------------------------------------------------
let stream;

function startCameraTest() {
    document.getElementById('cameraTest').style.display = 'block';
    if (!stream) {
        navigator.mediaDevices.getUserMedia({ video: true })
            .then(videoStream => {
                stream = videoStream;
                video.srcObject = stream;
                video.play();
            })
            .catch(error => {
                console.error("Error accessing the camera:", error);
                alert("Camera access denied.");
            });
    }
}

function captureImage() {
    if (stream) {
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        const image = canvas.toDataURL('image/png');
        const link = document.createElement('a');
        link.href = image;
        link.download = 'captured_image.png';
        link.click();
    } else {
        alert("Camera is not active. Please start the camera test first.");
    }
}

function stopCameraTest() {
    if (stream) {
        stream.getTracks().forEach(track => track.stop());
        stream = null;
        video.srcObject = null;
    }
}
 
document.getElementById('switchCameraButton').addEventListener('click', switchCamera);

function switchCamera() {
    if (stream) {
        stopCameraTest();
        navigator.mediaDevices.getUserMedia({ 
            video: { facingMode: stream.getVideoTracks()[0].getSettings().facingMode === 'user' ? 'environment' : 'user' }
        })
        .then(newStream => {
            stream = newStream;
            video.srcObject = stream;
            video.play();
        })
        .catch(error => {
            console.error("Error switching camera:", error);
            alert("Failed to switch camera.");
        });
    }
}

// Speaker Test -----------------------------------------------------------------------------------------------------------
const playLeftButton = document.getElementById('playLeftButton');
const playAllButton = document.getElementById('playAllButton');
const playRightButton = document.getElementById('playRightButton');

playLeftButton.addEventListener('click', toggleLeftAudio);
playAllButton.addEventListener('click', toggleAllAudio);
playRightButton.addEventListener('click', toggleRightAudio);


// Play audio through a specific channel
const leftAudio = new Audio('left.mp3');
const allAudio = new Audio('stereo.mp3');
const rightAudio = new Audio('right.mp3');

// Function to toggle left audio
function toggleLeftAudio() {
    if (!leftAudio.paused) {
        leftAudio.pause();
        leftAudio.currentTime = 0; // Reset to the start
        playLeftButton.textContent = 'KIRI'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        leftAudio.play();
        playLeftButton.textContent = 'STOP'; // Change button text
    }
}

// Function to toggle all audio
function toggleAllAudio() {
    if (!allAudio.paused) {
        allAudio.pause();
        allAudio.currentTime = 0; // Reset to the start
        playAllButton.textContent = 'STEREO'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        allAudio.play();
        playAllButton.textContent = 'STOP'; // Change button text
    }
}

// Function to toggle right audio
function toggleRightAudio() {
    if (!rightAudio.paused) {
        rightAudio.pause();
        rightAudio.currentTime = 0; // Reset to the start
        playRightButton.textContent = 'KANAN'; // Change button text
    } else {
        stopAllAudio(); // Stop any currently playing audio
        rightAudio.play();
        playRightButton.textContent = 'STOP'; // Change button text
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
    playLeftButton.textContent = 'KIRI';
    playAllButton.textContent = 'STEREO';
    playRightButton.textContent = 'KANAN';
}

// Event listeners for audio ended
leftAudio.addEventListener('ended', function() {
    playLeftButton.textContent = 'KIRI';
});

allAudio.addEventListener('ended', function() {
    playAllButton.textContent = 'STEREO';
});

rightAudio.addEventListener('ended', function() {
    playRightButton.textContent = 'KANAN';
});


function startSpeakerTest() {
    document.getElementById('speakerTest').style.display = 'block';
}


    // Mic Test ------------------------------------------------------------------------------------------------------

    // Make sure this function is called when you want to show the mic test
function startMicTest() {
    document.getElementById('micTest').style.display = 'block';
    document.getElementById('startRecordButton').style.display = 'inline-block';
    document.getElementById('stopRecordButton').style.display = 'none';
    document.getElementById('playRecordingButton').style.display = 'none';
    document.getElementById('recordingTimer').style.display = 'none';
    document.getElementById('recordedAudio').style.display = 'none';
}

// Make sure these event listeners are set up
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('startRecordButton').addEventListener('click', startRecording);
    document.getElementById('stopRecordButton').addEventListener('click', stopRecording);
    document.getElementById('playRecordingButton').addEventListener('click', playRecording);
});

// Rest of your JavaScript code for mic test...
    let mediaRecorder;
    let audioChunks = [];
    let audioBlob;
    let timerInterval;
    let startTime;
    
    document.getElementById('startRecordButton').addEventListener('click', startRecording);
    document.getElementById('stopRecordButton').addEventListener('click', stopRecording);
    document.getElementById('playRecordingButton').addEventListener('click', playRecording);
    
    function startRecording() {
        navigator.mediaDevices.getUserMedia({ audio: true })
            .then(stream => {
                mediaRecorder = new MediaRecorder(stream);
                mediaRecorder.start();
    
                audioChunks = [];
                mediaRecorder.addEventListener("dataavailable", event => {
                    audioChunks.push(event.data);
                });
    
                mediaRecorder.addEventListener("stop", () => {
                    audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                    document.getElementById('playRecordingButton').style.display = 'inline-block';
                });
    
                document.getElementById('startRecordButton').style.display = 'none';
                document.getElementById('stopRecordButton').style.display = 'inline-block';
                
                // Start the timer
                startTimer();
            })
            .catch(error => {
                console.error('Error accessing the microphone:', error);
                alert('Error accessing the microphone. Please check your permissions.');
            });
    }
    
    function stopRecording() {
        if (mediaRecorder && mediaRecorder.state !== 'inactive') {
            mediaRecorder.stop();
            mediaRecorder.stream.getTracks().forEach(track => track.stop());
        }
        document.getElementById('stopRecordButton').style.display = 'none';
        document.getElementById('startRecordButton').style.display = 'inline-block';
        
        // Stop the timer
        stopTimer();
    }
    
    function startTimer() {
        startTime = Date.now();
        document.getElementById('recordingTimer').style.display = 'block';
        updateTimer();
        timerInterval = setInterval(updateTimer, 1000);
    }
    
    function stopTimer() {
        clearInterval(timerInterval);
    }
    
    function updateTimer() {
        const elapsedTime = Date.now() - startTime;
        const seconds = Math.floor(elapsedTime / 1000);
        const minutes = Math.floor(seconds / 60);
        const formattedTime = 
            (minutes < 10 ? '0' : '') + minutes + ':' +
            (seconds % 60 < 10 ? '0' : '') + (seconds % 60);
        document.getElementById('recordingTimer').textContent = formattedTime;
    }
    
    function playRecording() {
        if (audioBlob) {
            const audioUrl = URL.createObjectURL(audioBlob);
            const audio = document.getElementById('recordedAudio');
            audio.src = audioUrl;
            audio.style.display = 'block';
            audio.play();
        }
    }
    






    // Helper functions
    function hideAllTests() {
        document.getElementById('lcdTest').style.display = 'none';
        document.getElementById('cameraTest').style.display = 'none';
        document.getElementById('speakerTest').style.display = 'none';
        document.getElementById('micTest').style.display = 'none';
    }
    
    // Initialize the test suite
    initTestEnvironment();
    
    // Additional event listeners
    captureButton.addEventListener('click', captureImage);

    
    // Capture image function
    function captureImage() {
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        const image = canvas.toDataURL('image/png');
        const link = document.createElement('a');
        link.href = image;
        link.download = 'captured_image.png';
        link.click();
    }
    
    // Audio playback function (you need to implement this with actual audio files)
    function playAudio(channel) {
        console.log(`Playing ${channel} audio`);
        // Implement audio playback logic here
    }

    function exitFullscreen() {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) { /* Safari */
            document.webkitExitFullscreen();
        } else if (document.msExitFullscreen) { /* IE11 */
            document.msExitFullscreen();
        }
    }
    function showTestComplete() {
        // Hide all test-specific elements
        hideAllTests();
        
        // Show a completion message
        const testContainer = document.getElementById('testContainer');
        testContainer.innerHTML = '<h1>Test Complete</h1><p>You have finished all tests.</p>';
    }
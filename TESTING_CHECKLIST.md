# 🧪 Testing Checklist - Speech-to-Text Feature

## Pre-Testing Requirements
- [ ] Android device fisik (bukan emulator)
- [ ] Microphone berfungsi normal
- [ ] Koneksi internet stabil
- [ ] APK ter-install di device

## 1. Permission Testing
### First Launch
- [ ] App meminta permission microphone
- [ ] Grant permission berhasil
- [ ] Mic button terlihat di chat input
- [ ] Mic button berwarna hijau

### Permission Denied
- [ ] Deny permission
- [ ] Mic button tidak terlihat
- [ ] Keyboard input tetap berfungsi
- [ ] App tidak crash

## 2. UI Testing
### Visual States
- [ ] Mic button hijau saat ready 🟢
- [ ] Mic button merah saat recording 🔴
- [ ] Status "Mendengarkan..." di AppBar
- [ ] Hint text berubah ke "Ketik atau tekan mic untuk berbicara..."
- [ ] Icon berubah dari `mic_none_rounded` ke `mic`

### Animations
- [ ] Smooth transition warna button
- [ ] Shadow effects terlihat
- [ ] Gradient background correct

## 3. Functionality Testing
### Basic Speech Recognition
- [ ] Tap mic button → Recording starts
- [ ] Speak "Halo" → Text muncul "Halo"
- [ ] Speak "Apa kabar" → Text muncul "Apa kabar"
- [ ] Stop talking 3 detik → Auto stop
- [ ] Manual tap stop → Recording stops

### Indonesian Language
- [ ] "Selamat pagi" → Recognized correctly
- [ ] "Apa arti kata loro?" → Recognized correctly
- [ ] "Bagaimana cara menggunakan" → Recognized correctly
- [ ] Numbers: "satu dua tiga" → "1 2 3" or "satu dua tiga"

### Real-time Updates
- [ ] Text appears while speaking (partial results)
- [ ] Text updates in real-time
- [ ] Final text accurate after stopping

## 4. Error Handling
### Network Issues
- [ ] Disconnect internet → Test behavior
- [ ] Reconnect internet → Should work again
- [ ] Slow connection → Test timeout

### Hardware Issues
- [ ] Cover microphone → Test low volume detection
- [ ] Background noise → Test accuracy
- [ ] Multiple apps using mic → Test conflict handling

### Edge Cases
- [ ] Very long speech (>30 seconds) → Auto stop
- [ ] No speech detected → Timeout handling
- [ ] Mumbling/unclear speech → Error gracefully

## 5. Integration Testing
### Chat Flow
- [ ] Speech → Text appears → Edit if needed → Send → Bot responds
- [ ] Multiple speech inputs in sequence
- [ ] Mix keyboard + speech input
- [ ] Speech → Clear text → Type manually

### App Lifecycle
- [ ] Minimize app during recording → Resume correctly
- [ ] Rotate device during recording → Handle correctly
- [ ] Background app → Return to app → State preserved

## 6. Performance Testing
### Memory Usage
- [ ] No memory leaks after multiple uses
- [ ] App responsive during speech recognition
- [ ] No UI freezing

### Battery Impact
- [ ] Normal battery drain
- [ ] Mic properly released when not in use

## 7. User Experience Testing
### Ease of Use
- [ ] Intuitive mic button placement
- [ ] Clear visual feedback
- [ ] Obvious start/stop states
- [ ] Helpful error messages

### Accessibility
- [ ] Button accessible via TalkBack
- [ ] Visual indicators clear
- [ ] Alternative input method available

## Test Scenarios

### Scenario 1: Happy Path
```
1. Open chatbot
2. Grant mic permission
3. Tap green mic button
4. Say "Apa arti kata tresna?"
5. Text appears: "Apa arti kata tresna?"
6. Tap send button
7. Bot responds with answer
✅ Expected: Smooth flow, accurate recognition
```

### Scenario 2: Correction Flow
```
1. Start speech recognition
2. Say "Apa arti kata loro"
3. Text shows "Apa arti kata loro"
4. Edit manually to "Apa arti kata loro dalam bahasa Jawa?"
5. Send message
✅ Expected: Easy text editing after speech
```

### Scenario 3: Multiple Languages
```
1. Say "Hello, apa kabar?" (mix English-Indonesian)
2. Say "Good morning, selamat pagi"
3. Say "Terima kasih, thank you"
✅ Expected: Reasonable recognition of mixed languages
```

### Scenario 4: Error Recovery
```
1. Start recording in noisy environment
2. Poor recognition results
3. Tap stop button
4. Try again in quiet place
5. Better results
✅ Expected: Easy retry mechanism
```

## Bug Report Template

**Bug**: [Short description]
**Steps to Reproduce**:
1. Step 1
2. Step 2
3. Step 3

**Expected Result**: [What should happen]
**Actual Result**: [What actually happened]
**Device**: [Device model and Android version]
**App Version**: [Version number]
**Additional Notes**: [Any other relevant info]

## Performance Metrics

### Success Metrics
- [ ] Speech recognition accuracy > 80%
- [ ] Response time < 2 seconds
- [ ] App stability (no crashes)
- [ ] User satisfaction with feature

### Failure Criteria
- [ ] Crashes during speech recognition
- [ ] No response to speech input
- [ ] Incorrect permission handling
- [ ] UI becomes unresponsive

---
📝 **Note**: Test pada berbagai kondisi (quiet room, noisy environment, different speaking speeds) untuk memastikan robustness.

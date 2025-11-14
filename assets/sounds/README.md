# Audio Assets for Roulette Module

This directory contains audio files for the roulette wheel experience.

## Required Files

### tick.mp3
- **Purpose**: Short tick/click sound played in loop during wheel rotation
- **Duration**: ~0.1-0.2 seconds
- **Type**: Short percussive sound (click, tick, or snap)
- **Usage**: Plays repeatedly while the wheel spins to create anticipation

### win.mp3  
- **Purpose**: Victory/celebration sound when wheel stops on a winning segment
- **Duration**: ~2-3 seconds
- **Type**: Triumphant, celebratory sound (fanfare, cheer, or success sound)
- **Usage**: Plays once when the wheel stops on a reward (not "nothing")

## Audio Requirements
- **Format**: MP3 (or other Flutter-supported formats: AAC, OGG)
- **Sample Rate**: 44.1 kHz recommended
- **Bit Rate**: 128-192 kbps
- **File Size**: Keep under 500KB each for optimal performance

## Sources for Free Sounds
- [Freesound.org](https://freesound.org)
- [Zapsplat](https://www.zapsplat.com)
- [Mixkit](https://mixkit.co/free-sound-effects/)
- [Pixabay Sounds](https://pixabay.com/sound-effects/)

## Integration Status
✅ Code is ready to use these audio files
✅ AudioPlayer service configured
⏳ Waiting for actual audio files to be added

Once you add the actual MP3 files, the roulette wheel will automatically play them during the spin experience.
